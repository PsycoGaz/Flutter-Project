import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import './quiz_screen.dart';
import './AppLocalizations.dart';

class QuizSettingsScreen extends StatefulWidget {
  @override
  _QuizSettingsScreenState createState() => _QuizSettingsScreenState();
}

class _QuizSettingsScreenState extends State<QuizSettingsScreen> {
  List<dynamic> categories = [];
  String? selectedCategory;
  String selectedDifficulty = 'easy';
  int numberOfQuestions = 5;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> playClickSound() async {
    await _audioPlayer.play(AssetSource('click.mp3'));
  }

  Future<void> fetchCategories() async {
    final url = 'https://opentdb.com/api_category.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = data['trivia_categories'];
      });
    } else {
      setState(() {
        categories = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('fetch_error'))),
      );
    }
  }

  void onStartQuizPressed() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).translate('select_category'))),
      );
      return;
    }

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
    await playClickSound();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          category: selectedCategory!,
          difficulty: selectedDifficulty,
          numberOfQuestions: numberOfQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        title: Text(
          AppLocalizations.of(context).translate('quiz_settings'),
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        elevation: 0,
      ),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('category'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((cat) {
                  return DropdownMenuItem(
                    value: cat['id'].toString(),
                    child: Text(cat['name']),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('difficulty'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                value: selectedDifficulty,
                onChanged: (value) {
                  setState(() {
                    selectedDifficulty = value!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'easy', child: Text(AppLocalizations.of(context).translate('easy'))),
                  DropdownMenuItem(value: 'medium', child: Text(AppLocalizations.of(context).translate('medium'))),
                  DropdownMenuItem(value: 'hard', child: Text(AppLocalizations.of(context).translate('hard'))),
                ],
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('number_of_questions'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                value: numberOfQuestions,
                onChanged: (value) {
                  setState(() {
                    numberOfQuestions = value!;
                  });
                },
                items: [5, 10, 15]
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onStartQuizPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('start_quiz'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
