import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({Key? key}) : super(key: key);

  @override
  State<ReservationListScreen> createState() => _ReservationListScreen();
}

class _ReservationListScreen extends State<ReservationListScreen> {
  final Stream<QuerySnapshot> _Reservations =
      FirebaseFirestore.instance.collection('Reservations').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Your Reservations'),
          backgroundColor: const Color.fromARGB(255, 245, 90, 79)),
      body: StreamBuilder<QuerySnapshot>(
          stream: _Reservations,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('There is an error');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Loading");
            }
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['Field'],
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['Location'],
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          data['Date: '].toDate().toString(),
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Players: ${data['Players']}',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
    );
  }
}
