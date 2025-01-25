import 'package:flutter/material.dart';
import 'package:mypharmacy/signup_page.dart';
import 'login_page.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  EntryPageState createState() => EntryPageState();
}

class EntryPageState extends State<EntryPage> {
  int _selectedIndex = 0; // Initial index, starts at the ProfilePage
  final List<Widget> _pages = [
    LoginPage(),
    SignupPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

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
            icon: Icon(Icons.login),
            label: 'Login',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Signup',
          ),
        ],
      ),
    );
  }
}
