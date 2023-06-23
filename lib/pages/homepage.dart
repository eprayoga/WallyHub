import 'package:flutter/material.dart';
import 'package:wallyhub/pages/accountpage.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:wallyhub/pages/favoritespage.dart';
import 'package:wallyhub/pages/mywallpaperpage.dart';

import 'explorepage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedPageIndex = 0;

  var _pages = [
    ExplorePage(),
    FavoritesPage(),
    MyWallpaperPage(),
    AccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WallyHub"),
      ),
      body: _pages[_selectedPageIndex],
      bottomNavigationBar: GNav(
        gap: 10,
        tabBackgroundColor: Colors.grey.shade800,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        tabs: [
          GButton(
            icon: Icons.search,
            text: "Explore",
          ),
          GButton(
            icon: Icons.favorite_border,
            text: "Favorite",
          ),
          GButton(
            icon: Icons.image,
            text: "My Wallpaper",
          ),
          GButton(
            icon: Icons.person_outline,
            text: "Account",
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
