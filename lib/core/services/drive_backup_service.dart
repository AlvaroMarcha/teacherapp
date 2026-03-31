import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'backup_service.dart';

/// Cliente HTTP autenticado con las cabeceras de Google Sign-In.
class _AuthClient extends http.BaseClient {
  final http.Client _inner;
  final Map<String, String> _headers;

  _AuthClient(this._inner, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

/// Servicio de backup con Google Drive.
///
/// Usa Google Sign-In para autenticar y la API de Drive para
/// subir/descargar el archivo completo de la base de datos.
class DriveBackupService {
  static const _backupFileName = 'teacher_finance_backup.db';
  static const _backupMimeType = 'application/x-sqlite3';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  final BackupService _backupService;

  DriveBackupService(this._backupService);

  // ── Auth ──────────────────────────────────────────────────────────

  /// Si el usuario ya tiene sesión iniciada.
  bool get isSignedIn => _googleSignIn.currentUser != null;

  /// Email del usuario logueado, o null.
  String? get currentEmail => _googleSignIn.currentUser?.email;

  /// Intenta restaurar sesión silenciosamente (al abrir la app).
  Future<GoogleSignInAccount?> signInSilently() async {
    return _googleSignIn.signInSilently();
  }

  /// Abre el flujo de login de Google.
  Future<GoogleSignInAccount?> signIn() async {
    return _googleSignIn.signIn();
  }

  /// Cierra la sesión de Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  // ── Drive operations ──────────────────────────────────────────────

  /// Crea un cliente HTTP autenticado con el token del usuario.
  Future<drive.DriveApi> _getDriveApi() async {
    final account = _googleSignIn.currentUser;
    if (account == null) throw BackupException('not_signed_in');

    final authHeaders = await account.authHeaders;
    final client = _AuthClient(http.Client(), authHeaders);
    return drive.DriveApi(client);
  }

  /// Busca el archivo de backup en Google Drive (por nombre).
  Future<drive.File?> _findBackupFile(drive.DriveApi api) async {
    final fileList = await api.files.list(
      q: "name = '$_backupFileName' and trashed = false",
      spaces: 'drive',
      $fields: 'files(id, name, modifiedTime, size)',
    );
    final files = fileList.files;
    if (files == null || files.isEmpty) return null;
    return files.first;
  }

  /// Sube la base de datos actual a Google Drive.
  /// Si ya existe un backup, lo actualiza. Si no, lo crea.
  Future<void> uploadBackup() async {
    final api = await _getDriveApi();
    final dbPath = await _backupService.getDbPath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw BackupException('db_not_found');
    }

    final media = drive.Media(dbFile.openRead(), await dbFile.length());
    final existing = await _findBackupFile(api);

    if (existing != null && existing.id != null) {
      // Actualizar archivo existente
      await api.files.update(
        drive.File()
          ..description = 'Updated: ${DateTime.now().toIso8601String()}',
        existing.id!,
        uploadMedia: media,
      );
    } else {
      // Crear nuevo archivo
      final driveFile = drive.File()
        ..name = _backupFileName
        ..mimeType = _backupMimeType
        ..description = 'Created: ${DateTime.now().toIso8601String()}';
      await api.files.create(driveFile, uploadMedia: media);
    }
  }

  /// Descarga el backup de Google Drive y reemplaza la DB local.
  /// [closeDb] debe cerrar la base de datos antes de sobrescribir.
  /// Retorna `true` si se restauró correctamente.
  Future<bool> downloadBackup({
    required Future<void> Function() closeDb,
  }) async {
    final api = await _getDriveApi();
    final existing = await _findBackupFile(api);

    if (existing == null || existing.id == null) {
      throw BackupException('no_backup_found');
    }

    // Descargar archivo completo
    final media = await api.files.get(
      existing.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;

    final List<int> bytes = [];
    await for (final chunk in media.stream) {
      bytes.addAll(chunk);
    }

    // Cerrar DB antes de sobrescribir
    await closeDb();

    final dbPath = await _backupService.getDbPath();
    await File(dbPath).writeAsBytes(bytes);

    return true;
  }

  /// Obtiene la fecha de la última copia en Google Drive, o null.
  Future<DateTime?> getLastBackupDate() async {
    try {
      final api = await _getDriveApi();
      final existing = await _findBackupFile(api);
      return existing?.modifiedTime;
    } catch (_) {
      return null;
    }
  }
}
