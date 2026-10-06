import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/models/auth_user.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key, required this.user});

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Registrar asistencia',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Escaneá el código QR mostrado por tu docente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              elevation: 1,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: const CircleAvatar(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.primary,
                  child: Icon(Icons.history_rounded),
                ),
                title: Text(
                  'Historial de asistencias',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text('Consultá tus registros anteriores.'),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
