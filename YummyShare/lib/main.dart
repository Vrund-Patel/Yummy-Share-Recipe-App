import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yummyshare/firebase_options.dart';
import 'package:yummyshare/views/screens/auth/welcome_page.dart';
import 'package:yummyshare/views/screens/home_page.dart';
import 'package:yummyshare/models/helper/local_notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationHelper().initNotification();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Open Sans',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: WelcomePage(),
      routes: {
        '/home': (context) => HomePage(),
      },
    );
  }
}
