// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intro_mobile_project/service/database.dart';
// import 'package:provider/provider.dart';
// import 'package:intro_mobile_project/model/user_logged_controller.dart';
// import 'package:intro_mobile_project/model/user_account.dart';
// import 'package:intro_mobile_project/model/user_service.dart';
// import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart' as customNavBar;

// class EditProfileScreen extends StatefulWidget {
//   @override
//   _EditProfileScreenState createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   TextEditingController emailController = TextEditingController();
//   TextEditingController usernameController = TextEditingController();
//   bool _isChanged = false;

//   @override
//   Widget build(BuildContext context) {
//     final userLogged = Provider.of<UserLogged>(context);
//     final userEmail = userLogged.email.trim();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Edit Profile"),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             FutureBuilder<UserAccount?>(
//               future: readUserOnce(userEmail),
//               builder: (context, snapshot) {
//                 if (snapshot.hasData) {
//                   final user = snapshot.data;

//                   if (user != null && !_isChanged) {
//                     emailController.text = user.email;
//                     usernameController.text = user.username;
//                     // nameController.text = user.name;
//                     // familyNameController.text = user.familyname;
//                   }

//                   return user == null
//                       ? Center(child: Text('User is empty'))
//                       : Column(
//                           children: [
//                             _buildTextField(
//                                 'Email', emailController, userEmail),
//                             _buildTextField(
//                                 'Username', usernameController, userEmail),
//                           ],
//                         );
//                 } else {
//                   return CircularProgressIndicator();
//                 }
//               },
//             ),
//             if (_isChanged)
//               ElevatedButton(
//                 onPressed: () {
//                   updateUser(userEmail);
//                 },
//                 child: Text('Update'),
//               )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       String label, TextEditingController controller, String hintText) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: TextField(
//         controller: controller,
//         onChanged: (value) {
//           setState(() {
//             _isChanged = true;
//           });
//         },
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hintText,
//           border: UnderlineInputBorder(),
//         ),
//       ),
//     );
//   }

//   Future<void> updateUser(String userEmail) async {
//     final docUser =
//         FirebaseFirestore.instance.collection('users').doc(userEmail);
//     await docUser.update({
//       'email': emailController.text,
//       'username': usernameController.text,
//     });

//     setState(() {
//       _isChanged = false;
//     });
//   }
// }
//
//###########################################################################################

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intro_mobile_project/service/database.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as customNavBar;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        emailController.text = userDoc['email'];
        usernameController.text = userDoc['username'];
        // familyNameController.text = userDoc['familyName'];
      });
    }
  }

  Future<void> _updateProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .update({
        'Email': emailController.text,
        'Username': usernameController.text,
        // 'familyName': familyNameController.text,
      });
      setState(() {
        _isChanged = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 90, 79),
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 30.0,
            ),
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
              decoration: InputDecoration(labelText: 'First Name'),
              onChanged: (value) {
                setState(() {
                  _isChanged = true;
                });
              },
            ),
            // TextFormField(
            //   controller: usernameController,
            //   decoration: InputDecoration(labelText: 'Family Name'),
            //   onChanged: (value) {
            //     setState(() {
            //       _isChanged = true;
            //     });
            //   },
            // ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _isChanged = true;
                });
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isChanged ? _updateProfile : null,
              child: Text('Update Profile'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: customNavBar.NavigationBar(),
    );
  }
}
