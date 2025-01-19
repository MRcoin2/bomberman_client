import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ItemType.dart';
import '../providers/game_data_provider.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:ui' as UI;

import '../widgets/game_player_list.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _onMessageCalled = false;
  final FocusNode _focusNode = FocusNode();

  UI.Image? wallImage = null;
  UI.Image? blockImage = null;
  Map<Color, UI.Image>? bombImages;
  Map<Color, UI.Image>? explosionImages;
  Map<String, UI.Image>? itemImages;
  Map<Color, UI.Image>? playerImages;

  bool _isGameOver = false;
  bool _isDraw = false;
  String _outcome = '';
  String? _winner = '';

  void _handleKeyEvent(BuildContext context, KeyEvent event) {
    final gameData = Provider.of<GameDataProvider>(context, listen: false);
    print(event.logicalKey.keyLabel);
    switch (event.logicalKey.keyLabel) {
      case "Arrow Up": // Arrow up
        print('Arrow up');
        //send to server
        gameData.sendMessage(
            '{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"up", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
        break;
      case "Arrow Down": // Arrow down
        print('Arrow down');
        gameData.sendMessage(
            '{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"down", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
        break;
      case "Arrow Left": // Arrow left
        print('Arrow left');
        gameData.sendMessage(
            '{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"left", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
        break;
      case "Arrow Right": // Arrow right
        print('Arrow right');
        gameData.sendMessage(
            '{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"right", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
        break;
      case " ": // Space
        print('Space');
        gameData.sendMessage('{"Type":"CLIENT_GAME_BOMB","Payload":""}');
        break;
    }
  }

  void _loadImages() async {
    wallImage = await loadImage('wall_dark.png');
    blockImage = await loadImage('block.png');

    bombImages = {
      Colors.blue: await loadImage('bomb_blue.png'),
      Colors.purple: await loadImage('bomb_magenta.png'),
      Colors.green: await loadImage('bomb_green.png'),
      Colors.yellow: await loadImage('bomb_yellow.png')
    };

    explosionImages = {
      Colors.blue: await loadImage('explosion_blue.png'),
      Colors.purple: await loadImage('explosion_magenta.png'),
      Colors.green: await loadImage('explosion_green.png'),
      Colors.yellow: await loadImage('explosion_yellow.png')
    };

    itemImages = {
      ItemType.SPEED_UP: await loadImage('powerup_speed.png'),
      ItemType.BOMB_UP: await loadImage('powerup_bombs.png'),
      ItemType.EXPLOSION_RANGE_UP: await loadImage('powerup_explosion.png'),
      ItemType.LIFE_UP: await loadImage('powerup_life.png')
    };

    playerImages = {
      Colors.blue: await loadImage('nerd_blue.png'),
      Colors.purple: await loadImage('nerd_magenta.png'),
      Colors.green: await loadImage('nerd_green.png'),
      Colors.yellow: await loadImage('nerd_yellow.png')
    };
  }

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_onMessageCalled) {
      _onMessageCalled = true;
      Provider.of<GameDataProvider>(context).onMessage((message) {
        //decode the json message
        var data = jsonDecode(message);
        if (data['Type'] == 'SERVER_GAME_OVER') {
          setState(() {
            _isGameOver = true;
            _outcome = data['Payload']['Outcome'];
            _winner = data['Payload']['Winner'];
            _isDraw = data['Payload']['Draw'];
          });

          if (_outcome == "TIME_OUT") {
            _outcome = "Time out!";
          } else if (_outcome == "ALL_ELIMINATED") {
            _outcome = "There is only one player alive!";
          }

          if (_isDraw) {
            _winner = "It's a draw!";
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        focusNode: FocusNode(skipTraversal: true),
        onPressed: () {
          Provider.of<GameDataProvider>(context, listen: false).disconnect();
          Navigator.of(context).popAndPushNamed('/');
        },
        child: const Icon(Icons.exit_to_app),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Consumer<GameDataProvider>(
                            builder: (context, gameData, child) {
                              return Text(
                                _isGameOver
                                    ? "Game Over!"
                                    : "${(gameData.timer! / 60).floor().toString().padLeft(2, '0')}:${(gameData.timer! % 60).toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 30,
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: DefaultTextEditingShortcuts(
                            child: KeyboardListener(
                              autofocus: true,
                              onKeyEvent: (event) =>
                                  _handleKeyEvent(context, event),
                              focusNode: _focusNode,
                              child: Center(
                                child: Consumer<GameDataProvider>(
                                  builder: (context, gameData, child) {
                                    return LayoutBuilder(
                                      builder: (context, constraints) {
                                        if (wallImage == null ||
                                            blockImage == null ||
                                            bombImages == null ||
                                            explosionImages == null ||
                                            itemImages == null ||
                                            playerImages == null) {
                                          return CircularProgressIndicator();
                                        } else {
                                          return CustomPaint(
                                            size: Size(constraints.maxHeight,
                                                constraints.maxHeight),
                                            painter: GameCanvasPainter(
                                                gameData, constraints,
                                                wallImage: wallImage,
                                                blockImage: blockImage,
                                                bombImages: bombImages,
                                                explosionImages:
                                                    explosionImages,
                                                itemImages: itemImages,
                                                playerImages: playerImages),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_isGameOver)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.8),
                          child: Center(
                            child: AlertDialog(
                              title: const Text('Game Over!'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_outcome,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),SizedBox(height: 10),
                                  Text(_isDraw?"Draw":"$_winner WINS!",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 24)),
                                ],
                              ),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Provider.of<GameDataProvider>(context,
                                            listen: false)
                                        .disconnect();
                                    Navigator.of(context).popAndPushNamed("/");
                                  },
                                  child: const Text('Return to main menu'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Card(
              child: Consumer<GameDataProvider>(
                builder: (context, gameData, child) {
                  return GamePlayerList(gameData: gameData);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<UI.Image> loadImage(String imageName) async {
  final data = await rootBundle.load('assets/pngs/$imageName');
  return decodeImageFromList(data.buffer.asUint8List());
}

class GameCanvasPainter extends CustomPainter {
  final GameDataProvider gameData;
  final BoxConstraints constraints;

  late double tileWidth;

  UI.Image? wallImage;
  UI.Image? blockImage;
  Map<Color, UI.Image>? bombImages;
  Map<Color, UI.Image>? explosionImages;
  Map<String, UI.Image>? itemImages;
  Map<Color, UI.Image>? playerImages;

  GameCanvasPainter(this.gameData, this.constraints,
      {required this.wallImage,
      required this.blockImage,
      required this.bombImages,
      required this.explosionImages,
      required this.itemImages,
      required this.playerImages}) {
    tileWidth = math.min(constraints.maxWidth / gameData.mapWidth,
        constraints.maxHeight / gameData.mapHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect tileRect = Rect.fromLTWH(0, 0, tileWidth, tileWidth);

    for (var item in gameData.items) {
      canvas.drawImageRect(
          itemImages![item.type]!,
          Rect.fromLTWH(0, 0, itemImages![item.type]!.width.toDouble(),
              itemImages![item.type]!.height.toDouble()),
          tileRect.shift(Offset(item.x * tileWidth, item.y * tileWidth)),
          Paint());
    }
    for (var wall in gameData.walls) {
      canvas.drawImageRect(
          wallImage!,
          Rect.fromLTWH(
              0, 0, wallImage!.width.toDouble(), wallImage!.height.toDouble()),
          tileRect.shift(Offset(wall.x * tileWidth, wall.y * tileWidth)),
          Paint());
    }

    for (var block in gameData.blocks) {
      canvas.drawImageRect(
          blockImage!,
          Rect.fromLTWH(0, 0, blockImage!.width.toDouble(),
              blockImage!.height.toDouble()),
          tileRect.shift(Offset(block.x * tileWidth, block.y * tileWidth)),
          Paint());
    }

    for (var player in gameData.players) {
      if (player.x != null && player.y != null) {
        if (player.lives != 0) {
          if (player.invincibilityTicks % 3 != 1) {
            canvas.drawImageRect(
                playerImages![player.playerColor]!,
                Rect.fromLTWH(
                    0,
                    0,
                    playerImages![player.playerColor]!.width.toDouble(),
                    playerImages![player.playerColor]!.height.toDouble()),
                tileRect.shift(
                    Offset(player.x! * tileWidth, player.y! * tileWidth)),
                Paint());
          }
        }
        for (var explosion in gameData.explosions
            .where((explosion) => explosion.playerId == player.id)) {
          canvas.drawImageRect(
              explosionImages![player.playerColor]!,
              Rect.fromLTWH(
                  0,
                  0,
                  explosionImages![player.playerColor]!.width.toDouble(),
                  explosionImages![player.playerColor]!.height.toDouble()),
              tileRect.shift(
                  Offset(explosion.x * tileWidth, explosion.y * tileWidth)),
              Paint());
        }

        for (var bomb
            in gameData.bombs.where((bomb) => bomb.ownerId == player.id)) {
          canvas.drawImageRect(
              bombImages![player.playerColor]!,
              Rect.fromLTWH(
                  0,
                  0,
                  bombImages![player.playerColor]!.width.toDouble(),
                  bombImages![player.playerColor]!.height.toDouble()),
              tileRect.shift(Offset(bomb.x * tileWidth, bomb.y * tileWidth)),
              Paint());
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
