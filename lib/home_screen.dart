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
        return response.data;
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
    final apiCaller = Provider.of<APICaller>(context);

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
                // Show the AlertDialog to change the password
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController oldPasswordController =
                        TextEditingController();
                    TextEditingController newPasswordController =
                        TextEditingController();
                    TextEditingController confirmPasswordController =
                        TextEditingController();

                    return AlertDialog(
                      title: Text("Change Password"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: oldPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Old Password',
                              hintText: 'Enter your old password',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'New Password',
                              hintText: 'Enter a new password',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Confirm New Password',
                              hintText: 'Confirm your new password',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            // Close the dialog
                            Navigator.of(context).pop();
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            String oldPassword = oldPasswordController.text;
                            String newPassword = newPasswordController.text;
                            String confirmPassword =
                                confirmPasswordController.text;

                            if (newPassword != confirmPassword) {
                              // Show error if new passwords don't match
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text("New passwords don't match")),
                              );
                              return;
                            }

                            try {
                              await userState.changePassword(
                                  oldPassword, newPassword);

                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Password changed successfully!")),
                                );
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Error: ${e.toString()}")),
                                );
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Text("Change Password"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.message_outlined),
              title: Text('Submit a Ticket'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    TextEditingController message = TextEditingController();
                    return AlertDialog(
                      title: Text('Submit a Ticket'),
                      content: TextField(
                        controller: message,
                        decoration: InputDecoration(
                          labelText: 'Message',
                          hintText: 'Describe your issue',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        maxLines: 5,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Cancel
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            String route =
                                "$serverAddress/newticket"; // Endpoint for inserting item
                            Map<String, dynamic> requestBody = {
                              "Content": message.text,
                              "PharmaIndex": userState.pharmaIndex
                            };
                            try {
                              await apiCaller.post(route, requestBody);

                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Ticket submitted successfully!")),
                                );
                                Navigator.of(context).pop();
                              });
                            } catch (e) {
                              SchedulerBinding.instance
                                  .addPostFrameCallback((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Error: failed to submit a ticket")),
                                );
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            if (userState.decodeToken()["Manager"] == "Yes")
              FutureBuilder<List>(
                future: fetchBranches(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
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
