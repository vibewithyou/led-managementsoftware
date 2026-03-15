import 'package:led_management_software/features/intro_players/model/player_intro_model.dart';
import 'package:led_management_software/features/intro_players/service/intro_players_service.dart';

class IntroPlayersController {
  IntroPlayersController({IntroPlayersService? service}) : _service = service ?? const IntroPlayersService();

  final IntroPlayersService _service;

  List<PlayerIntroModel> get lineup => _service.loadLineup();
}
