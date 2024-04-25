import 'package:flutter/material.dart';

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});
  @override
  State<FieldsScreen> createState() => _FieldScreens();
}

class _FieldScreens extends State<FieldsScreen> {
  final List<String> fields = ['Field 1', 'Field 2', 'Field 3', 'Field 4'];

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
            child: ListTile(
                title: Text(fields[index]),
                selectedColor: const Color.fromARGB(255, 245, 90, 79),
                onTap: () {
                  print("field ${fields[index]} selected");
                }),
          );
        },
      ),
    );
  }
}
