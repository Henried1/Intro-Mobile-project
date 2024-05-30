import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intro_mobile_project/service/database.dart';

const primaryColor = Color.fromARGB(255, 245, 90, 79);

class UserGamesTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  UserGamesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getUserMatches(userEmail!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no matches'));
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            return ListTile(
              title: Text('${data['Field']} (${data['Location']})'),
              subtitle: Text(
                  'Players: ${data['CurrentPlayers'].length}/${data['Players']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  _firestoreService.leaveMatch(doc.id, userEmail!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text('Leave'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
