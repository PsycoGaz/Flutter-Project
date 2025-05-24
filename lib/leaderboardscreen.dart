import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Map<String, int> scores = {};

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final loadedScores = <String, int>{};

    for (var key in keys) {
      loadedScores[key] = prefs.getInt(key) ?? 0;
    }

    setState(() {
      scores = loadedScores;
    });
  }

  Future<void> resetScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      scores = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await resetScores();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Leaderboard reset successfully')),
              );
            },
          ),
        ],
      ),
      body: scores.isEmpty
          ? Center(child: Text('No scores available'))
          : ListView.builder(
        itemCount: scores.length,
        itemBuilder: (context, index) {
          final entry = scores.entries.toList()[index];
          return ListTile(
            title: Text(entry.key.replaceAll('_', ' - ')),
            trailing: Text('Score: ${entry.value}'),
          );
        },
      ),
    );
  }
}