import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:wallyhub/config/config.dart';
import 'package:wallyhub/services/firebase_auth_service.dart';

class WallpaperViewPage extends StatefulWidget {
  const WallpaperViewPage({super.key, required this.data});

  final DocumentSnapshot data;

  @override
  State<WallpaperViewPage> createState() => _WallpaperViewPageState();
}

class _WallpaperViewPageState extends State<WallpaperViewPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    List<dynamic> tags = widget.data.get("tags").toList();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Hero(
                  tag: widget.data.get("url"),
                  child: CachedNetworkImage(
                    placeholder: (ctx, url) => Image(
                      image: AssetImage("assets/placeholder.jpg"),
                    ),
                    imageUrl: widget.data.get("url"),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Wrap(
                  spacing: 10,
                  children: tags.map((tag) {
                    return Chip(
                      label: Text(tag.toString()),
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Wrap(spacing: 10, children: [
                  ElevatedButton.icon(
                    onPressed: _launchURL,
                    icon: Icon(Icons.download),
                    label: Text("Download"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text("Share"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addToFavorite,
                    icon: Icon(Icons.favorite_border),
                    label: Text("Favorite"),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL() async {
    try {
      await launch(
        widget.data["url"],
        customTabsOption: CustomTabsOption(
          toolbarColor: primaryColor,
          enableUrlBarHiding: true,
          showPageTitle: true,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void _addToFavorite() async {
    User user = await _auth.currentUser!;

    String uid = user.uid;

    final Map<String, dynamic> data =
        Map<String, dynamic>.from(widget.data.data() as Map);

    _db
        .collection("users")
        .doc(uid)
        .collection("favorites")
        .doc(widget.data.id)
        .set(data);
  }
}
