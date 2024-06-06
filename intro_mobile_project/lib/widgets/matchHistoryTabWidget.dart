import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchHistoryTab extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  MatchHistoryTab({super.key});

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

  Widget buildCircleAvatar(String name) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getMatchHistory(userEmail!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('You have no match history'));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
            List currentPlayers = data['CurrentPlayers'] ?? [];
            Timestamp matchTime = data['Date'];
            DateTime matchDateTime = matchTime.toDate();
            String formattedDate =
                DateFormat('yMMMMd').add_jm().format(matchDateTime);
            String? winnerEmail = data['Winner'];

            return FutureBuilder<String>(
              future: winnerEmail != null
                  ? getUsername(winnerEmail)
                  : Future.value('N/A'),
              builder: (context, winnerSnapshot) {
                if (winnerSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                String winnerUsername = winnerSnapshot.data ?? 'N/A';

                return ListTile(
                  title: Text('${data['Field']} (${data['Location']})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Players: ${currentPlayers.length}/${data['Players']}'),
                      Text('Result: ${data['Result'] ?? 'N/A'}'),
                      Text('Winner: $winnerUsername'),
                      Text('Ended: $formattedDate'),
                    ],
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
