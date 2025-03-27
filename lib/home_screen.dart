import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mypharmacy/assistance_manage.dart';
import 'package:mypharmacy/item_list_page.dart';
import 'package:mypharmacy/profile_page.dart';
import 'package:mypharmacy/sell_page.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'user_state.dart';
import 'med_list_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({super.key, required this.onToggleTheme});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List> fetchBranches() async {
    String route = "$serverAddress/branches";

    try {
      final apiCaller = context.read<APICaller>();
      final response = await apiCaller.get(route);

      if (response.statusCode == 200) {
        return response.data; // Return the list of branches
      } else {
        throw Exception('Failed to load branches');
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      ProfilePage(),
      MedPage(),
      ItemPage(),
      SellPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Text("Home"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration:
                    BoxDecoration(color: Theme.of(context).colorScheme.primary),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Options Menu ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dark_mode),
              title: Text('Toggle DarkMode'),
              onTap: widget.onToggleTheme,
            ),
            ListTile(
              leading: Icon(Icons.key),
              title: Text('Change Password'),
              onTap: () {
                // changePassWord action
              },
            ),
            ListTile(
              leading: Icon(Icons.message_outlined),
              title: Text('Submit a Ticket'),
              onTap: () {
                // Ticket action
              },
            ),
            if (userState.decodeToken()["Manager"] == "Yes")
              FutureBuilder<List>(
                future: fetchBranches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Show loading state
                  } else if (snapshot.hasError) {
                    return ListTile(title: Text('Error fetching branches'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListTile(title: Text('No branches available'));
                  } else {
                    return ExpansionTile(
                      title: Text("branches"),
                      leading: Icon(Icons.list_alt),
                      children: List.generate(snapshot.data!.length, (index) {
                        return ListTile(
                          title: Text(snapshot.data![index]),
                          leading: Icon(Icons.arrow_right),
                          onTap: () {
                            userState.changeIndex(index);
                            setState(() {
                              _selectedIndex = 0;
                            });
                          },
                        );
                      }),
                    );
                  }
                },
              ),
            if (userState.decodeToken()["Manager"] == "Yes")
              ListTile(
                leading: Icon(Icons.accessibility),
                title: Text('Mange Assistants'),
                onTap: () async {
                  List br = await fetchBranches();
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssistantManage(br: br),
                      ),
                    );
                  });
                },
              ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: userState.logout,
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // Switch pages on tap
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_sharp),
            label: 'Dictionary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sell),
            label: 'Bill',
          ),
        ],
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withValues(),
      ),
    );
  }
}
