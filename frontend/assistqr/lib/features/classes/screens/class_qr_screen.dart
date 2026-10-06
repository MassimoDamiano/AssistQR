import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../models/teacher_class_summary.dart';
import '../providers/class_provider.dart';

class ClassQrScreen extends StatefulWidget {
  const ClassQrScreen({
    super.key,
    required this.accessToken,
    required this.classSummary,
  });

  final String accessToken;
  final TeacherClassSummary classSummary;

  @override
  State<ClassQrScreen> createState() => _ClassQrScreenState();
}

class _ClassQrScreenState extends State<ClassQrScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    context.read<ClassProvider>().clearQr();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _generateQr() async {
    _timer?.cancel();
    setState(() => _remainingSeconds = 0);

    final provider = context.read<ClassProvider>();
    final success = await provider.generateQr(
      classSessionId: widget.classSummary.classSessionId,
      accessToken: widget.accessToken,
    );

    if (!mounted || !success || provider.qrClass == null) {
      return;
    }

    _updateRemainingTime(provider.qrClass!.expiresAtUtc);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final qr = provider.qrClass;
      if (qr != null) {
        _updateRemainingTime(qr.expiresAtUtc);
      }
    });
  }

  void _updateRemainingTime(DateTime expiresAtUtc) {
    final difference = expiresAtUtc
        .difference(DateTime.now().toUtc())
        .inMilliseconds;
    final seconds = difference <= 0 ? 0 : (difference / 1000).ceil();

    if (!mounted) {
      return;
    }
    setState(() => _remainingSeconds = seconds);
    if (seconds == 0) {
      _timer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassProvider>();
    final qr = provider.qrClass;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR de la clase'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.classSummary.subjectName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El backend generará un código con una duración máxima de 30 segundos.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (provider.isGeneratingQr)
                    const _QrLoading()
                  else if (provider.qrErrorMessage != null)
                    _QrError(message: provider.qrErrorMessage!)
                  else if (qr != null)
                    _QrResult(
                      token: qr.qrToken,
                      remainingSeconds: _remainingSeconds,
                      classStatus: widget.classSummary.status,
                    )
                  else
                    const _QrPlaceholder(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    key: const Key('generateQrButton'),
                    onPressed: provider.isGeneratingQr ? null : _generateQr,
                    icon: Icon(
                      qr == null
                          ? Icons.qr_code_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(qr == null ? 'Generar QR' : 'Generar otro QR'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Generar un QR no abre la clase ni habilita el registro de asistencias.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QrResult extends StatelessWidget {
  const _QrResult({
    required this.token,
    required this.remainingSeconds,
    required this.classStatus,
  });

  final String token;
  final int remainingSeconds;
  final String classStatus;

  @override
  Widget build(BuildContext context) {
    final isActive = remainingSeconds > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          AnimatedOpacity(
            opacity: isActive ? 1 : 0.2,
            duration: const Duration(milliseconds: 250),
            child: QrImageView(
              data: token,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            isActive ? 'Vence en $remainingSeconds s' : 'Código vencido',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isActive ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            classStatus.toUpperCase() == 'SCHEDULED'
                ? 'QR generado. La clase continúa en estado programado.'
                : 'QR generado. Estado de la clase: $classStatus.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _QrLoading extends StatelessWidget {
  const _QrLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 310,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _QrError extends StatelessWidget {
  const _QrError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 60,
            color: AppColors.error,
          ),
          const SizedBox(height: 14),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 88,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 12),
          Text('El código aparecerá acá'),
        ],
      ),
    );
  }
}
