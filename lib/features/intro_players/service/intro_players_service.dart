import 'package:led_management_software/features/intro_players/model/player_intro_model.dart';

class IntroPlayersService {
  const IntroPlayersService();

  List<PlayerIntroModel> loadLineup() {
    return const [
      PlayerIntroModel(number: 1, name: 'Luca Neumann', position: 'TW', clip: 'intro_01.mp4'),
      PlayerIntroModel(number: 4, name: 'Jonas Pfeiffer', position: 'RL', clip: 'intro_04.mp4'),
      PlayerIntroModel(number: 7, name: 'Timo Berg', position: 'RM', clip: 'intro_07.mp4'),
      PlayerIntroModel(number: 9, name: 'Milan Herzog', position: 'RR', clip: 'intro_09.mp4'),
      PlayerIntroModel(number: 13, name: 'Paul Krüger', position: 'KM', clip: 'intro_13.mp4'),
      PlayerIntroModel(number: 21, name: 'Felix Sommer', position: 'LA', clip: 'intro_21.mp4'),
    ];
  }
}
