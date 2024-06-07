import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/games_screen.dart';
import 'package:intro_mobile_project/screens/reservationsList_screen.dart';
import 'package:intro_mobile_project/screens/fields_screen.dart';

const Color primaryColor = Color.fromARGB(255, 245, 90, 79);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Paddle App'),
        backgroundColor: primaryColor,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(height: 20.0),
          buildButtonWithImage(
            context,
            'assets/images/book.jpg',
            'Book a field',
            const FieldsScreen(),
          ),
          buildButtonWithImage(
            context,
            'assets/images/reservations.jpg',
            'View your reservations',
            const ReservationListScreen(),
          ),
          buildButtonWithImage(
            context,
            'assets/images/playing.jpg',
            'Play a game',
            const GamesScreen(),
          ),
        ],
      ),
    );
  }

  Widget buildButtonWithImage(
      BuildContext context, String imagePath, String text, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0),
              ),
              child: Image.asset(
                imagePath,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0),
                ),
              ),
              padding: const EdgeInsets.all(15.0),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
