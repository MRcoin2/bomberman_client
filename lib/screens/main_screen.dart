import 'package:bomberman_client/providers/game_data_provider.dart';
import 'package:bomberman_client/screens/lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bomberman_client/providers/websocket_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Bomberman', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'IP Address',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final url = 'ws://${_ipController.text}/ws';
              await context.read<WebSocketProvider>().connect(url);
              // Register a callback to listen for messages and update game state
              context.read<WebSocketProvider>().onMessage((message) {
                context.read<GameDataProvider>().updateData(message);
              });
              //send join message
              context.read<WebSocketProvider>().sendMessage('{"Type":"JOIN_LOBBY"}');
              context.read<WebSocketProvider>().sendMessage('Hello');
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LobbyScreen()));
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}