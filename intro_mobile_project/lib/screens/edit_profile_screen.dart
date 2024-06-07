import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/screens/profile_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as customNavBar;

class EditProfileScreen extends StatefulWidget {
  final VoidCallback onProfileUpdated;

  const EditProfileScreen({Key? key, required this.onProfileUpdated})
      : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();

      setState(() {
        emailController.text = userDoc['Email'];
        usernameController.text = userDoc['Username'];
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .update({
        'Email': emailController.text,
        'Username': usernameController.text,
      });

      widget.onProfileUpdated();

      setState(() {
        _isChanged = false;
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 90, 79),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 30.0,
            ),
            offset: const Offset(0, 60),
            onSelected: (String result) async {
              switch (result) {
                case 'Log out':
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Log out',
                child: Text('Log out'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              onChanged: (value) {
                setState(() {
                  _isChanged = true;
                });
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _isChanged = true;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isChanged ? _updateProfile : null,
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
