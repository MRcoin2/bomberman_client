import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/game_data_provider.dart';
import '../models/Player.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FocusNode _focusNode = FocusNode();

  void _handleKeyEvent(BuildContext context, KeyEvent event) {
    final gameData = Provider.of<GameDataProvider>(context, listen: false);
      print(event.logicalKey.keyLabel);
      switch (event.logicalKey.keyLabel) {
        case "Arrow Up": // Arrow up
          print('Arrow up');
          //send to server
          gameData.sendMessage('{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"up", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
          break;
        case "Arrow Down": // Arrow down
          print('Arrow down');
          gameData.sendMessage('{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"down", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
          break;
        case "Arrow Left": // Arrow left
          print('Arrow left');
          gameData.sendMessage('{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"left", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
          break;
        case "Arrow Right": // Arrow right
          print('Arrow right');
          gameData.sendMessage('{"Type":"CLIENT_GAME_MOVE","Payload":{"Direction":"right", "KeyDown":${event is KeyDownEvent || event is KeyRepeatEvent}}}');
          break;
        case " ": // Space
          print('Space');
          gameData.sendMessage('{"Type":"CLIENT_GAME_BOMB","Payload":""}');
          break;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //go to main screen
      floatingActionButton: FloatingActionButton(
        focusNode: FocusNode(skipTraversal: true),
        onPressed: () {
          Navigator.of(context).popAndPushNamed('/');
        },
        child: const Icon(Icons.exit_to_app),
      ),
      body: Column(
        children: [
          Expanded(
            child: DefaultTextEditingShortcuts(
              child: KeyboardListener(
                autofocus: true,
                onKeyEvent: (event) => _handleKeyEvent(context, event),
                focusNode: _focusNode,
                child: Center(
                  child: Consumer<GameDataProvider>(
                    builder: (context, gameData, child) {
                      return CustomPaint(
                        size: Size(300, 300),
                        painter: GameCanvasPainter(gameData),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Consumer<GameDataProvider>(
            builder: (context, gameData, child) {
              return Column(
                children: gameData.players.map((player) {
                  return ListTile(
                    title: Text(player.name),
                    subtitle: Text(player.isReady ? 'Ready' : 'Not Ready'),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

const double tileWidth = 20.0;

class GameCanvasPainter extends CustomPainter {
  final GameDataProvider gameData;

  GameCanvasPainter(this.gameData);

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
        Rect.fromLTWH(wall.x * tileWidth, wall.y * tileWidth, tileWidth, tileWidth),
        wallPaint,
      );
    }

    for (var block in gameData.blocks) {
      canvas.drawRect(
        Rect.fromLTWH(block.x * tileWidth, block.y * tileWidth, tileWidth, tileWidth),
        blockPaint,
      );
    }

    for (var bomb in gameData.bombs) {
      canvas.drawCircle(
        Offset(bomb.x * tileWidth, bomb.y * tileWidth),
        tileWidth / 2,
        bombPaint,
      );
    }

    for (var explosion in gameData.explosions) {
      canvas.drawCircle(
        Offset(explosion.x * tileWidth, explosion.y * tileWidth),
        tileWidth * 0.75,
        explosionPaint,
      );
    }

    for (var item in gameData.items) {
      canvas.drawRect(
        Rect.fromLTWH(item.x * tileWidth, item.y * tileWidth, tileWidth / 2, tileWidth / 2),
        itemPaint,
      );
    }

    for (var player in gameData.players) {
      if (player.x != null && player.y != null) {
        canvas.drawRect(
          Rect.fromLTWH(player.x! * tileWidth, player.y! * tileWidth, tileWidth, tileWidth),
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