import 'package:flutter/material.dart';
import 'rest_screen.dart';
import 'secrets_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        title: const Text(
          'Flutter',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            const Text(
              'Proyecto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF00E5CC),
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Red y Seguridad',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 48),

            // Botón Módulo 1
            _ModuleCard(
              icon: Icons.cloud_outlined,
              title: 'Módulo',
              subtitle: 'Conectividad REST',
              description: 'GET y PUT con JSONPlaceholder',
              color: const Color(0xFF00E5CC),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RestScreen()),
              ),
            ),
            const SizedBox(height: 16),

            // Botón Módulo 2
            _ModuleCard(
              icon: Icons.lock_outline,
              title: 'Módulo',
              subtitle: 'Almacenamiento Seguro',
              description: 'SharedPrefs + DataStore + EncryptedSharedPrefs',
              color: const Color(0xFF4FC3F7),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecretsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title: $subtitle',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}