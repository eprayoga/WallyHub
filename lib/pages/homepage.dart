import 'package:flutter/material.dart';
import 'package:wallyhub/config/config.dart';
import 'package:wallyhub/pages/accountpage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:wallyhub/pages/favoritespage.dart';
import 'package:wallyhub/pages/mywallpaperpage.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'explorepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  final _pages = [
    const ExplorePage(),
    const FavoritesPage(),
    const MyWallpaperPage(),
    const AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WallyHub"),
        actions: [
          IconButton(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  headerAnimationLoop: true,
                  animType: AnimType.scale,
                  title: 'Info Aplikasi',
                  desc:
                      'Aplikasi ini dibuat oleh Endang Prayoga Hidayatulloh dari Institut Teknologi Garut Prodi Teknik Informatika 2020, dengan NIM 2006189. Aplikasi ini ditujukan untuk memenuhi Tugas Akhir Mata Kuliah Pemrograman Mobile.',
                  showCloseIcon: true,
                ).show();
              },
              icon: const Icon(
                Icons.info,
              ))
        ],
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: GNav(
        gap: 10,
        tabBackgroundColor: Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        activeColor: secondaryColor,
        tabs: const [
          GButton(
            icon: Icons.search,
            text: "Jelajahi",
          ),
          GButton(
            icon: Icons.favorite_border,
            text: "Favorit",
          ),
          GButton(
            icon: Icons.image,
            text: "Wallpaper Saya",
          ),
          GButton(
            icon: Icons.person_outline,
            text: "Akun",
          ),
        ],
        onTabChange: (value) {
          setState(() {
            _selectedPageIndex = value;
          });
        },
      ),
    );
  }
}
