import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/ItemType.dart';
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

  UI.Image? wallImage = null;
  UI.Image? blockImage = null;
  List<UI.Image>? bombImages;
  List<UI.Image>? explosionImages;
  Map<String, UI.Image>? itemImages;
  List<UI.Image>? playerImages;

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
    bombImages = [
      await loadImage('bomb_blue.png'),
      await loadImage('bomb_magenta.png'),
      await loadImage('bomb_green.png'),
      await loadImage('bomb_yellow.png')
    ];
    explosionImages = [
      await loadImage('explosion_blue.png'),
      await loadImage('explosion_magenta.png'),
      await loadImage('explosion_green.png'),
      await loadImage('explosion_yellow.png')
    ];
    itemImages = {
      ItemType.SPEED_UP: await loadImage('powerup_speed.png'),
      ItemType.BOMB_UP: await loadImage('powerup_bombs.png'),
      ItemType.EXPLOSION_RANGE_UP: await loadImage('powerup_explosion.png'),
      ItemType.LIFE_UP: await loadImage('powerup_life.png')
    };
    playerImages = [
      await loadImage('nerd_blue.png'),
      await loadImage('nerd_magenta.png'),
      await loadImage('nerd_green.png'),
      await loadImage('nerd_yellow.png')
    ];
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
                                    builder: (context, constraints){
                                      if (wallImage == null ||
                                          blockImage == null ||
                                          bombImages == null ||
                                          explosionImages == null ||
                                          itemImages == null ||
                                          playerImages == null) {
                                        return CircularProgressIndicator();
                                      }else{
                                      return CustomPaint(
                                        size: Size(constraints.maxHeight,
                                            constraints.maxHeight),
                                        painter: GameCanvasPainter(
                                            gameData, constraints,
                                            wallImage: wallImage,
                                            blockImage: blockImage,
                                            bombImages: bombImages,
                                            explosionImages: explosionImages,
                                            itemImages: itemImages,
                                            playerImages: playerImages),
                                      );
                                    }},

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
        ));
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
   List<UI.Image>? bombImages;
   List<UI.Image>? explosionImages;
   Map<String,UI.Image>? itemImages;
   List<UI.Image>? playerImages;

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
          Rect.fromLTWH(
              0, 0, blockImage!.width.toDouble(), blockImage!.height.toDouble()),
          tileRect.shift(Offset(block.x * tileWidth, block.y * tileWidth)),
          Paint());
    }


    for (var item in gameData.items) {
      canvas.drawImageRect(
          itemImages![item.type]!,
          Rect.fromLTWH(0, 0, itemImages![item.type]!.width.toDouble(),
              itemImages![item.type]!.height.toDouble()),
          tileRect.shift(Offset(item.x * tileWidth, item.y * tileWidth)),
          Paint());
    }

    // Sort players by UUID
    var sortedPlayers = gameData.players..sort((a, b) => a.id.compareTo(b.id));

    for (var i = 0; i < sortedPlayers.length; i++) {
      var player = sortedPlayers[i];
      if (player.x != null && player.y != null) {
        canvas.drawImageRect(
            playerImages![i % playerImages!.length],
            Rect.fromLTWH(
                0,
                0,
                playerImages![i % playerImages!.length].width.toDouble(),
                playerImages![i % playerImages!.length].height.toDouble()),
            tileRect
                .shift(Offset(player.x! * tileWidth, player.y! * tileWidth)),
            Paint());
        for (var explosion in gameData.explosions.where((explosion) =>
            explosion.playerId == player.id)) {
          canvas.drawImageRect(
              explosionImages![i % explosionImages!.length],
              Rect.fromLTWH(
                  0,
                  0,
                  explosionImages![i % explosionImages!.length].width.toDouble(),
                  explosionImages![i % explosionImages!.length].height.toDouble()),
              tileRect
                  .shift(Offset(explosion.x * tileWidth, explosion.y * tileWidth)),
              Paint());
        }

        for (var bomb in gameData.bombs.where((bomb) => bomb.ownerId == player.id)) {
          canvas.drawImageRect(
              bombImages![i % bombImages!.length],
              Rect.fromLTWH(
                  0,
                  0,
                  bombImages![i % bombImages!.length].width.toDouble(),
                  bombImages![i % bombImages!.length].height.toDouble()),
              tileRect
                  .shift(Offset(bomb.x * tileWidth, bomb.y * tileWidth)),
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
