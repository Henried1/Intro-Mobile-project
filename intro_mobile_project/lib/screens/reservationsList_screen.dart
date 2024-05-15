import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

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
      ),
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
                return ListTile(
                    title: Text(data['Field']),
                    subtitle: Text(
                      data['Date: '].toDate().toString(),
                    ));
              }).toList(),
            );
          }),
    );
  }
}
