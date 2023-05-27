import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class WallpaperViewPage extends StatefulWidget {
  const WallpaperViewPage({super.key, required this.image});

  final String image;

  @override
  State<WallpaperViewPage> createState() => _WallpaperViewPageState();
}

class _WallpaperViewPageState extends State<WallpaperViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                child: Hero(
                  tag: widget.image,
                  child: CachedNetworkImage(
                    placeholder: (ctx, url) => Image(
                      image: AssetImage("assets/placeholder.jpg"),
                    ),
                    imageUrl: widget.image,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
