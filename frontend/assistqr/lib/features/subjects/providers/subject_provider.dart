import 'package:flutter/foundation.dart';

import '../models/subject.dart';
import '../services/subject_service.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectService _subjectService = SubjectService();

  List<Subject> _subjects = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Subject> get subjects => List.unmodifiable(_subjects);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadSubjects(String accessToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _subjects = await _subjectService.getSubjects(accessToken);
    } catch (error) {
      _subjects = const [];
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
