import 'dart:io';

import 'package:bomberman_client/providers/websocket_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/Player.dart';
import '../providers/game_data_provider.dart';
import '../widgets/player_list.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

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
              child: PlayerList(players: context.watch<GameDataProvider>().players),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    onEditingComplete: () {
                      //TODO send name to server
                    },
                    decoration: const InputDecoration(
                      hintText: 'Name',
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    //TODO send ready to server
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