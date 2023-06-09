import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wallyhub/pages/homepage.dart';
import 'package:wallyhub/pages/signin_screen.dart';
import 'package:wallyhub/pages/splash_screen.dart';
import 'config/config.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: primaryColor,
        fontFamily: "productsans",
        useMaterial3: true,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (ctx, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          User user = snapshot.data;
          if (user != null) {
            return const HomePage();
          } else {
            return const SignInScreen();
          }
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
