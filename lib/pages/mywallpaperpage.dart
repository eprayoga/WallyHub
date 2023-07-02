import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyhub/pages/add_wallpaper_screen.dart';
import 'package:wallyhub/pages/wallpaper_view_screen.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import '../config/config.dart';

class MyWallpaperPage extends StatefulWidget {
  const MyWallpaperPage({super.key});

  @override
  State<MyWallpaperPage> createState() => _MyWallpaperPageState();
}

class _MyWallpaperPageState extends State<MyWallpaperPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: _user != null
            ? Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, top: 3, bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wallpaper Saya",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddWallpaperScreen(),
                                  fullscreenDialog: true,
                                ));
                          },
                          child: Row(
                            children: [Icon(Icons.add), Text("Tambah Foto")],
                          ),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: _db
                        .collection("photos")
                        .where('uploaded_by', isEqualTo: _user.uid)
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
                              return InkWell(
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
                                child: Stack(
                                  children: [
                                    Hero(
                                      tag:
                                          snapshot.data?.docs[index].get("url"),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          placeholder: (ctx, url) => Image(
                                            image: AssetImage(
                                                "assets/placeholder.jpg"),
                                          ),
                                          imageUrl: snapshot.data?.docs[index]
                                              .get("url"),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.warning,
                                          headerAnimationLoop: true,
                                          animType: AnimType.scale,
                                          title: 'Confirmation',
                                          reverseBtnOrder: true,
                                          btnOkOnPress: () {
                                            _db
                                                .collection("photos")
                                                .doc(snapshot
                                                    .data?.docs[index].id)
                                                .delete();

                                            AwesomeDialog(
                                              context: context,
                                              animType: AnimType.scale,
                                              headerAnimationLoop: false,
                                              dialogType: DialogType.success,
                                              showCloseIcon: true,
                                              title: 'Succes',
                                              desc: 'successful delete photo',
                                              btnOkOnPress: () {
                                                debugPrint('OnClcik');
                                              },
                                              btnOkIcon: Icons.check_circle,
                                              onDismissCallback: (type) {
                                                debugPrint(
                                                    'Dialog Dissmiss from callback $type');
                                              },
                                            ).show();
                                          },
                                          btnCancelOnPress: () {},
                                          desc:
                                              'Are you sure, you are deleting photo?',
                                        ).show();
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Kamu tidak memiliki Foto,\nayo upload Foto terbaik kamu!",
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddWallpaperScreen(),
                                            fullscreenDialog: true,
                                          ));
                                    },
                                    child: Text("Tambah Foto"))
                              ],
                            ),
                          );
                        }
                      }
                      return SpinKitChasingDots(
                        color: primaryColor,
                        size: 50,
                      );
                    },
                  ),
                  SizedBox(
                    height: 80,
                  ),
                ],
              )
            : LinearProgressIndicator(),
      ),
    );
  }
}
