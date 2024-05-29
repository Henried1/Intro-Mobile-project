import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intro_mobile_project/service/database.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class PublicGamesTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  PublicGamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getPublicMatches(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No public matches available'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            List currentPlayers = data['CurrentPlayers'] ?? [];
            int maxPlayers = data['Players'] ?? 0;
            bool isUserInMatch = currentPlayers.contains(userEmail);
            bool canJoin = !isUserInMatch && currentPlayers.length < maxPlayers;

            String buttonText;
            if (canJoin) {
              buttonText = 'Join';
            } else if (currentPlayers.length >= maxPlayers) {
              buttonText = 'Full';
            } else {
              buttonText = 'Already Joined';
            }

            return ListTile(
              title: Text('${data['Field']} (${data['Location']})'),
              subtitle: Text('Players: ${currentPlayers.length}/$maxPlayers'),
              trailing: ElevatedButton(
                onPressed: canJoin
                    ? () {
                        _firestoreService.joinMatch(doc.id, userEmail!);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: Text(buttonText),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
