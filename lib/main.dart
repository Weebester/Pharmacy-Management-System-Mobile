import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mypharmacy/entry_Screen.dart';
import 'package:mypharmacy/firebase_options.dart';
import 'package:mypharmacy/home_Screen.dart';
import 'package:provider/provider.dart';
import 'api_call_manager.dart';
import 'branch_select_screen.dart';
import 'state_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StateManager()),
        Provider(
            create: (context) =>
                APICaller(Provider.of<StateManager>(context, listen: false))),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StateManager>(
      builder: (context, stateManager, _) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
              useMaterial3: true,
            ),
            home: switch (stateManager.state) {
              1 => HomePage(),
              2 => BranchSS(),
              _ => EntryPage()
            });
      },
    );
  }
}
