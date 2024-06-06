import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'dart:math';
import 'package:intl/intl.dart';

const primaryColor = Color.fromARGB(255, 245, 90, 79);

class UserGamesTab extends StatefulWidget {
  const UserGamesTab({super.key});

  @override
  _UserGamesTabState createState() => _UserGamesTabState();
}

class _UserGamesTabState extends State<UserGamesTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;
  final _formKey = GlobalKey<FormState>();

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

  void _showMatchDetails(
      BuildContext context, Map<String, dynamic> data, String docId) async {
    List currentPlayers = data['CurrentPlayers'] ?? [];
    List<String> usernames =
        await getUsernames(List<String>.from(currentPlayers));
    Timestamp matchTime = data['Date'];
    DateTime matchDateTime = matchTime.toDate();
    String formattedDate = DateFormat('yMMMMd').add_jm().format(matchDateTime);
    TextEditingController resultController = TextEditingController();
    String? selectedWinnerEmail;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Match Details'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Field: ${data['Field']}'),
                      Text(
                          'Players: ${currentPlayers.length}/${data['Players']}'),
                      const SizedBox(height: 10),
                      const Text('Current Players:'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: usernames
                            .map((username) => buildCircleAvatar(username))
                            .toList(),
                      ),
                      Text('Time: $formattedDate'),
                      if (data['isEnded'] == null ||
                          data['isEnded'] == false) ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: resultController,
                          decoration: const InputDecoration(
                            labelText: 'Enter Match Result',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a result';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedWinnerEmail,
                          hint: const Text('Select Winner'),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedWinnerEmail = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a winner';
                            }
                            return null;
                          },
                          items: currentPlayers
                              .map<DropdownMenuItem<String>>((playerEmail) {
                            return DropdownMenuItem<String>(
                              value: playerEmail,
                              child: Text(usernames[
                                  currentPlayers.indexOf(playerEmail)]),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                if (data['isEnded'] == null || data['isEnded'] == false) ...[
                  TextButton(
                    child: const Text('End Match'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _firestoreService.addMatchResult(
                            docId, resultController.text);
                        _firestoreService.setMatchWinner(
                            docId, selectedWinnerEmail!);
                        _firestoreService.endMatch(docId, userEmail!);
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

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
            List currentPlayers = data['CurrentPlayers'] ?? [];
            Timestamp matchTime = data['Date'];
            DateTime matchDateTime = matchTime.toDate();
            DateFormat('yMMMMd').add_jm().format(matchDateTime);

            return ListTile(
              title: Text('${data['Field']} (${data['Location']})'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Players: ${currentPlayers.length}/${data['Players']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _firestoreService.leaveMatch(doc.id, userEmail!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Leave'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showMatchDetails(context, data, doc.id);
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
          }).toList(),
        );
      },
    );
  }
}
