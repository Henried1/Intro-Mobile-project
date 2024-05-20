import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intro_mobile_project/screens/field_details_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({Key? key}) : super(key: key);

  @override
  State<FieldsScreen> createState() => _FieldScreens();
}

class _FieldScreens extends State<FieldsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Location'),
        backgroundColor: const Color.fromARGB(255, 245, 90, 79),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final List<DocumentSnapshot> documents = snapshot.data!.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final field = documents[index];
              return Card(
                color: const Color.fromARGB(255, 245, 90, 79),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                      child: Image.network(
                        field['fieldImage'],
                        height: 200,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        field['fieldName'],
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Text(
                        field['fieldLocation'],
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FieldDetailScreen(
                              fieldName: field['fieldName'],
                              fieldImage: field['fieldImage'],
                              fieldLocation: field['fieldLocation'],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
