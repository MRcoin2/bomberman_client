import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/Player.dart';
import '../widgets/player_list.dart';

class GameDataProvider with ChangeNotifier {
  List<Player> _players = [];

  List<Player> get players => _players;

  void updateData(String message) {
    //TODO: Parse json data and update players list
    var data = jsonDecode(message);
    if (data["Type"] == "GAME_STATE") {
      _players = [];
      for (var player in data["Payload"]["Players"]) {
        _players.add(Player(
            name: player["Name"],
            isReady: player["IsReady"],
            id: player["Id"],
            lives: player["Lives"]));
      }
    }
    notifyListeners();
  }
}
