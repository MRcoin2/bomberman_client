import 'package:flutter/material.dart';

import '../models/Player.dart';

class PlayerList extends StatefulWidget {
  final List<Player> players;

  const PlayerList({Key? key, required this.players}) : super(key: key);

  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: widget.players.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Text(widget.players[index].name),
              trailing: Text(widget.players[index].isReady ? 'Ready' : 'Not Ready',
                  style: TextStyle(
                      color: widget.players[index].isReady ? Colors.green : Colors
                          .red)),
            );
          },
        ),
      ),
    );
  }
}
