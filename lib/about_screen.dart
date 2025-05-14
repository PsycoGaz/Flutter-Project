import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('À propos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Cette application utilise l'API OpenTDB pour fournir des quiz interactifs.\n\nDéveloppée en Flutter pour le mini-projet de Programmation Mobile.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}