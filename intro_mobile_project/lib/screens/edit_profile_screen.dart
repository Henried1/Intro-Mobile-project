import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:provider/provider.dart';
import 'package:intro_mobile_project/model/user_logged_controller.dart';
import 'package:intro_mobile_project/model/user_account.dart';
import 'package:intro_mobile_project/model/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  bool _isChanged = false;

  @override
  Widget build(BuildContext context) {
    final userLogged = Provider.of<UserLogged>(context);
    final userEmail = userLogged.email.trim();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            FutureBuilder<UserAccount?>(
              future: readUserOnce(userEmail),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user = snapshot.data;

                  if (user != null && !_isChanged) {
                    emailController.text = user.email;
                    usernameController.text = user.username;
                    // nameController.text = user.name;
                    // familyNameController.text = user.familyname;
                  }

                  return user == null
                      ? Center(child: Text('User is empty'))
                      : Column(
                          children: [
                            _buildTextField(
                                'Email', emailController, userEmail),
                            _buildTextField(
                                'Username', usernameController, userEmail),
                          ],
                        );
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
            if (_isChanged)
              ElevatedButton(
                onPressed: () {
                  updateUser(userEmail);
                },
                child: Text('Update'),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        onChanged: (value) {
          setState(() {
            _isChanged = true;
          });
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: UnderlineInputBorder(),
        ),
      ),
    );
  }

  Future<void> updateUser(String userEmail) async {
    final docUser =
        FirebaseFirestore.instance.collection('users').doc(userEmail);
    await docUser.update({
      'email': emailController.text,
      'username': usernameController.text,
    });

    setState(() {
      _isChanged = false;
    });
  }
}
