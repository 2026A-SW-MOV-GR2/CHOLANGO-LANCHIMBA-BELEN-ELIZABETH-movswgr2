import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({super.key});

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  // Controladores de texto
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  // Estado
  Post? _currentPost;
  bool _isLoading = false;
  String? _statusMessage;
  Color _statusColor = Colors.green;

  /// Ejecuta la petición GET /posts/{id}
  Future<void> _fetchPost() async {
    final idText = _idController.text.trim();
    if (idText.isEmpty) {
      _showStatus('⚠️ Ingresa un ID válido', Colors.orange);
      return;
    }

    final id = int.tryParse(idText);
    if (id == null || id < 1 || id > 100) {
      _showStatus('⚠️ ID debe ser entre 1 y 100', Colors.orange);
      return;
    }

    // Loading state: deshabilita campos y botones
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    try {
      final post = await ApiService.getPost(id);
      setState(() {
        _currentPost = post;
        _titleController.text = post.title;
        _bodyController.text = post.body;
      });
      _showStatus('✅ Post obtenido correctamente (200 OK)', Colors.green);
    } catch (e) {
      _showStatus('❌ Error: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Ejecuta la petición PUT /posts/{id}
  Future<void> _updatePost() async {
    if (_currentPost == null) {
      _showStatus('⚠️ Primero consulta un post', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Actualiza el objeto con los valores editados
      _currentPost!.title = _titleController.text;
      _currentPost!.body = _bodyController.text;

      final success = await ApiService.updatePost(_currentPost!);

      if (success) {
        _showStatus('✅ Post actualizado correctamente (200 OK)', Colors.green);
      } else {
        _showStatus('❌ Error al actualizar', Colors.red);
      }
    } catch (e) {
      _showStatus('❌ Error: $e', Colors.red);
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
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text(
          'Módulo: Conectividad REST',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección GET
            _SectionHeader(title: 'Consulta (GET)', color: const Color(0xFF00E5CC)),
            const SizedBox(height: 12),

            // Input ID
            _StyledTextField(
              controller: _idController,
              label: 'ID del Post (1-100)',
              keyboardType: TextInputType.number,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),

            // Botón GET
            _ActionButton(
              label: 'GET /posts/{id}',
              icon: Icons.download_outlined,
              color: const Color(0xFF00E5CC),
              onPressed: _isLoading ? null : _fetchPost,
              isLoading: _isLoading,
            ),

            const SizedBox(height: 24),

            // Sección PUT (aparece solo si hay post cargado)
            if (_currentPost != null) ...[
              _SectionHeader(title: 'Actualización (PUT)', color: const Color(0xFF4FC3F7)),
              const SizedBox(height: 12),

              _StyledTextField(
                controller: _titleController,
                label: 'Título',
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),

              _StyledTextField(
                controller: _bodyController,
                label: 'Cuerpo',
                maxLines: 4,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12),

              _ActionButton(
                label: 'PUT /posts/{id}',
                icon: Icons.upload_outlined,
                color: const Color(0xFF4FC3F7),
                onPressed: _isLoading ? null : _updatePost,
                isLoading: _isLoading,
              ),
            ],

            const SizedBox(height: 20),

            // Estado / Mensaje de respuesta
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(color: _statusColor, fontSize: 14),
                ),
              ),

            // Indicador de carga
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF00E5CC)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────
// WIDGETS AUXILIARES
// ──────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            )
        ),
        const SizedBox(width: 10),
        Text(title,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final TextInputType keyboardType;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
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
          borderSide: const BorderSide(color: Color(0xFF00E5CC)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF21262D)),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: onPressed == null ? color.withOpacity(0.4) : color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}