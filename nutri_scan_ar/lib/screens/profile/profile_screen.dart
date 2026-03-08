import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/nutrition_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final nutrition = context.watch<NutritionController>();
    final user = auth.user;

    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _confirmLogout(context, auth),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Avatar ────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2ECC71),
                  child: Text(
                    user.name[0].toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                Text(user.email,
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),

          const SizedBox(height: 24),

          // ── Estadísticas ──────────────────────────
          Row(
            children: [
              Expanded(
                  child: _QuickStat(
                      label: 'Comidas hoy',
                      value: '${nutrition.today.meals.length}',
                      color: Colors.blue)),
              const SizedBox(width: 10),
              Expanded(
                  child: _QuickStat(
                      label: 'Calorías hoy',
                      value: '${nutrition.today.calories.round()}',
                      color: const Color(0xFF2ECC71))),
              const SizedBox(width: 10),
              Expanded(
                  child: _QuickStat(
                      label: 'Meta diaria',
                      value: '${nutrition.today.targetCalories.round()}',
                      color: Colors.orange)),
            ],
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // ── Datos del perfil ──────────────────────
          _SectionCard(
            title: 'Información personal',
            icon: Icons.person_outline,
            children: [
              _InfoRow(label: 'Nombre', value: user.name),
              _InfoRow(label: 'Correo', value: user.email),
              _InfoRow(label: 'Plan', value: 'Gratuito'),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 14),

          // ── Objetivos ─────────────────────────────
          _SectionCard(
            title: 'Objetivos nutricionales',
            icon: Icons.track_changes_rounded,
            children: [
              _InfoRow(
                  label: 'Calorías diarias',
                  value: '${nutrition.today.targetCalories.round()} kcal'),
              _InfoRow(label: 'Objetivo', value: 'Mantener peso'),
              _InfoRow(label: 'Actividad', value: 'Moderada'),
            ],
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 14),

          // ── Preferencias ──────────────────────────
          _SectionCard(
            title: 'Preferencias',
            icon: Icons.settings_outlined,
            children: [
              SwitchListTile(
                title: const Text('Notificaciones'),
                value: true,
                activeColor: const Color(0xFF2ECC71),
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Vibración táctil'),
                value: true,
                activeColor: const Color(0xFF2ECC71),
                onChanged: (_) {},
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 14),

          // ── Cerrar sesión ─────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmLogout(context, auth),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro que deseas salir?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (_) => false);
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF2ECC71), size: 20),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}