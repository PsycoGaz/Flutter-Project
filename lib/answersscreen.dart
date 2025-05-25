import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:audioplayers/audioplayers.dart';
import './AppLocalizations.dart';

class AnswersScreen extends StatefulWidget {
  final List<dynamic> questions;
  final List<String> userAnswers;

  AnswersScreen({required this.questions, required this.userAnswers});

  @override
  _AnswersScreenState createState() => _AnswersScreenState();
}

class _AnswersScreenState extends State<AnswersScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final HtmlUnescape unescape = HtmlUnescape();

  Future<void> playClickSound() async {
    await _audioPlayer.play(AssetSource('click.mp3'));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('answers'),
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Container(
        color: isDark ? Colors.black : Colors.grey[100],
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: ListView.builder(
          itemCount: widget.questions.length,
          itemBuilder: (context, index) {
            final question = widget.questions[index];
            final correctAnswer = unescape.convert(question['correct_answer']);
            final userAnswer = widget.userAnswers[index];
            final isCorrect = userAnswer == correctAnswer;

            return GestureDetector(
              onTap: () async {
                await playClickSound();
                // tu peux ajouter une action ici si besoin
              },
              child: Card(
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        unescape.convert(question['question']),
                        style: textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '${AppLocalizations.of(context).translate('your_answer')}: $userAnswer',
                        style: TextStyle(
                          color: isCorrect ? Colors.greenAccent.shade400 : Colors.redAccent.shade400,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context).translate('correct_answer')}: $correctAnswer',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
