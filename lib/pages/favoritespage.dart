import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyhub/pages/homepage.dart';
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
                "Favorit",
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
                    if (snapshot.data!.docs.isNotEmpty) {
                      return StaggeredGridView.countBuilder(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        staggeredTileBuilder: (int index) =>
                            StaggeredTile.fit(1),
                        itemCount: snapshot.data?.docs.length,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        itemBuilder: (ctx, index) {
                          return Stack(
                            children: [
                              InkWell(
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
                                        image: AssetImage(
                                            "assets/placeholder.jpg"),
                                      ),
                                      imageUrl:
                                          snapshot.data?.docs[index].get("url"),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: StreamBuilder(
                                  stream: _db
                                      .collection("users")
                                      .where("uid",
                                          isEqualTo: snapshot.data?.docs[index]
                                              .get("uploaded_by"))
                                      .snapshots(),
                                  builder: (ctx,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: FadeInImage(
                                              width: 20,
                                              height: 20,
                                              image: NetworkImage(snapshot
                                                  .data!.docs[0]
                                                  .get("photoUrl")),
                                              placeholder: AssetImage(
                                                  "assets/placeholder.jpg"),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 7,
                                          ),
                                          Text(
                                            snapshot.data!.docs[0]
                                                .get("displayName"),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height - 280,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image(
                              image: AssetImage("assets/no_data.png"),
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Kamu belum memiliki favorit,\nayo jelajahi foto terlebih dahulu!",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
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
