import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Scoreboard extends StatefulWidget {
  final String ip;

  const Scoreboard(this.ip, {Key? key}) : super(key: key);

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  late Future<List<dynamic>> _scoreboardData;

  @override
  void initState() {
    super.initState();
    _scoreboardData = _fetchScoreboardData();
  }

  Future<List<dynamic>> _fetchScoreboardData() async {
      var uri = Uri.http(widget.ip, '/scoreboard/scoreboard/top20');
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load scoreboard');
      }
    }
  

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _scoreboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
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
              ...snapshot.data!.map((player) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Row(
                      children: [
                        Text(player['username'],
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        SizedBox(width: 10),
                        Text(player['topScore'].toString(),
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        }
      },
    );
  }
}