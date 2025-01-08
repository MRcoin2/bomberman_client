import 'dart:convert';
import 'dart:io';

import 'package:bomberman_client/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Player.dart';
import '../providers/game_data_provider.dart';
import '../widgets/player_list.dart';

class LobbyScreen extends StatefulWidget {
  final String nameText;

  const LobbyScreen(String this.nameText, {super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  List<Player> players = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _nameController.text = widget.nameText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Consumer<GameDataProvider>(
                builder: (context, gameData, child) {
                  return PlayerList(players: gameData.players);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    onChanged: (text) {
                      //TODO send name to server
                      context.read<GameDataProvider>().sendMessage(
                          '{"Type":"CLIENT_LOBBY_CHANGE_NAME","Payload":"${text}"}');
                    },
                    decoration: const InputDecoration(
                      hintText: 'Name',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    context.read<GameDataProvider>().sendMessage(
                        '{"Type":"CLIENT_LOBBY_READY","Payload":""}');
                    context.read<GameDataProvider>().onMessage(
                      (message) {
                        var data = jsonDecode(message);
                        if (data['Type'] == 'SERVER_GAME_START') {
                          context.read<GameDataProvider>().clearListeners();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const GameScreen()));
                        }
                      },
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Ready'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
