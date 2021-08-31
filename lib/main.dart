import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'Services/DatabaseHelper.dart';
import 'package:quote/view/Homepage.dart';
import 'Services/SqlServices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  dbHelper.getDatabase; // data base initialize
  SqlServices().mopubInit();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (context) {
      runApp(MyApp());
    },
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SqlServices>(
      create: (context) => SqlServices(),
      child: MaterialApp(
        title: 'Lessons in Life',
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        theme: ThemeData(primaryColor: Colors.purple[900]),
      ),
    );
  }
}
