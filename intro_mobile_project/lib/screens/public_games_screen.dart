import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intro_mobile_project/service/database.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class PublicMatchesScreen extends StatefulWidget {
  @override
  _PublicMatchesScreenState createState() => _PublicMatchesScreenState();
}

class _PublicMatchesScreenState extends State<PublicMatchesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Public Matches'),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPublicMatches(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No public matches available'));
          }
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
              List currentPlayers = data['CurrentPlayers'] ?? [];
              int maxPlayers = data['Players'] ?? 0;
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
                title: Text('${data['Field']} (${data['Location']})'),
                subtitle: Text('Players: ${currentPlayers.length}/$maxPlayers'),
                trailing: canJoin
                    ? ElevatedButton(
                        child: Text(buttonText),
                        onPressed: () {
                          _firestoreService.joinMatch(doc.id, userEmail!);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                        ),
                      )
                    : null,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
