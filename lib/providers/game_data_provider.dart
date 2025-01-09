import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../models/Block.dart';
import '../models/Bomb.dart';
import '../models/Explosion.dart';
import '../models/Item.dart';
import '../models/Player.dart';
import '../models/Wall.dart';

class GameDataProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  late StreamController _streamController;

  List<Player> _players = [];
  List<Block> _blocks = [];

  List<Wall> _walls = [];
  List<Bomb> _bombs = [];
  List<Explosion> _explosions = [];
  List<Item> _items = [];
  int? _timer = 0;
  late String id;

  int mapWidth=1;
  int mapHeight=1;

  GameDataProvider() {
    _streamController = StreamController.broadcast();
  }

  List<Player> get players => _players;
  List<Block> get blocks => _blocks;
  List<Bomb> get bombs => _bombs;
  List<Explosion> get explosions => _explosions;
  List<Item> get items => _items;
  int? get timer => _timer;

  get walls => _walls;

  /// Establish WebSocket connection
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel?.stream.listen((event) {
        //print("received message: $event");
        _streamController.add(event);
        _UpdateData(event);
      }, onDone: () {
        if (_channel?.closeCode == status.policyViolation) {
          // Handle policy violation (e.g., lobby is full)
          onPolicyViolation?.call("Cannot connect to server: ${_channel?.closeReason ?? "Policy violation occurred."}");        
        }
      });
    } catch (e) {
      if (e is WebSocketChannelException) {
        onPolicyViolation?.call("Cannot connect to server: ${e.message}");
      }

      print("Error connecting to WebSocket: $e");
    }
  }

  /// Disconnect WebSocket
  void disconnect() {
    _channel?.sink.close(status.normalClosure);
    _channel = null;
    notifyListeners();
  }

  void Function(String message)? onPolicyViolation;

  /// Listen for incoming messages
  void onMessage(Function(dynamic) callback) {
    _streamController.stream.listen(callback);
  }
  ///Clear the stream
  void clearListeners() {
    _streamController= StreamController.broadcast();
  }

  /// Send message through WebSocket
  void sendMessage(String message) {
    print("Sending message: $message");
    _channel?.sink.add(message);
  }

  /// Update data based on incoming WebSocket messages
  void _UpdateData(String message) {
    try {
      var data = jsonDecode(message);
      if (data["Type"] == "SERVER_LOBBY_UPDATE") {
        _updatePlayers(data["Payload"]);
      }
      else if (data["Type"] == "SERVER_GAME_UPDATE") {
        _updateGameState(data["Payload"]);
      }
    } catch (e) {
      print("Error handling message: $e");
    }
    // print("notifying listeners");
    notifyListeners();
  }

  /// Parse and update players from WebSocket payload
  void _updatePlayers(List<dynamic> payload) {
    _players = payload.map((player) {
      return Player(
        name: player["Name"],
        isReady: player["IsReady"],
        id: player["Id"],
      );
    }).toList();
  }

  bool isConnected() {
    return _channel != null;
  }

  void _updateGameState(Map<String, dynamic> playfield) {
    playfield = playfield["Playfield"];

  // Clear existing lists
  _blocks.clear();
  _walls.clear();
  _players.clear();
  _bombs.clear();
  _explosions.clear();
  _items.clear();

  // Update map dimensions
  mapWidth = playfield["Width"];
  mapHeight = playfield["Height"];


  // Update blocks
  for (var block in playfield["Blocks"]) {
    _blocks.add(Block(
      x: block["X"].toDouble(),
      y: block["Y"].toDouble(),
    ));
  }

  // Update walls
  for (var wall in playfield["Walls"]) {
    _walls.add(Wall(
      x: wall["X"],
      y: wall["Y"],
    ));
  }

  // Update players
  for (var player in playfield["Players"]) {
    var p = Player(
      name: player["Name"],
      isReady: player["IsReady"],
      id: player["Id"],
      x: player["X"].toDouble(),
      y: player["Y"].toDouble(),
      lives: player["Lives"],
    );
    _players.add(p);
  }

  // Update bombs
  for (var bomb in playfield["Bombs"]) {
    _bombs.add(Bomb(
      bomb["OwnerId"], bomb["X"], bomb["Y"], bomb["Fuse"],
    ));
  }

  // Update explosions
  for (var explosion in playfield["Explosions"]) {
    _explosions.add(Explosion(
      explosion["OwnerId"], explosion["X"], explosion["Y"], explosion["Time"],
    ));
  }

  // Update items
  for (var item in playfield["Items"]) {
    _items.add(Item(
      item["X"], item["Y"], item["Type"],
    ));
  }

  // Update timer
  _timer = playfield["Timer"]["SecondsLeft"];

  notifyListeners();
}

  @override
  void dispose() {
    _channel?.sink.close(status.goingAway);
    _streamController.close();
    super.dispose();
  }
}
