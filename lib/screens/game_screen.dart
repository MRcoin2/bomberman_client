import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_data_provider.dart';
import '../models/Player.dart';
import 'dart:math' as math;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _onMessageCalled = false;
  final FocusNode _focusNode = FocusNode();

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

  @override
  void initState() {
    super.initState();
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
                    Provider.of<GameDataProvider>(context, listen: false).disconnect();
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
      //go to main screen
      floatingActionButton: FloatingActionButton(
        focusNode: FocusNode(skipTraversal: true),
        onPressed: () {
          //disconnect from server
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
                                    painter: GameCanvasPainter(gameData, constraints),
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
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Row(
                              children: [
                                for (var i = 0; i < (player.lives??0); i++)
                                  Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                              ],
                            ),
                            trailing: Text("${2137}",
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
      ),
    );
  }
}


class GameCanvasPainter extends CustomPainter {
  final GameDataProvider gameData;
  final BoxConstraints constraints;

  late double tileWidth;
  GameCanvasPainter(this.gameData, this.constraints){
    tileWidth = math.min(constraints.maxWidth / gameData.mapWidth, constraints.maxHeight / gameData.mapHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final wallPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final blockPaint = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    final bombPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final explosionPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;

    final itemPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final playerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Draw the playfield
    for (var wall in gameData.walls) {
      canvas.drawRect(
        Rect.fromLTWH(
            wall.x * tileWidth, wall.y * tileWidth, tileWidth, tileWidth),
        wallPaint,
      );
    }

    for (var block in gameData.blocks) {
      canvas.drawRect(
        Rect.fromLTWH(
            block.x * tileWidth, block.y * tileWidth, tileWidth, tileWidth),
        blockPaint,
      );
    }

    for (var bomb in gameData.bombs) {
      canvas.drawCircle(
        Offset(bomb.x * tileWidth + tileWidth / 2,
            bomb.y * tileWidth + tileWidth / 2),
        tileWidth / 2,
        bombPaint,
      );
    }

    for (var explosion in gameData.explosions) {
      canvas.drawCircle(
        Offset(explosion.x * tileWidth + tileWidth / 2,
            explosion.y * tileWidth + tileWidth / 2),
        tileWidth * 0.4,
        explosionPaint,
      );
    }

    for (var item in gameData.items) {
      canvas.drawRect(
        Rect.fromLTWH(item.x * tileWidth, item.y * tileWidth, tileWidth / 2,
            tileWidth / 2),
        itemPaint,
      );
    }

    for (var player in gameData.players) {
      if (player.x != null && player.y != null) {
        canvas.drawRect(
          Rect.fromLTWH(player.x! * tileWidth, player.y! * tileWidth, tileWidth,
              tileWidth),
          playerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
