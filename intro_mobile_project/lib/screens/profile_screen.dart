import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/screens/edit_profile_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as customNavBar;

class ProfileScreenWidget extends StatefulWidget {
  const ProfileScreenWidget({super.key});

  @override
  State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
}

class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String username = 'Loading...';
  String email = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.email != null) {
      print(
          "Fetching profile for user with email: ${user.email}"); // Debug print
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        print("User document data: ${userDoc.data()}"); // Debug print
        setState(() {
          username = userDoc['Username'] ?? 'No Username';
          email = userDoc['Email'] ?? 'No Email';
        });
      } else {
        print("User profile not found"); // Debug print
        setState(() {
          username = 'User profile not found';
          email = 'User profile not found';
        });
      }
    } else {
      print("No user is currently signed in or email is null"); // Debug print
      setState(() {
        username = 'No user is signed in';
        email = 'No user is signed in';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          currentFocus.focusedChild!.unfocus();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.white,
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
              offset: const Offset(0, 60),
              onSelected: (String result) async {
                switch (result) {
                  case 'About':
                    showAboutDialog(
                      context: context,
                      applicationName: 'Paddle App',
                      applicationVersion: '1.0.0',
                    );
                    break;
                  case 'Edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfileScreen()),
                    );
                    break;

                  case 'Log out':
                    await FirebaseAuth.instance.signOut();
                    print("Logged out");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'About',
                  child: Text('About'),
                ),
                const PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem<String>(
                  value: 'Log out',
                  child: Text('Log out'),
                ),
              ],
            ),
          ],
          centerTitle: false,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 450.0,
                height: 133.0,
                decoration: BoxDecoration(
                  color: Colors.white,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    alignment: AlignmentDirectional(0.0, -1.0),
                    image: Image.asset(
                      'assets/images/tennis-field-outdoor-illustration-background.jpg',
                    ).image,
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Align(
                  alignment: AlignmentDirectional(0.0, 1.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.width * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 5.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 150.0,
                        height: 156.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Column(
                    children: [
                      Text(
                        'username',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        email,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: customNavBar.NavigationBar(),
      ),
    );
  }
}



// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intro_mobile_project/screens/signin_screen.dart';
// import 'package:intro_mobile_project/screens/edit_profile_screen.dart';

// import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
//     as customNavBar;

// class ProfileScreenWidget extends StatefulWidget {
//   const ProfileScreenWidget({super.key});

//   @override
//   State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
// }

// class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScopeNode currentFocus = FocusScope.of(context);

//         if (!currentFocus.hasPrimaryFocus &&
//             currentFocus.focusedChild != null) {
//           currentFocus.focusedChild!.unfocus();
//         }
//       },
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 245, 90, 79),
//           automaticallyImplyLeading: false,
//           title: const Text(
//             'Profile',
//             style: TextStyle(color: Colors.black),
//           ),
//           actions: [
//             PopupMenuButton<String>(
//               icon: const Icon(
//                 Icons.more_vert,
//                 color: Colors.black,
//                 size: 30.0,
//               ),
//               offset: const Offset(0, 60),
//               onSelected: (String result) async {
//                 switch (result) {
//                   case 'About':
//                     showAboutDialog(
//                       context: context,
//                       applicationName: 'Paddle App',
//                       applicationVersion: '1.0.0',
//                     );
//                     break;
//                   case 'Edit':
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => EditProfileScreen()),
//                     );
//                     break;

