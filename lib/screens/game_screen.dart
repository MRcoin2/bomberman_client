import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_data_provider.dart';
import '../models/Player.dart';
import 'dart:math' as math;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as UI;

import 'package:flutter/services.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _onMessageCalled = false;
  final FocusNode _focusNode = FocusNode();

  late UI.Image wallImage;
  late UI.Image blockImage;
  late UI.Image bombImage;
  late UI.Image explosionImage;
  late UI.Image itemImage;
  late UI.Image playerImage;

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
    bombImage = await loadImage('bomb_blue.png');
    explosionImage = await loadImage('explosion_blue.png');
    itemImage = await loadImage('speed_powerup.png');
    playerImage = await loadImage('nerd_blue.png');
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Game Over'),
              actions: [
                TextButton(
                  onPressed: () {
                    Provider.of<GameDataProvider>(context, listen: false)
                        .disconnect();
                    Navigator.of(context).popAndPushNamed("/");
                  },
                  child: const Text('Return to main menu'),
                ),
              ],
            ),
          );
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Consumer<GameDataProvider>(
                            builder: (context, gameData, child) {
                              return Text(
                                  "${(gameData.timer! / 60).floor().toString().padLeft(2, '0')}:${(gameData.timer! % 60).toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30));
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
                                      builder: (context, constraints) =>
                                          CustomPaint(
                                        size: Size(constraints.maxHeight,
                                            constraints.maxHeight),
                                        painter: GameCanvasPainter(
                                            gameData,
                                            constraints,
                                            wallImage: wallImage,
                                            blockImage: blockImage,
                                            bombImage: bombImage,
                                            explosionImage: explosionImage,
                                            itemImage: itemImage,
                                            playerImage: playerImage),
                                      ),
                                    );
                                  },
                                ),
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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text("Player",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30)),
                              trailing: Text("Score",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30)),
                            ),
                          ),
                          ...gameData.players.map((player) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(player.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                subtitle: Row(
                                  children: [
                                    for (var i = 0; i < (player.lives ?? 0); i++)
                                      Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 16,
                                      ),
                                  ],
                                ),
                                trailing: Text(player.score.toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30)),
                              ),
                            );
                          })
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        );
}
}
Future<UI.Image> loadImage(String imageName) async {
  final data = await rootBundle.load('assets/pngs/$imageName');
  return decodeImageFromList(data.buffer.asUint8List());
}
class GameCanvasPainter extends CustomPainter {
  late GameDataProvider gameData;
  late BoxConstraints constraints;

  late double tileWidth;

  late UI.Image wallImage;
  late UI.Image blockImage;
  late UI.Image bombImage;
  late UI.Image explosionImage;
  late UI.Image itemImage;
  late UI.Image playerImage;

  GameCanvasPainter(this.gameData, constraints,
      {required this.wallImage,
      required this.blockImage,
      required this.bombImage,
      required this.explosionImage,
      required this.itemImage,
      required this.playerImage}) {
    tileWidth = math.min(constraints.maxWidth / gameData.mapWidth,
        constraints.maxHeight / gameData.mapHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect tileRect = Rect.fromLTWH(0, 0, tileWidth, tileWidth);

    for (var wall in gameData.walls) {
      canvas.drawImageRect(
          wallImage,
          Rect.fromLTWH(0, 0, wallImage.width.toDouble(), wallImage.height.toDouble()),
          tileRect.shift(Offset(wall.x * tileWidth, wall.y * tileWidth)),
          Paint());
    }

    for (var block in gameData.blocks) {
      canvas.drawImageRect(
          blockImage,
          Rect.fromLTWH(0, 0, blockImage.width.toDouble(), blockImage.height.toDouble()),
          tileRect.shift(Offset(block.x * tileWidth, block.y * tileWidth)),
          Paint());
    }

    for (var bomb in gameData.bombs) {
      canvas.drawImageRect(
          bombImage,
          Rect.fromLTWH(0, 0, bombImage.width.toDouble(), bombImage.height.toDouble()),
          tileRect.shift(Offset(bomb.x * tileWidth, bomb.y * tileWidth)),
          Paint());
    }

    for (var explosion in gameData.explosions) {
      canvas.drawImageRect(
          explosionImage,
          Rect.fromLTWH(0, 0, explosionImage.width.toDouble(), explosionImage.height.toDouble()),
          tileRect.shift(Offset(explosion.x * tileWidth, explosion.y * tileWidth)),
          Paint());
    }

    for (var item in gameData.items) {
      canvas.drawImageRect(
          itemImage,
          Rect.fromLTWH(0, 0, itemImage.width.toDouble(), itemImage.height.toDouble()),
          tileRect.shift(Offset(item.x * tileWidth, item.y * tileWidth)),
          Paint());
    }

    for (var player in gameData.players) {
      if (player.x != null && player.y != null) {
        canvas.drawImageRect(
            playerImage,
            Rect.fromLTWH(0, 0, playerImage.width.toDouble(), playerImage.height.toDouble()),
            tileRect.shift(Offset(player.x! * tileWidth, player.y! * tileWidth)),
            Paint());
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}