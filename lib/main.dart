import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mypharmacy/entry_screen.dart';
import 'package:mypharmacy/firebase_options.dart';
import 'package:mypharmacy/home_screen.dart';
import 'package:provider/provider.dart';
import 'Bill.dart';
import 'api_call_manager.dart';
import 'custom_widgets_&_utility.dart';
import 'user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final bool isDarkMode = await ThemePreferences().loadTheme();
  final userState = UserState();
  await userState.initializeUser();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => userState),
        ChangeNotifierProvider(create: (context) => BillState()),
        Provider(
            create: (context) =>
                APICaller(Provider.of<UserState>(context, listen: false))),
      ],
      child: MyApp(
        isDarkMode: isDarkMode,
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  const MyApp({super.key, required this.isDarkMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });
    await ThemePreferences().saveTheme(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, _) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyPharmacy',
            theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
            home: switch (userState.state) {
              1 => HomePage(onToggleTheme: toggleTheme),
              _ => EntryPage(isDarkMode: isDarkMode)
            });
      },
    );
  }
}
