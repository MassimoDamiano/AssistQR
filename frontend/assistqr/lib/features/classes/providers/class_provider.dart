import 'package:flutter/foundation.dart';

import '../models/class_session.dart';
import '../models/create_class_request.dart';
import '../models/teacher_class_summary.dart';
import '../services/class_service.dart';

class ClassProvider extends ChangeNotifier {
  ClassProvider({ClassService? classService})
    : _classService = classService ?? ClassService();

  final ClassService _classService;

  List<TeacherClassSummary> _classes = const [];
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _createErrorMessage;
  ClassSession? _createdClass;

  List<TeacherClassSummary> get classes => List.unmodifiable(_classes);
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get createErrorMessage => _createErrorMessage;
  ClassSession? get createdClass => _createdClass;

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

  Future<bool> createClass(
    CreateClassRequest request,
    String accessToken,
  ) async {
    _isCreating = true;
    _createErrorMessage = null;
    _createdClass = null;
    notifyListeners();

    try {
      _createdClass = await _classService.createClass(request, accessToken);
      return true;
    } catch (error) {
      _createErrorMessage = _cleanError(error);
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  void clearCreateError() {
    _createErrorMessage = null;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
