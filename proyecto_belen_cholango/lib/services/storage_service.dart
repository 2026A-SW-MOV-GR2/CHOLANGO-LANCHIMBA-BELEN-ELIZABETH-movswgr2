import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Enum para seleccionar el compartimento de almacenamiento
enum StorageType {
  sharedPreferences,     // Texto plano, síncrono
  dataStore,             // Texto plano, asíncrono (simulado con SharedPrefs async)
  encryptedSharedPrefs,  // AES-256 cifrado automático
}

class StorageService {
  // Instancia del almacenamiento cifrado
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true, // ✅ Equivalente a EncryptedSharedPreferences de Android
    ),
  );

  /// GUARDAR un secreto según el compartimento elegido
  static Future<void> saveSecret({
    required String key,
    required String value,
    required StorageType type,
  }) async {
    switch (type) {
      case StorageType.sharedPreferences:
      // SharedPreferences: clave-valor plano, XML en disco
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
        break;

      case StorageType.dataStore:
      // DataStore equivalente: también usa SharedPreferences pero de forma asíncrona
      // En Android nativo sería Jetpack DataStore con Kotlin Flows
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('ds_$key', value); // prefijo "ds_" para diferenciar
        break;

      case StorageType.encryptedSharedPrefs:
      // EncryptedSharedPreferences: cifra AES-256 SIV + AES-128 GCM automáticamente
        await _secureStorage.write(key: key, value: value);
        break;
    }
  }

  /// RECUPERAR un secreto según el compartimento elegido
  static Future<String?> getSecret({
    required String key,
    required StorageType type,
  }) async {
    switch (type) {
      case StorageType.sharedPreferences:
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);

      case StorageType.dataStore:
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString('ds_$key');

      case StorageType.encryptedSharedPrefs:
        return await _secureStorage.read(key: key);
    }
  }
}