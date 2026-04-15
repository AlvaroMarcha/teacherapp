import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Servicio de backup local: exportar/importar el archivo SQLite.
class BackupService {
  static const _dbFileName = 'teacher_app.db';

  /// Ruta absoluta del archivo de base de datos.
  Future<String> getDbPath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbFileName);
  }

  /// Exporta la DB usando el share sheet nativo.
  /// Copia el archivo con un nombre legible antes de compartir.
  Future<void> exportBackup() async {
    final dbPath = await getDbPath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) {
      throw const BackupException('No se encontró la base de datos');
    }

    // Copiar a tmp con nombre legible
    final now = DateTime.now();
    final timestamp =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final tmpDir = await getTemporaryDirectory();
    final exportName = 'teacher_finance_backup_$timestamp.db';
    final exportPath = p.join(tmpDir.path, exportName);
    await dbFile.copy(exportPath);

    await Share.shareXFiles([XFile(exportPath)]);
  }

  /// Crea una copia de seguridad automática (sin share sheet).
  /// Sobreescribe siempre el mismo archivo para no acumular copias.
  Future<void> createAutoBackup() async {
    final dbPath = await getDbPath();
    final dbFile = File(dbPath);
    if (!await dbFile.exists()) return;

    final dir = await getApplicationDocumentsDirectory();
    final backupPath = p.join(dir.path, 'teacher_finance_auto_backup.db');
    await dbFile.copy(backupPath);
  }

  /// Ruta del archivo de backup automático, o null si no existe.
  Future<String?> getAutoBackupPath() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'teacher_finance_auto_backup.db');
    if (await File(path).exists()) return path;
    return null;
  }

  /// Comparte el archivo de backup automático vía share sheet.
  Future<void> shareAutoBackup() async {
    final path = await getAutoBackupPath();
    if (path == null) throw const BackupException('no_auto_backup');
    await Share.shareXFiles([XFile(path)]);
  }

  /// Importa una DB desde un archivo seleccionado por el usuario.
  /// Retorna `true` si la importación fue exitosa.
  /// [closeDb] debe cerrar la base de datos antes de sobrescribir.
  Future<bool> importBackup({required Future<void> Function() closeDb}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );
    if (result == null || result.files.isEmpty) return false;

    final pickedPath = result.files.single.path;
    if (pickedPath == null) return false;

    final pickedFile = File(pickedPath);
    if (!await _isValidSqlite(pickedFile)) {
      throw const BackupException('invalid_file');
    }

    // Cerrar DB antes de sobrescribir
    await closeDb();

    final dbPath = await getDbPath();
    await pickedFile.copy(dbPath);

    return true;
  }

  /// Valida que el archivo sea una base de datos SQLite real
  /// comprobando los magic bytes del header.
  Future<bool> _isValidSqlite(File file) async {
    try {
      final raf = await file.open(mode: FileMode.read);
      final Uint8List header = await raf.read(16);
      await raf.close();
      // Los primeros 16 bytes de un archivo SQLite son "SQLite format 3\000"
      const magic = 'SQLite format 3\x00';
      if (header.length < 16) return false;
      return String.fromCharCodes(header) == magic;
    } catch (_) {
      return false;
    }
  }
}

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);

  @override
  String toString() => 'BackupException: $message';
}
