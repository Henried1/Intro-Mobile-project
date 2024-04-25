// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/field_details_screen.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldScreens();
}

class _FieldScreens extends State<FieldsScreen> {
  final List<String> fields = ['Field 1', 'Field 2', 'Field 3', 'Field 4'];
  final List<String> fieldImages = [
    'assets/images/veld1.jpg',
    'assets/images/veld2.jpg',
    'assets/images/veld3.jpeg',
    'assets/images/veld4.jpg'
  ];
  final List<String> fieldLocations = [
    'Hombeek',
    'Mechelen',
    'Bonheiden',
    'Sint-Katelijne-Waver'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select a Field'),
          backgroundColor: const Color.fromARGB(255, 245, 90, 79),
        ),
        body: ListView.builder(
          itemCount: fields.length,
          itemBuilder: (context, index) {
            return Card(
              color: Color.fromARGB(255, 245, 90, 79),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                    child: Image.asset(
                      fieldImages[index],
                      height: 200,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      fields[index],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      fieldLocations[index],
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FieldDetailScreen(
                                  fieldName: fields[index],
                                  fieldImage: fieldImages[index],
                                  fieldLocation: fieldLocations[index])));
                    },
                  )
                ],
              ),
            );
          },
        ));
  }
}
