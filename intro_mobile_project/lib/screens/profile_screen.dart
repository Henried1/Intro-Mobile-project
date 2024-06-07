import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/screens/edit_profile_screen.dart';
import 'package:url_launcher/url_launcher_string.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['Username'] ?? 'No Username';
          email = userDoc['Email'] ?? 'No Email';
        });
      } else {
        setState(() {
          username = 'User profile not found';
          email = 'User profile not found';
        });
      }
    } else {
      setState(() {
        username = 'No user is signed in';
        email = 'No user is signed in';
      });
    }
  }

  void _handleProfileUpdate() {
    _fetchUserProfile();
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
                          builder: (context) => EditProfileScreen(
                                onProfileUpdated: _handleProfileUpdate,
                              )),
                    );
                    break;

                  case 'Log out':
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                      (Route<dynamic> route) => false,
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
                    alignment: const AlignmentDirectional(0.0, -1.0),
                    image: Image.asset(
                      'assets/images/tennis-field-outdoor-illustration-background.jpg',
                    ).image,
                  ),
                  shape: BoxShape.rectangle,
                ),
                child: Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
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
                    child: CircleAvatar(
                      child: Text(
                        username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 50.0),
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 0.0),
                  child: Column(
                    children: [
                      Text(
                        username,
                        style:
                            const TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      Text(
                        email,
                        style:
                            const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
              GestureDetector(
                onTap: () async {
                  const url =
                      'https://docs.google.com/forms/d/e/1FAIpQLSdozt0pcXY7Jech1quq9E6EmDlth4ATEsXaJJkmJkIoH1-Xvg/viewform?usp=sf_link';
                  await launchUrlString(url);
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Feedback',
                        style: TextStyle(fontSize: 24.0, color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20),
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Log out',
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
