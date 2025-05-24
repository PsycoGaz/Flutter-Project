import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import './AppLocalizations.dart';

class AnswersScreen extends StatelessWidget {
  final List<dynamic> questions;
  final List<String> userAnswers;

  AnswersScreen({required this.questions, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    final unescape = HtmlUnescape();

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('answers'))),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final correctAnswer = unescape.convert(question['correct_answer']);
          final userAnswer = userAnswers[index];
          final isCorrect = userAnswer == correctAnswer;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: ListTile(
                title: Text(unescape.convert(question['question'])),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppLocalizations.of(context).translate('your_answer')}: $userAnswer',
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                    Text('${AppLocalizations.of(context).translate('correct_answer')}: $correctAnswer'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}