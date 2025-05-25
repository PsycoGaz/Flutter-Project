import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
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

  void _onButtonPressed(BuildContext context, VoidCallback action) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 80);
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    saveBestScore();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: Text(
          AppLocalizations.of(context).translate('results'),
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: FutureBuilder<int>(
        future: getBestScore(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final bestScore = snapshot.data!;
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.of(context).translate('your_score')}: $score/$total',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context).translate('best_score')}: $bestScore/$total',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onButtonPressed(context, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswersScreen(
                              questions: questions,
                              userAnswers: userAnswers,
                            ),
                          ),
                        );
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('view_answers'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onButtonPressed(context, () {
                        Navigator.pop(context);
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        AppLocalizations.of(context).translate('back_to_home'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
