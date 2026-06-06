import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SecretsScreen extends StatefulWidget {
  const SecretsScreen({super.key});

  @override
  State<SecretsScreen> createState() => _SecretsScreenState();
}

class _SecretsScreenState extends State<SecretsScreen> {
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  StorageType _selectedStorage = StorageType.sharedPreferences;
  String? _retrievedValue;
  String? _statusMessage;
  Color _statusColor = Colors.green;
  bool _isLoading = false;

  // Información de cada mecanismo
  final Map<StorageType, Map<String, dynamic>> _storageInfo = {
    StorageType.sharedPreferences: {
      'name': 'SharedPreferences',
      'encryption': 'Sin cifrado (Texto plano)',
      'use': 'Preferencias de UI, estados globales',
      'color': const Color(0xFFFF7043),
      'icon': Icons.lock_open_outlined,
    },
    StorageType.dataStore: {
      'name': 'DataStore (Preferences)',
      'encryption': 'Sin cifrado (Texto plano)',
      'use': 'Acceso asíncrono moderno, evita bloqueos UI',
      'color': const Color(0xFF42A5F5),
      'icon': Icons.storage_outlined,
    },
    StorageType.encryptedSharedPrefs: {
      'name': 'EncryptedSharedPreferences',
      'encryption': 'AES-256 SIV + AES-128 GCM',
      'use': 'Tokens JWT, credenciales, API keys',
      'color': const Color(0xFF66BB6A),
      'icon': Icons.security_outlined,
    },
  };

  Future<void> _saveSecret() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showStatus('⚠️ Ingresa una Llave y un Valor', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await StorageService.saveSecret(
        key: key,
        value: value,
        type: _selectedStorage,
      );
      _showStatus('✅ Secreto guardado en ${_storageInfo[_selectedStorage]!['name']}', Colors.green);
      setState(() => _retrievedValue = null);
    } catch (e) {
      _showStatus('❌ Error al guardar: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _retrieveSecret() async {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      _showStatus('⚠️ Ingresa la Llave a recuperar', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final value = await StorageService.getSecret(
        key: key,
        type: _selectedStorage,
      );

      if (value != null) {
        setState(() => _retrievedValue = value);
        _showStatus('✅ Secreto encontrado en ${_storageInfo[_selectedStorage]!['name']}', Colors.green);
      } else {
        setState(() => _retrievedValue = null);
        // Notificación genérica: no revela si existe o no (por seguridad)
        _showStatus('🔍 No se encontró ningún secreto con esa llave', Colors.orange);
      }
    } catch (e) {
      _showStatus('❌ Error al recuperar: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showStatus(String message, Color color) {
    setState(() {
      _statusMessage = message;
      _statusColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _storageInfo[_selectedStorage]!;
    final selectedColor = info['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Módulo: Almacenamiento Seguro',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Selector de compartimento ──
            const Text(
              'Selecciona el compartimento:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Tarjetas de selección
            ...StorageType.values.map((type) {
              final typeInfo = _storageInfo[type]!;
              final isSelected = _selectedStorage == type;
              final typeColor = typeInfo['color'] as Color;

              return GestureDetector(
                onTap: () => setState(() {
                  _selectedStorage = type;
                  _retrievedValue = null;
                  _statusMessage = null;
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? typeColor.withOpacity(0.15)
                        : const Color(0xFF161B22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? typeColor : const Color(0xFF30363D),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(typeInfo['icon'] as IconData,
                          color: typeColor, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              typeInfo['name'] as String,
                              style: TextStyle(
                                color: isSelected ? typeColor : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              typeInfo['encryption'] as String,
                              style: TextStyle(
                                color: isSelected
                                    ? typeColor.withOpacity(0.8)
                                    : Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: typeColor, size: 20),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // ── Formulario transaccional ──
            Row(
              children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text('Gestión de Secretos',
                    style: TextStyle(
                        color: selectedColor, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),

            // Input Llave
            _buildTextField(
              controller: _keyController,
              label: 'Llave (key)',
              icon: Icons.vpn_key_outlined,
              accentColor: selectedColor,
            ),
            const SizedBox(height: 12),

            // Input Valor (solo para guardar)
            _buildTextField(
              controller: _valueController,
              label: 'Valor (value)',
              icon: Icons.text_fields_outlined,
              accentColor: selectedColor,
            ),
            const SizedBox(height: 16),

            // Botones Guardar y Recuperar
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveSecret,
                    icon: const Icon(Icons.save_outlined, color: Colors.black),
                    label: const Text('Guardar',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _isLoading ? selectedColor.withOpacity(0.4) : selectedColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _retrieveSecret,
                    icon: Icon(Icons.search_outlined, color: selectedColor),
                    label: Text('Recuperar',
                        style: TextStyle(
                            color: selectedColor, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: selectedColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Resultado recuperado ──
            if (_retrievedValue != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: selectedColor.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Valor recuperado:',
                        style: TextStyle(color: selectedColor, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text(
                      _retrievedValue!,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Mensaje de estado ──
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(_statusMessage!,
                    style: TextStyle(color: _statusColor, fontSize: 14)),
              ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              Center(child: CircularProgressIndicator(color: selectedColor)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color accentColor,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: const Color(0xFF161B22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }
}
