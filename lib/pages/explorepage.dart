import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyhub/config/config.dart';
import 'package:wallyhub/pages/wallpaper_view_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: const EdgeInsets.only(top: 3, left: 20, bottom: 20),
              child: const Text(
                "Jelajahi",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            StreamBuilder(
              stream: _db
                  .collection("photos")
                  .orderBy("date", descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    staggeredTileBuilder: (int index) =>
                        const StaggeredTile.fit(1),
                    itemCount: snapshot.data?.docs.length,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: snapshot.data?.docs[index].get("url"),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  placeholder: (ctx, url) => const Image(
                                    image: AssetImage("assets/placeholder.jpg"),
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
                              builder:
                                  (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          placeholder: const AssetImage(
                                              "assets/placeholder.jpg"),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        snapshot.data!.docs[0]
                                            .get("displayName"),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
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
                }
                return SizedBox(
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
            const SizedBox(
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}
