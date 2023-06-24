import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyhub/pages/wallpaper_view_screen.dart';

import '../config/config.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? user;

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  void _getUser() async {
    User u = await _auth.currentUser!;
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 3, left: 20, bottom: 20),
              child: Text(
                "Favorites",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            if (user != null) ...[
              StreamBuilder(
                stream: _db
                    .collection("users")
                    .doc(user?.uid)
                    .collection("favorites")
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return StaggeredGridView.countBuilder(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                      itemCount: snapshot.data?.docs.length,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WallpaperViewPage(
                                  data: snapshot.data!.docs[index],
                                  fav: true,
                                ),
                              ),
                            );
                          },
                          child: Hero(
                            tag: snapshot.data?.docs[index].get("url"),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                placeholder: (ctx, url) => Image(
                                  image: AssetImage("assets/placeholder.jpg"),
                                ),
                                imageUrl: snapshot.data?.docs[index].get("url"),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Container(
                    height: MediaQuery.of(context).size.width,
                    child: Center(
                      child: SpinKitChasingDots(
                        color: primaryColor,
                        size: 50,
                      ),
                    ),
                  );
                },
              ),
            ]
          ],
        ),
      ),
    );
  }
}
