import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../config/config.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  void fetchUserData() async {
    User user = _auth.currentUser!;
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: _user != null
            ? Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FadeInImage(
                      width: 200,
                      height: 200,
                      image: NetworkImage(_user.photoURL!),
                      placeholder: const AssetImage("assets/placeholder.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${_user.displayName}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(),
                    ),
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        headerAnimationLoop: true,
                        animType: AnimType.bottomSlide,
                        title: 'Log Out',
                        reverseBtnOrder: true,
                        btnOkOnPress: () async {
                          _auth.signOut();
                          await GoogleSignIn().signOut();
                        },
                        btnCancelOnPress: () {},
                        desc: 'Apakah kamu yakin akan melakukan logout?',
                      ).show();
                    },
                    child: const Text("Logout"),
                  ),
                ],
              )
            : const LinearProgressIndicator(),
      ),
    );
  }
}
