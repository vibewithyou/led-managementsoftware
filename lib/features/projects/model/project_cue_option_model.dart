import 'package:led_management_software/domain/enums/cue_type.dart';
import 'package:led_management_software/domain/enums/media_category.dart';

class ProjectCueOptionModel {
  const ProjectCueOptionModel({
    required this.id,
    required this.title,
    required this.category,
    required this.cueType,
    required this.isLocked,
  });

  final String id;
  final String title;
  final MediaCategory category;
  final CueType cueType;
  final bool isLocked;

  String get categoryLabel => category.name;

  String get cueTypeLabel => cueType.name;

  String get lockStatusLabel => isLocked ? 'Gesperrt' : 'Nicht gesperrt';
}
