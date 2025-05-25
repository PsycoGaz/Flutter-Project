import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        title: Text(
          'À propos',
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Container(
        color: isDark ? Colors.black : Colors.grey[100],
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Cette application utilise l'API OpenTDB pour fournir des quiz interactifs.\n\n"
              "Développée en Flutter pour le mini-projet de Programmation Mobile.",
          style: textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
