import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../subjects/models/subject.dart';
import '../models/create_class_request.dart';
import '../providers/class_provider.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({
    super.key,
    required this.accessToken,
    required this.subject,
  });

  final String accessToken;
  final Subject subject;

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _radiusController = TextEditingController(text: '50');

  DateTime? _sessionDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  Position? _position;
  String? _formError;
  String? _locationError;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<ClassProvider>().clearCreateError();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _sessionDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (selected != null) {
      setState(() {
        _sessionDate = selected;
        _formError = null;
      });
    }
  }

  Future<void> _selectTime({required bool isStart}) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? TimeOfDay.now())
          : (_endTime ?? _suggestedEndTime()),
    );

    if (selected != null) {
      setState(() {
        if (isStart) {
          _startTime = selected;
        } else {
          _endTime = selected;
        }
        _formError = null;
      });
    }
  }

  TimeOfDay _suggestedEndTime() {
    final start = _startTime ?? TimeOfDay.now();
    final minutes = start.hour * 60 + start.minute + 60;
    return TimeOfDay(hour: (minutes ~/ 60) % 24, minute: minutes % 60);
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Activá la ubicación del dispositivo para continuar.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception('Necesitamos permiso para obtener la ubicación.');
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'El permiso de ubicación está bloqueado. Habilitalo desde Ajustes.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _position = position;
        _formError = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _locationError = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final radius = int.tryParse(_radiusController.text.trim());

    if (_sessionDate == null || _startTime == null || _endTime == null) {
      setState(() => _formError = 'Completá la fecha y ambos horarios.');
      return;
    }
    if (_toMinutes(_endTime!) <= _toMinutes(_startTime!)) {
      setState(() {
        _formError = 'La hora de fin debe ser posterior a la de inicio.';
      });
      return;
    }
    if (_position == null) {
      setState(() {
        _formError = 'Obtené y confirmá la ubicación de la clase.';
      });
      return;
    }
    if (radius == null || radius <= 0) {
      setState(() => _formError = 'Ingresá un radio mayor que cero.');
      return;
    }

    setState(() => _formError = null);
    final request = CreateClassRequest(
      subjectId: widget.subject.id,
      sessionDate: _sessionDate!,
      startTime: (hour: _startTime!.hour, minute: _startTime!.minute),
      endTime: (hour: _endTime!.hour, minute: _endTime!.minute),
      latitude: _position!.latitude,
      longitude: _position!.longitude,
      allowedRadiusMeters: radius,
    );

    final provider = context.read<ClassProvider>();
    final success = await provider.createClass(request, widget.accessToken);
    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.createErrorMessage ?? 'No se pudo crear la clase.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  int _toMinutes(TimeOfDay value) => value.hour * 60 + value.minute;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClassProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva clase'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.subject.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Definí cuándo y dónde se realizará la clase.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  _PickerField(
                    key: const Key('classDateField'),
                    icon: Icons.calendar_today_outlined,
                    label: 'Fecha',
                    value: _sessionDate == null
                        ? 'Seleccionar fecha'
                        : _formatDate(_sessionDate!),
                    onTap: provider.isCreating ? null : _selectDate,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerField(
                          key: const Key('classStartTimeField'),
                          icon: Icons.schedule_outlined,
                          label: 'Inicio',
                          value: _startTime?.format(context) ?? 'Elegir',
                          onTap: provider.isCreating
                              ? null
                              : () => _selectTime(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerField(
                          key: const Key('classEndTimeField'),
                          icon: Icons.schedule_outlined,
                          label: 'Fin',
                          value: _endTime?.format(context) ?? 'Elegir',
                          onTap: provider.isCreating
                              ? null
                              : () => _selectTime(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _LocationCard(
                    position: _position,
                    isLoading: _isGettingLocation,
                    errorMessage: _locationError,
                    onGetLocation: provider.isCreating
                        ? null
                        : _getCurrentLocation,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    key: const Key('allowedRadiusField'),
                    controller: _radiusController,
                    enabled: !provider.isCreating,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Radio permitido (metros)',
                      prefixIcon: Icon(Icons.radar_outlined),
                      helperText:
                          'Distancia máxima desde la ubicación de la clase.',
                    ),
                  ),
                  if (_formError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _formError!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    key: const Key('createClassButton'),
                    onPressed: provider.isCreating ? null : _submit,
                    icon: provider.isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.add_rounded),
                    label: Text(
                      provider.isCreating ? 'Creando...' : 'Crear clase',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        child: Text(value),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.position,
    required this.isLoading,
    required this.errorMessage,
    required this.onGetLocation,
  });

  final Position? position;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onGetLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Ubicación de la clase',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (position != null)
                const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 12),
          if (position != null) ...[
            Text('Latitud: ${position!.latitude.toStringAsFixed(6)}'),
            const SizedBox(height: 4),
            Text('Longitud: ${position!.longitude.toStringAsFixed(6)}'),
          ] else
            Text(
              'Usaremos la ubicación actual del celular. Podrás confirmarla antes de crear la clase.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          if (errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(errorMessage!, style: const TextStyle(color: AppColors.error)),
          ],
          const SizedBox(height: 14),
          OutlinedButton.icon(
            key: const Key('getCurrentLocationButton'),
            onPressed: isLoading ? null : onGetLocation,
            icon: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(
              isLoading
                  ? 'Obteniendo ubicación...'
                  : position == null
                  ? 'Usar ubicación actual'
                  : 'Actualizar ubicación',
            ),
          ),
        ],
      ),
    );
  }
}
