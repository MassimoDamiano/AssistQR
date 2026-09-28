import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio docente'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('¡Hola!', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 4),
            Text(user.email, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 28),
            const _TeacherActionCard(
              icon: Icons.menu_book_outlined,
              title: 'Mis materias',
              description: 'Consultá y administrá tus materias.',
            ),
            const SizedBox(height: 16),
            const _TeacherActionCard(
              icon: Icons.qr_code_rounded,
              title: 'Generar QR',
              description: 'Abrí una clase y generá su código temporal.',
            ),
            const SizedBox(height: 16),
            const _TeacherActionCard(
              icon: Icons.groups_outlined,
              title: 'Asistencias',
              description: 'Revisá los estudiantes presentes por clase.',
            ),
          ],
        ),
      ),
    );
  }
}

class _TeacherActionCard extends StatelessWidget {
  const _TeacherActionCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          foregroundColor: AppColors.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(description),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
