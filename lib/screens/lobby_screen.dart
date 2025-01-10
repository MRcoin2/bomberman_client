import 'dart:convert';
import 'dart:io';

import 'package:bomberman_client/screens/game_screen.dart';
import 'package:bomberman_client/widgets/settings_panel.dart';
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              flex: 2,
              child: Consumer<GameDataProvider>(
                builder: (context, gameData, child) {
                  return PlayerList(players: gameData.players);
                },
              ),
            ),
            const SizedBox(height: 20),
            SettingsPanel(),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _nameController,
                          onChanged: (text) {
                            context.read<GameDataProvider>().sendMessage(
                                '{"Type":"CLIENT_LOBBY_CHANGE_NAME","Payload":{"Name":"${text}"}}');
                          },
                          decoration: const InputDecoration(
                            hintText: 'Name',
                            labelText: 'Name',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ElevatedButton(

                      onPressed: () {
                        context.read<GameDataProvider>().sendMessage(
                            '{"Type":"CLIENT_LOBBY_READY","Payload":{"_":"_"}}');
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
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 30),
                        child: Text('Ready', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
