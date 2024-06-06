import 'package:flutter/material.dart';
import 'package:intro_mobile_project/widgets/publicGamesTabWidget.dart';
import 'package:intro_mobile_project/widgets/userGamesTabWidget.dart';
import 'package:intro_mobile_project/widgets/matchHistoryTabWidget.dart'; // Make sure this import is correct

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Update the length to include the new tab
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Games'),
          backgroundColor: primaryColor,
          bottom: TabBar(
            labelStyle: const TextStyle(color: Colors.white),
            unselectedLabelColor: Colors.white.withOpacity(0.4),
            tabs: const [
              Tab(text: 'Public Games'),
              Tab(text: 'My Games'),
              Tab(text: 'Match History'), // Add the new tab
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PublicGamesTab(),
            UserGamesTab(),
            MatchHistoryTab(), // Add the new tab
          ],
        ),
      ),
    );
  }
}
