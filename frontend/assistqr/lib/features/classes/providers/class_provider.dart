import 'package:flutter/foundation.dart';

import '../models/class_session.dart';
import '../models/create_class_request.dart';
import '../models/qr_class.dart';
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
  QrClass? _qrClass;
  bool _isGeneratingQr = false;
  String? _qrErrorMessage;

  List<TeacherClassSummary> get classes => List.unmodifiable(_classes);
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get createErrorMessage => _createErrorMessage;
  ClassSession? get createdClass => _createdClass;
  QrClass? get qrClass => _qrClass;
  bool get isGeneratingQr => _isGeneratingQr;
  String? get qrErrorMessage => _qrErrorMessage;

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

  Future<bool> generateQr({
    required int classSessionId,
    required String accessToken,
  }) async {
    _isGeneratingQr = true;
    _qrClass = null;
    _qrErrorMessage = null;
    notifyListeners();

    try {
      _qrClass = await _classService.generateQr(
        classSessionId: classSessionId,
        accessToken: accessToken,
      );
      return true;
    } catch (error) {
      _qrErrorMessage = _cleanError(error);
      return false;
    } finally {
      _isGeneratingQr = false;
      notifyListeners();
    }
  }

  void clearQr() {
    _qrClass = null;
    _qrErrorMessage = null;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
