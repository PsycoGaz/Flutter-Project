import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:html_unescape/html_unescape.dart';
import './results_screen.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  final int numberOfQuestions;

  QuizScreen({
    required this.category,
    required this.difficulty,
    required this.numberOfQuestions,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<dynamic> questions = [];
  List<String> userAnswers = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  final unescape = HtmlUnescape();
  Timer? timer;
  int timeLeft = 20;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchQuestions() async {
    final url =
        'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}&category=${widget.category}&difficulty=${widget.difficulty}&type=multiple';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions = data['results'].map((question) {
          final answers = [...question['incorrect_answers'], question['correct_answer']];
          answers.shuffle();
          return {
            ...question,
            'shuffled_answers': answers,
          };
        }).toList();
        isLoading = false;
      });
      startTimer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions. Please try again.')),
      );
    }
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = 20;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
        moveToNextQuestion();
      }
    });
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
      startTimer();
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            score: score,
            total: questions.length,
            questions: questions,
            userAnswers: userAnswers,
            category: widget.category,
            difficulty: widget.difficulty,
          ),
        ),
      );
    }
  }

  void checkAnswer(String selectedAnswer) {
    userAnswers.add(selectedAnswer);
    final correctAnswer = questions[currentQuestionIndex]['correct_answer'];
    if (selectedAnswer == correctAnswer) {
      setState(() {
        score++;
      });
    }
    moveToNextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Quiz')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];
    final answers = question['shuffled_answers'];

    return Scaffold(
      appBar: AppBar(title: Text('Quiz')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              unescape.convert(question['question']),
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              'Time Left: $timeLeft seconds',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            SizedBox(height: 16),
            ...answers.map((answer) {
              return ElevatedButton(
                onPressed: () => checkAnswer(answer),
                child: Text(unescape.convert(answer)),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}