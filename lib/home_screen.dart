import 'package:flutter/material.dart';
import './quiz_settings_screen.dart';
import './leaderboardscreen.dart';
import './AppLocalizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final Function(Locale) onChangeLanguage;

  HomeScreen({required this.onToggleTheme, required this.onChangeLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('title')),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
          DropdownButton<Locale>(
            icon: Icon(Icons.language, color: Colors.white),
            underline: SizedBox(),
            onChanged: (Locale? locale) {
              if (locale != null) onChangeLanguage(locale);
            },
            items: [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('fr'), child: Text('Français')),
              DropdownMenuItem(value: Locale('ar'), child: Text('العربية')),
            ],
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: AppLocalizations.of(context).translate('title'),
                applicationVersion: '1.0.0',
                applicationIcon: Icon(Icons.quiz),
                children: [
                  Text(AppLocalizations.of(context).translate('about')),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuizSettingsScreen()),
                );
              },
              child: Text(AppLocalizations.of(context).translate('start_quiz')),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                );
              },
              child: Text(AppLocalizations.of(context).translate('view_leaderboard')),
            ),
          ],
        ),
      ),
    );
  }
}