import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../subjects/models/subject.dart';
import '../models/teacher_class_summary.dart';
import '../providers/class_provider.dart';

class TeacherClassesScreen extends StatefulWidget {
  const TeacherClassesScreen({
    super.key,
    required this.accessToken,
    required this.subject,
  });

  final String accessToken;
  final Subject subject;

  @override
  State<TeacherClassesScreen> createState() => _TeacherClassesScreenState();
}

class _TeacherClassesScreenState extends State<TeacherClassesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ClassProvider>().loadClasses(widget.accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassProvider>();
    final classes = provider.classesForSubject(widget.subject.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: _ClassesContent(
          accessToken: widget.accessToken,
          provider: provider,
          classes: classes,
        ),
      ),
    );
  }
}

class _ClassesContent extends StatelessWidget {
  const _ClassesContent({
    required this.accessToken,
    required this.provider,
    required this.classes,
  });

  final String accessToken;
  final ClassProvider provider;
  final List<TeacherClassSummary> classes;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null) {
      return _MessageState(
        icon: Icons.error_outline_rounded,
        message: provider.errorMessage!,
        actionLabel: 'Reintentar',
        onAction: () => provider.loadClasses(accessToken),
      );
    }

    if (classes.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.loadClasses(accessToken),
        child: const _EmptyClassesState(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadClasses(accessToken),
      child: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: classes.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '${classes.length} ${classes.length == 1 ? 'clase programada' : 'clases programadas'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          }

          return _ClassCard(classSummary: classes[index - 1]);
        },
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classSummary});

  final TeacherClassSummary classSummary;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(classSummary.sessionDate),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                _StatusLabel(status: classSummary.status),
              ],
            ),
            const SizedBox(height: 14),
            _ClassDetail(
              icon: Icons.schedule_outlined,
              text:
                  '${_formatTime(classSummary.startTime)} a ${_formatTime(classSummary.endTime)}',
            ),
            const SizedBox(height: 8),
            _ClassDetail(
              icon: Icons.groups_outlined,
              text:
                  '${classSummary.attendanceCount} ${classSummary.attendanceCount == 1 ? 'asistencia registrada' : 'asistencias registradas'}',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String _formatTime(String value) {
    return value.length >= 5 ? value.substring(0, 5) : value;
  }
}

class _ClassDetail extends StatelessWidget {
  const _ClassDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toUpperCase();
    final (label, color) = switch (normalizedStatus) {
      'OPEN' => ('Abierta', AppColors.success),
      'CLOSED' => ('Cerrada', AppColors.textSecondary),
      'SCHEDULED' => ('Programada', AppColors.warning),
      _ => (status, AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyClassesState extends StatelessWidget {
  const _EmptyClassesState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.event_busy_outlined,
          size: 72,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 20),
        Text(
          'Todavía no hay clases programadas',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'En la próxima etapa vas a poder crear una clase para esta materia.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 68, color: AppColors.error),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
