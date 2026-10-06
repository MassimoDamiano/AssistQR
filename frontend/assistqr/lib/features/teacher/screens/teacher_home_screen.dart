import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';
import '../../auth/providers/auth_provider.dart';
import '../../attendance/screens/attendance_placeholder_screen.dart';
import '../../subjects/screens/teacher_subjects_screen.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key, required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '¡Hola, ${user.firstName}!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 28),
            _TeacherActionCard(
              icon: Icons.menu_book_outlined,
              title: 'Mis materias',
              description: 'Consultá y administrá tus materias.',
              onTap: () {
                final accessToken = context
                    .read<AuthProvider>()
                    .loginResponse
                    ?.accessToken;

                if (accessToken == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay una sesión activa.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TeacherSubjectsScreen(accessToken: accessToken),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _TeacherActionCard(
              icon: Icons.groups_outlined,
              title: 'Asistencias',
              description: 'Disponible cuando se integre el flujo de apertura.',
              isPending: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AttendancePlaceholderScreen(),
                ),
              ),
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
    this.onTap,
    this.isPending = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      child: ListTile(
        onTap: onTap,
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
        trailing: isPending
            ? const Text(
                'Próximamente',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              )
            : const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
