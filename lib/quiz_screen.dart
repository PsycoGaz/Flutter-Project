import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:html_unescape/html_unescape.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  Future<void> playClickSound() async {
    await _audioPlayer.play(AssetSource('click.mp3'));
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

  void checkAnswer(String selectedAnswer) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    await playClickSound();

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black87 : Colors.white,
          title: Text('Quiz', style: textTheme.titleLarge?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          elevation: 0,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];
    final answers = question['shuffled_answers'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: Text('Quiz', style: textTheme.titleLarge?.copyWith(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: isDark ? Colors.black : Colors.grey[100],
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}/${questions.length}',
              style: textTheme.titleMedium?.copyWith(color: isDark ? Colors.white70 : Colors.black87),
            ),
            SizedBox(height: 16),
            Text(
              unescape.convert(question['question']),
              style: textTheme.titleLarge?.copyWith(color: isDark ? Colors.white : Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Time Left: $timeLeft seconds',
              style: textTheme.titleMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...answers.map((answer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(answer),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Text(
                    unescape.convert(answer),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
