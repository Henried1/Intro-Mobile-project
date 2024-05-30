import 'package:flutter/material.dart';
import 'package:intro_mobile_project/screens/home_screen.dart';
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
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
        break;
    }
    switch (index) {
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreenWidget(),
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

// import 'package:flutter/material.dart';
// import 'package:intro_mobile_project/screens/home_screen.dart';
// import 'package:intro_mobile_project/screens/profile_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:intro_mobile_project/providers/navigation_provider.dart';

// class NavigationBar extends StatefulWidget {
//   const NavigationBar({super.key});
//   @override
//   _NavigationBarState createState() => _NavigationBarState();
// }

// class _NavigationBarState extends State<NavigationBar> {
//   void _onItemTapped(int index) {
//     Provider.of<NavigationProvider>(context, listen: false).setIndex(index);
//     switch (index) {
//       case 0:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const HomeScreen(),
//           ),
//         );
//         break;
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const ProfileScreenWidget(),
//           ),
//         );
//         break;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final selectedIndex =
//         Provider.of<NavigationProvider>(context).selectedIndex;
//     return BottomNavigationBar(
//       currentIndex: selectedIndex,
//       items: const <BottomNavigationBarItem>[
//         BottomNavigationBarItem(
//           icon: Icon(Icons.explore),
//           label: 'Explore',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.search),
//           label: 'Search',
//         ),
//         // Add more items as needed
//       ],
//       onTap: _onItemTapped,
//     );
//   }
// }
