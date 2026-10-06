import 'package:flutter/foundation.dart';

import '../models/teacher_class_summary.dart';
import '../services/class_service.dart';

class ClassProvider extends ChangeNotifier {
  ClassProvider({ClassService? classService})
    : _classService = classService ?? ClassService();

  final ClassService _classService;

  List<TeacherClassSummary> _classes = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TeacherClassSummary> get classes => List.unmodifiable(_classes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TeacherClassSummary> classesForSubject(int subjectId) {
    return List.unmodifiable(
      _classes.where((classSummary) => classSummary.subjectId == subjectId),
    );
  }

  Future<void> loadClasses(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _classes = await _classService.getClasses(accessToken);
    } catch (error) {
      _classes = const [];
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
