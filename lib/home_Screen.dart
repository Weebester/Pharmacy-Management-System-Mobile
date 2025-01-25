import 'package:flutter/material.dart';
import 'package:mypharmacy/profile_page.dart';
import 'package:provider/provider.dart';
import 'state_manager.dart';
import 'med_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Initial index, starts at the ProfilePage
  final List<Widget> _pages = [
    ProfilePage(),
    MedPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<StateManager>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        title: Row(
          children: [
            Image.asset(
              "Assets/LOGO.png",
              height: 40,
            ),
            SizedBox(width: 10),
            Text("MyPharmacy")
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authProvider.logout,
            tooltip: "Log Out",
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Start from the right
              end: Offset.zero, // End at the current position
            ).animate(animation),
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Switch pages on tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_sharp),
            label: 'Medicine\nDictionary',
          ),
        ],
      ),
    );
  }
}
