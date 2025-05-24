import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './answersscreen.dart';
import './AppLocalizations.dart';

class ResultsScreen extends StatelessWidget {
  final int score;
  final int total;
  final List<dynamic> questions;
  final List<String> userAnswers;
  final String category;
  final String difficulty;

  ResultsScreen({
    required this.score,
    required this.total,
    required this.questions,
    required this.userAnswers,
    required this.category,
    required this.difficulty,
  });

  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${category}_$difficulty';
    final bestScore = prefs.getInt(key) ?? 0;

    if (score > bestScore) {
      await prefs.setInt(key, score);
    }
  }

  Future<int> getBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${category}_$difficulty';
    return prefs.getInt(key) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    saveBestScore();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('results'))),
      body: FutureBuilder<int>(
        future: getBestScore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bestScore = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${AppLocalizations.of(context).translate('your_score')}: $score/$total',
                  style: TextStyle(fontSize: 24),
                ),
                SizedBox(height: 16),
                Text(
                  '${AppLocalizations.of(context).translate('best_score')}: $bestScore/$total',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnswersScreen(
                          questions: questions,
                          userAnswers: userAnswers,
                        ),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context).translate('view_answers')),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context).translate('back_to_home')),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}