import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'dart:math';
import 'package:intl/intl.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class PublicGamesTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  PublicGamesTab({super.key});

  Future<String> getUsername(String email) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(email).get();
    return userDoc.exists ? userDoc.get('Username') : email;
  }

  Future<List<String>> getUsernames(List<String> emails) async {
    List<Future<String>> futures =
        emails.map((email) => getUsername(email)).toList();
    return await Future.wait(futures);
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Widget buildCircleAvatar(String name) {
    return CircleAvatar(
      backgroundColor: getRandomColor(),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

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
          children: snapshot.data!.docs
              .map((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                List currentPlayers = data['CurrentPlayers'] ?? [];
                int maxPlayers = data['Players'] ?? 0;
                Timestamp matchTime = data['Date'];
                DateTime matchDateTime = matchTime.toDate();
                String formattedDate =
                    DateFormat('yMMMMd').add_jm().format(matchDateTime);
                bool isUserInMatch = currentPlayers.contains(userEmail);
                bool canJoin =
                    !isUserInMatch && currentPlayers.length < maxPlayers;

                String buttonText;
                if (canJoin) {
                  buttonText = 'Join';
                } else if (currentPlayers.length >= maxPlayers) {
                  buttonText = 'Full';
                } else {
                  buttonText = 'Already Joined';
                }

                return ListTile(
                  title: Text('${data['Field']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Players: ${currentPlayers.length}/$maxPlayers'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: canJoin
                            ? () {
                                _firestoreService.joinMatch(doc.id, userEmail!);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(buttonText),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          List<String> usernames = await getUsernames(
                              List<String>.from(currentPlayers));
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Match Details'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Field: ${data['Field']}'),
                                    Text(
                                        'Players: ${currentPlayers.length}/$maxPlayers'),
                                    const SizedBox(height: 10),
                                    const Text('Current Players:'),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: usernames
                                          .map((username) =>
                                              buildCircleAvatar(username))
                                          .toList(),
                                    ),
                                    Text('Time: $formattedDate'),
                                  ],
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Close'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Details'),
                      ),
                    ],
                  ),
                );
              })
              .toList()
              .cast<Widget>(),
        );
      },
    );
  }
}
