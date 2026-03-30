import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gestiona el almacenamiento seguro de credenciales del usuario.
/// Las credenciales se cifran con el Keystore (Android) / Keychain (iOS).
class AuthService {
  static const _keyUsername = 'auth_username';
  static const _keyPassword = 'auth_password';
  static const _keyIsSetup = 'auth_is_setup';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// ¿Ya tiene credenciales guardadas?
  Future<bool> isSetup() async {
    final val = await _storage.read(key: _keyIsSetup);
    return val == 'true';
  }

  /// Guarda usuario y contraseña por primera vez (o los sobreescribe).
  Future<void> saveCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
    await _storage.write(key: _keyIsSetup, value: 'true');
  }

  /// Valida que las credenciales introducidas coincidan con las guardadas.
  Future<bool> validateCredentials(String username, String password) async {
    final storedUser = await _storage.read(key: _keyUsername);
    final storedPass = await _storage.read(key: _keyPassword);
    return storedUser == username && storedPass == password;
  }

  /// Devuelve las credenciales guardadas (para recuperación).
  Future<({String? username, String? password})> getCredentials() async {
    final username = await _storage.read(key: _keyUsername);
    final password = await _storage.read(key: _keyPassword);
    return (username: username, password: password);
  }
}
