import 'package:bomberman_client/providers/game_data_provider.dart';
import 'package:flutter/material.dart';


class GamePlayerList extends StatelessWidget {
  final GameDataProvider gameData;
  static const List<Color> colors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.yellow,
  ];
  GamePlayerList({super.key, required this.gameData});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
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
              title: Row(
                children: [
                  Text(player.name,
                      style: TextStyle(
                          color: colors[gameData.players.indexOf(player)],
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  SizedBox(width: 10),
                  Text("[💣 - ${player.bombLimit}]"),
                  SizedBox(width: 10),
                  Text("[💥 - ${player.bombPower}]"),
                  SizedBox(width: 10),
                  Text("[💨 - ${player.speed}]"),

                ],

              ),
              subtitle: player.isAlive ? Row(
                children: [
                  for (var i = 0; i < (player.lives ?? 0); i++)
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 16,
                    ),
                ],
              ):const Icon(
                Icons.close,
                color: Colors.red,
                size: 16,
              ),

              trailing: Text(player.score.toString(),
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 30)),
            ),
          );
        })
      ],
    );
  }
}
