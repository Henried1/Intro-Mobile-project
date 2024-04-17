import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as customNavBar;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Paddle App'),
        backgroundColor: Colors.redAccent,
      ),
      backgroundColor: Colors.white,
      body: Container(
        alignment: Alignment.topRight,
        child: Padding(
          padding: EdgeInsets.only(top: 0.0),
          child: ElevatedButton(
            child: const Text("log out"),
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                print("Logged out");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              });
            },
          ),
        ),
      ),
      bottomNavigationBar:
          customNavBar.NavigationBar(), // Use NavigationBar widget
    );
  }
}
