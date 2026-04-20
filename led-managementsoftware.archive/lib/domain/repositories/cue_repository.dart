import 'package:led_management_software/domain/entities/cue.dart';

abstract class CueRepository {
  Future<List<Cue>> getAllCues();

  Future<Cue?> getCueById(String id);

  Future<List<Cue>> getFavoriteCues();

  Future<void> saveCue(Cue cue);

  Future<void> deleteCue(String id);
}
