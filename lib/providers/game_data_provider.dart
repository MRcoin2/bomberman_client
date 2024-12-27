import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/Player.dart';
import '../widgets/player_list.dart';

class GameDataProvider with ChangeNotifier {
  List<Player> _players = [];

  late String id;

  List<Player> get players => _players;

  void updateData(String message) {
    //TODO: Parse json data and update all data
    var data = jsonDecode(message);
    if (data["Type"] == "SERVER_LOBBY_UPDATE") {
      _players = [];
      for (var player in data["Payload"]) {
        _players.add(Player(
            name: player["Name"],
            isReady: player["IsReady"],
            id: player["Id"]));
      }
    }
    notifyListeners();
  }
}
