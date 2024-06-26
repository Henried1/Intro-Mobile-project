import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

const primaryColor = Color.fromARGB(255, 245, 90, 79);

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreen();
}

class _ReservationListScreen extends State<ReservationListScreen> {
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Reservations'),
        backgroundColor: primaryColor,
      ),
      body: userEmail == null
          ? const Center(child: Text("No user logged in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Reservations')
                  .where('Email', isEqualTo: userEmail)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('There is an error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No reservations found."));
                }
                return ListView(
                  children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;

                    Timestamp timestamp = data['Date'];
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
                        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['Field'] ?? 'Unknown Field',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              data['Location'] ?? 'Unknown Location',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Players: ${data['Players'] ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
