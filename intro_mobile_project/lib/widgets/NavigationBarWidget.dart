import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/profile_screen.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({super.key});

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
<<<<<<< HEAD
            builder: (context) => ProfileScreenWidget(),

=======
            builder: (context) => ProfileScreen(),
>>>>>>> parent of 02edd03 (profile_screen)
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: _onItemTapped,
      selectedItemColor: Colors.white,
      backgroundColor: const Color.fromARGB(255, 245, 90, 79),
      unselectedItemColor: Colors.black,
      currentIndex: _selectedIndex,
    );
  }
}
