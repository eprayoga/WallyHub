import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WallpaperViewPage extends StatefulWidget {
  const WallpaperViewPage({super.key, required this.data});

  final DocumentSnapshot data;

  @override
  State<WallpaperViewPage> createState() => _WallpaperViewPageState();
}

class _WallpaperViewPageState extends State<WallpaperViewPage> {
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
                    onPressed: () {},
                    icon: Icon(Icons.image),
                    label: Text("Set as wallpaper"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text("Share"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
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
}
