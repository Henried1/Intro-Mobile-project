import 'package:flutter/material.dart';
import 'package:intro_mobile_project/widgets/publicGamesTabWidget.dart';
import 'package:intro_mobile_project/widgets/userGamesTabWidget.dart';
import 'package:intro_mobile_project/widgets/matchHistoryTabWidget.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
              Tab(text: 'Match History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            PublicGamesTab(),
            const UserGamesTab(),
            MatchHistoryTab(),
          ],
        ),
      ),
    );
  }
}
