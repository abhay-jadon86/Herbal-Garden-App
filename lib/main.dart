import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:herbal_garden_app/theme_based/homepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:herbal_garden_app/theme_based/loginpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "My Herbal Garden",
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFF1D2428),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF32CD32)),
              ),
            );
          }
          if (snapshot.hasData) {
            return const MyHomePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}