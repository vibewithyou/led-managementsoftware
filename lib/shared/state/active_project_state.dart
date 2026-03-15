import 'package:flutter/foundation.dart';
import 'package:led_management_software/domain/entities/project.dart';

/// Global application state for the currently active match/event project.
class ActiveProjectState extends ChangeNotifier {
  ActiveProjectState._();

  static final ActiveProjectState instance = ActiveProjectState._();

  Project? _activeProject;

  Project? get activeProject => _activeProject;

  bool get hasActiveProject => _activeProject != null;

  void setActiveProject(Project? project) {
    _activeProject = project;
    notifyListeners();
  }

  void clear() {
    _activeProject = null;
    notifyListeners();
  }
}
