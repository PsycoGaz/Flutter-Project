import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class ScoreEntry {
  final String categoryId;
  final String categoryName;
  final String difficulty;
  final int score;

  ScoreEntry({
    required this.categoryId,
    required this.categoryName,
    required this.difficulty,
    required this.score,
  });
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<ScoreEntry> entries = [];
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Exemple de map categoryId -> categoryName (à compléter selon tes catégories)
  final Map<String, String> categoryNames = {
    '9': 'General Knowledge',
    '10': 'Entertainment: Books',
    '11': 'Entertainment: Film',
    '12': 'Entertainment: Music',
    '13': 'Entertainment: Musicals & Theatres',
    '14': 'Entertainment: Television',
    '15': 'Entertainment: Video Games',
    '16': 'Entertainment: Board Games',
    '17': 'Science & Nature',
    '18': 'Science: Computers',
    '19': 'Science: Mathematics',
    '20': 'Mythology',
    '21': 'Sports',
    '22': 'Geography',
    '23': 'History',
    '24': 'Politics',
    '25': 'Art',
    '26': 'Celebrities',
    '27': 'Animals',
    '28': 'Vehicles',
    '29': 'Entertainment: Comics',
    '30': 'Science: Gadgets',
    '31': 'Entertainment: Japanese Anime & Manga',
    '32': 'Entertainment: Cartoon & Animations',
  };

  @override
  void initState() {
    super.initState();
    loadScores();
  }

  Future<void> playClickSound() async {
    try {
      await _audioPlayer.play(AssetSource('click.mp3'));
    } catch (e) {
      // ignore audio errors
    }
  }

  Future<void> loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    List<ScoreEntry> loadedEntries = [];

    for (var key in keys) {
      final score = prefs.getInt(key) ?? 0;
      // clé formatée: categoryId_difficulty, ex: '9_easy'
      final parts = key.split('_');
      if (parts.length == 2) {
        final catId = parts[0];
        final diff = parts[1];
        final catName = categoryNames[catId] ?? catId;
        loadedEntries.add(ScoreEntry(
          categoryId: catId,
          categoryName: catName,
          difficulty: diff,
          score: score,
        ));
      }
    }

    // Trier : catégorie alphabétique, difficulté (easy < medium < hard), score décroissant
    loadedEntries.sort((a, b) {
      final catCompare = a.categoryName.compareTo(b.categoryName);
      if (catCompare != 0) return catCompare;

      final diffOrder = ['easy', 'medium', 'hard'];
      final diffCompare = diffOrder.indexOf(a.difficulty).compareTo(diffOrder.indexOf(b.difficulty));
      if (diffCompare != 0) return diffCompare;

      return b.score.compareTo(a.score);
    });

    setState(() {
      entries = loadedEntries;
    });
  }

  Future<void> resetScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    setState(() {
      entries = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    String? currentCategory;
    String? currentDifficulty;
    int rank = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        title: Text(
          'Leaderboard',
          style: textTheme.titleLarge?.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: isDark ? Colors.white : Colors.black),
            onPressed: () async {
              await playClickSound();
              await resetScores();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leaderboard reset successfully'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.teal,
                ),
              );
            },
            tooltip: 'Reset Leaderboard',
          ),
        ],
      ),
      body: Container(
        color: isDark ? Colors.black : Colors.grey[100],
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: entries.isEmpty
            ? Center(
          child: Text(
            'No scores available',
            style: textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        )
            : ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => Divider(
            color: isDark ? Colors.white12 : Colors.black12,
            thickness: 1,
            height: 12,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];

            // reset rank si nouvelle catégorie ou difficulté
            if (entry.categoryName != currentCategory || entry.difficulty != currentDifficulty) {
              currentCategory = entry.categoryName;
              currentDifficulty = entry.difficulty;
              rank = 1;
            } else {
              rank++;
            }

            return ListTile(
              tileColor: isDark ? Colors.grey[900] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Text(
                  '$rank',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                '${entry.categoryName} (${entry.difficulty.capitalize()})',
                style: textTheme.titleMedium?.copyWith(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: Text(
                'Score: ${entry.score}',
                style: textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.tealAccent.shade200 : Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
