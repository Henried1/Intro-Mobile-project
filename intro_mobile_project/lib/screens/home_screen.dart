import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/public_games_screen.dart';
import 'package:intro_mobile_project/screens/reservationsList_screen.dart';
import 'package:intro_mobile_project/screens/signin_screen.dart';
import 'package:intro_mobile_project/widgets/NavigationBarWidget.dart'
    as customNavBar;
import 'package:intro_mobile_project/screens/fields_screen.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

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
        title: const Text('Paddle App'),
        backgroundColor: primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20.0),
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
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FieldsScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_tennis_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Book a field',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ReservationListScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'View your reservations',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PublicMatchesScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.public_rounded,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    'View Public Games',
                    style: TextStyle(fontSize: 24.0, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: customNavBar.NavigationBar(),
    );
  }
}
