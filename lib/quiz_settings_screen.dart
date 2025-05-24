import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    fetchCategories();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).translate('quiz_settings'))),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('category')),
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
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('difficulty')),
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
              SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: AppLocalizations.of(context).translate('number_of_questions')),
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
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
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
                },
                child: Text(AppLocalizations.of(context).translate('start_quiz')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}