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
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final player = snapshot.data![index];
              return ListTile(
                title: Text(player['name']),
                trailing: Text(player['score'].toString()),
              );
            },
          );
        }
      },
    );
  }
}