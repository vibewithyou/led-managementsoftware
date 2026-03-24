import 'package:led_management_software/domain/entities/lineup_entry.dart';
import 'package:led_management_software/domain/entities/media_asset.dart';

class IntroLineupItemModel {
  const IntroLineupItemModel({
    required this.entry,
    required this.mediaAsset,
  });

  final LineupEntry entry;
  final MediaAsset? mediaAsset;

  bool get hasClip => mediaAsset != null;

  String get clipTitle => mediaAsset?.title ?? 'Clip nicht gefunden';

  String get categoryLabel => mediaAsset?.category.name ?? '-';
}
