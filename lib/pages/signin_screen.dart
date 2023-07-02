import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wallyhub/config/config.dart';

import '../services/firebase_auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool inLogin = false;

  Future<void> _loginGoogle() async {
    setState(() {
      inLogin = true;
    });
    await FirebaseAuthService().signInWithGoogle();

    setState(() {
      inLogin = false;
    });

    final user = FirebaseAuthService().user;

    _db.collection("users").doc(user.uid).set({
      "displayName": user.displayName,
      "email": user.email,
      "uid": user.uid,
      "photoUrl": user.photoURL,
      "lastSignIn": DateTime.now()
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Image(
              image: const AssetImage("assets/bg2.jpg"),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              width: MediaQuery.of(context).size.width,
              child: const Image(
                image: AssetImage("assets/logo_circle.png"),
                width: 200,
                height: 200,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF000000),
                    Color(0X00000000),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: InkWell(
                  onTap: _loginGoogle,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "Google Sign in",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            inLogin
                ? Container(
                    color: Colors.black54,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: SpinKitChasingDots(
                        color: primaryColor,
                        size: 80,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
