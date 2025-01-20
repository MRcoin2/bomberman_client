import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Scoreboard extends StatefulWidget {
  final ValueNotifier<String> ipNotifier;

  const Scoreboard(this.ipNotifier, {Key? key}) : super(key: key);

  @override
  _ScoreboardState createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  late Future<List<dynamic>> _scoreboardData;

  @override
  void initState() {
    super.initState();
    widget.ipNotifier.addListener(_fetchScoreboardData);
    _fetchScoreboardData();
  }

  @override
  void dispose() {
    widget.ipNotifier.removeListener(_fetchScoreboardData);
    super.dispose();
  }

  void _fetchScoreboardData() {
    setState(() {
      _scoreboardData = _loadScoreboardData();
    });
  }

  Future<List<dynamic>> _loadScoreboardData() async {
    var uri = Uri.http(widget.ipNotifier.value, '/scoreboard/scoreboard/topScore');
    try{
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      });
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load scoreboard');
      }}catch(e){
      throw Exception('Invalid IP address or server error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: FutureBuilder<List<dynamic>>(
        future: _scoreboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Scoreboard',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Player",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Top Score",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Total Score",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Kills",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Deaths",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Wins",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Matches",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("K/D",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            ),
                          ],
                        ),
                        ...snapshot.data!.map((player) {
                          return TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['username'],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['topScore'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['totalScore'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['totalKills'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['totalDeaths'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['totalWins'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['totalMatches'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(player['storedKDRatio'].toString(),
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 16)),
                              ),

                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}