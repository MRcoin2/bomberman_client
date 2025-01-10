import 'dart:convert';

import 'package:bomberman_client/providers/game_data_provider.dart';
import 'package:bomberman_client/screens/lobby_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _ipController = TextEditingController();

  @override
  void initState() {
    _nameController.text = 'Player 1';
    _ipController.text = 'localhost:5038';
    super.initState();
  }

  void _handlePolicyViolation(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        duration: Duration(seconds: 5)
      ),
    );
  }

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
              final gameDataProvider = context.read<GameDataProvider>();
              gameDataProvider.onPolicyViolation = _handlePolicyViolation;
              await gameDataProvider.connect(url);

              //send join message
              gameDataProvider.sendMessage('{"Type":"CLIENT_LOBBY_JOIN","Payload":{"Name":"${_nameController.text}"}}');
              gameDataProvider.onMessage((message) {
                var data = jsonDecode(message);
                if (data['Type'] == 'SERVER_LOBBY_JOIN') {
                  if(data['Payload']['Response'] == 'OK') {
                    gameDataProvider.id = data['Payload']['PlayerId'];
                    gameDataProvider.clearListeners();
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => LobbyScreen(_nameController.text)));
                  }else{
                    //pop up error message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: Text(data['Payload']['Response']),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              });

            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}