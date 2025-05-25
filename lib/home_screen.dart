import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import './quiz_settings_screen.dart';
import './leaderboardscreen.dart';
import './AppLocalizations.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final Function(Locale) onChangeLanguage;
  final AudioPlayer _audioPlayer = AudioPlayer();

  HomeScreen({required this.onToggleTheme, required this.onChangeLanguage});

  void playClickSound() async {
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
          AppLocalizations.of(context).translate('title'),
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              playClickSound();
              onToggleTheme();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: PopupMenuButton<Locale>(
              icon: Icon(Icons.language, color: isDark ? Colors.white : Colors.black),
              onSelected: (Locale locale) {
                playClickSound();
                onChangeLanguage(locale);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                PopupMenuItem(
                  value: Locale('fr'),
                  child: Text('Français'),
                ),
                PopupMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.info_outline, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              playClickSound();
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
      body: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        color: isDark ? Colors.black : Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.play_arrow),
                label: Text(
                  AppLocalizations.of(context).translate('start_quiz'),
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                ),
                onPressed: () {
                  playClickSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => QuizSettingsScreen()),
                  );
                },
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.leaderboard),
                label: Text(
                  AppLocalizations.of(context).translate('view_leaderboard'),
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  backgroundColor: isDark ? Colors.tealAccent.shade700 : Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 6,
                ),
                onPressed: () {
                  playClickSound();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LeaderboardScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
