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
        automaticallyImplyLeading: false, // This removes the back button
        title: Text('Paddle App'),
        backgroundColor: Color.fromARGB(255, 245, 90, 79),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20.0, right: 20.0),
              child: ElevatedButton(
                child: const Text("log out"),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Logged out");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignInScreen()),
                    );
                  });
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(20.0),
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.redAccent, // Set the color of the square
              borderRadius:
                  BorderRadius.circular(20.0), // Make the square rounded
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(
                Icons.sports_tennis_rounded,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              const Text(
                'Book a field',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
            ]),
          ),
        ],
      ),
      bottomNavigationBar:
          customNavBar.NavigationBar(), // Use NavigationBar widget
    );
  }
}