//                   case 'Log out':
//                     await FirebaseAuth.instance.signOut();
//                     print("Logged out");
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const SignInScreen()),
//                     );
//                     break;
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 const PopupMenuItem<String>(
//                   value: 'About',
//                   child: Text('About'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'Edit',
//                   child: Text('Edit'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'Log out',
//                   child: Text('Log out'),
//                 ),
//               ],
//             ),
//           ],
//           centerTitle: false,
//           elevation: 2.0,
//         ),
//         body: SafeArea(
//           top: true,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Container(
//                 width: 450.0,
//                 height: 133.0,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   image: DecorationImage(
//                     fit: BoxFit.fitWidth,
//                     alignment: AlignmentDirectional(0.0, -1.0),
//                     image: Image.asset(
//                       'assets/images/tennis-field-outdoor-illustration-background.jpg',
//                     ).image,
//                   ),
//                   shape: BoxShape.rectangle,
//                 ),
//                 child: Align(
//                   alignment: AlignmentDirectional(0.0, 1.0),
//                   child: Container(
//                     width: MediaQuery.sizeOf(context).width * 0.3,
//                     height: MediaQuery.sizeOf(context).width * 0.3,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 5.0,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(50.0),
//                       child: Image.asset(
//                         'assets/images/logo.png',
//                         width: 150.0,
//                         height: 156.0,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Align(
//                 alignment: AlignmentDirectional(0.0, 0.0),
//                 child: Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
//                   child: Text(
//                     data['username'] ?? 'Unknown Username',
//                     style: TextStyle(fontSize: 25, color: Colors.black),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: customNavBar.NavigationBar(),
//       ),
//     );
//   }
// }
//###############################################################
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intro_mobile_project/screens/signin_screen.dart';
// import 'package:intro_mobile_project/screens/edit_profile_screen.dart';
// import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
//     as customNavBar;

// class ProfileScreenWidget extends StatefulWidget {
//   const ProfileScreenWidget({super.key});

//   @override
//   State<ProfileScreenWidget> createState() => _ProfileScreenWidgetState();
// }

// class _ProfileScreenWidgetState extends State<ProfileScreenWidget> {
//   final String? userEmail = FirebaseAuth.instance.currentUser?.email;
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   String username = 'Loading...';
//   String email = 'Loading...';

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserProfile();
//   }

//   Future<void> _fetchUserProfile() async {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       DocumentSnapshot userDoc =
//           await FirebaseFirestore.instance.collection('Users').doc(email).get();

//       if (userDoc.exists) {
//         setState(() {
//           username = userDoc['username'] ?? 'No Username';
//           email = userDoc['email'] ?? 'No Email';
//         });
//       } else {
//         setState(() {
//           username = 'User profile not found';
//           email = 'User profile not found';
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScopeNode currentFocus = FocusScope.of(context);
//         if (!currentFocus.hasPrimaryFocus &&
//             currentFocus.focusedChild != null) {
//           currentFocus.focusedChild!.unfocus();
//         }
//       },
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color.fromARGB(255, 245, 90, 79),
//           automaticallyImplyLeading: false,
//           title: const Text(
//             'Profile',
//             style: TextStyle(color: Colors.black),
//           ),
//           actions: [
//             PopupMenuButton<String>(
//               icon: const Icon(
//                 Icons.more_vert,
//                 color: Colors.black,
//                 size: 30.0,
//               ),
//               offset: const Offset(0, 60),
//               onSelected: (String result) async {
//                 switch (result) {
//                   case 'About':
//                     showAboutDialog(
//                       context: context,
//                       applicationName: 'Paddle App',
//                       applicationVersion: '1.0.0',
//                     );
//                     break;
//                   case 'Edit':
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => EditProfileScreen()),
//                     );
//                     break;

//                   case 'Log out':
//                     await FirebaseAuth.instance.signOut();
//                     print("Logged out");
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const SignInScreen()),
//                     );
//                     break;
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 const PopupMenuItem<String>(
//                   value: 'About',
//                   child: Text('About'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'Edit',
//                   child: Text('Edit'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'Log out',
//                   child: Text('Log out'),
//                 ),
//               ],
//             ),
//           ],
//           centerTitle: false,
//           elevation: 2.0,
//         ),
//         body: SafeArea(
//           top: true,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Container(
//                 width: 450.0,
//                 height: 133.0,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   image: DecorationImage(
//                     fit: BoxFit.fitWidth,
//                     alignment: AlignmentDirectional(0.0, -1.0),
//                     image: Image.asset(
//                       'assets/images/tennis-field-outdoor-illustration-background.jpg',
//                     ).image,
//                   ),
//                   shape: BoxShape.rectangle,
//                 ),
//                 child: Align(
//                   alignment: AlignmentDirectional(0.0, 1.0),
//                   child: Container(
//                     width: MediaQuery.of(context).size.width * 0.3,
//                     height: MediaQuery.of(context).size.width * 0.3,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.white,
//                         width: 5.0,
//                       ),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(50.0),
//                       child: Image.asset(
//                         'assets/images/logo.png',
//                         width: 150.0,
//                         height: 156.0,
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Align(
//                 alignment: AlignmentDirectional(0.0, 0.0),
//                 child: Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
//                   child: Column(
//                     children: [
//                       Text(
//                         username,
//                         style: TextStyle(fontSize: 25, color: Colors.black),
//                       ),
//                       Text(
//                         email,
//                         style: TextStyle(fontSize: 15, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         bottomNavigationBar: customNavBar.NavigationBar(),
//       ),
//     );
//   }
// }
