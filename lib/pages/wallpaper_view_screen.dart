import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:wallyhub/config/config.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class WallpaperViewPage extends StatefulWidget {
  const WallpaperViewPage({super.key, required this.data, this.fav});

  final DocumentSnapshot data;
  final bool? fav;

  @override
  State<WallpaperViewPage> createState() => _WallpaperViewPageState();
}

class _WallpaperViewPageState extends State<WallpaperViewPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isFavorite = false;

  @override
  void initState() {
    if (widget.fav != null) {
      isFavorite = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> tags = widget.data.get("tags").toList();

    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - 80,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Hero(
                          tag: widget.data.get("url"),
                          child: CachedNetworkImage(
                            placeholder: (ctx, url) => const Image(
                              image: AssetImage("assets/placeholder.jpg"),
                            ),
                            imageUrl: widget.data.get("url"),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          top: 30,
                          child: IconButton(
                            onPressed: _addToFavorite,
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 35,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: Wrap(
                        spacing: 10,
                        children: tags.map((tag) {
                          return Chip(
                            label: Text(tag.toString()),
                          );
                        }).toList(),
                      ),
                    ),
                    StreamBuilder(
                      stream: _db
                          .collection("users")
                          .where("uid",
                              isEqualTo: widget.data.get("uploaded_by"))
                          .snapshots(),
                      builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: FadeInImage(
                                    width: 35,
                                    height: 35,
                                    image: NetworkImage(
                                        snapshot.data!.docs[0].get("photoUrl")),
                                    placeholder: const AssetImage(
                                        "assets/placeholder.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  snapshot.data!.docs[0].get("displayName"),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _launchURL,
                        icon: const Icon(Icons.download),
                        label: const Text("Download"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: secondaryColor,
                          shape: const RoundedRectangleBorder(),
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.4, 60),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _createDynamicLink,
                        icon: const Icon(Icons.share),
                        label: const Text("Bagikan"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const RoundedRectangleBorder(),
                          textStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          minimumSize:
                              Size(MediaQuery.of(context).size.width * 0.4, 60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

    if (!isFavorite) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Container(
          height: 60,
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Berhasil ditambahkan ke Favorit",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.transparent,
      ));
    }

    setState(() {
      isFavorite = true;
    });
  }

  void _createDynamicLink() async {
    DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
      link: Uri.parse(widget.data["url"]),
      uriPrefix: "https://wallyhub.page.link",
      androidParameters: const AndroidParameters(
          packageName: 'com.example.wallyhub', minimumVersion: 0),
      iosParameters: const IOSParameters(
          bundleId: 'com.example.wallyhub', minimumVersion: "0"),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "WallyHub",
        description: "An App for cools Photos",
        imageUrl: Uri.parse(widget.data["url"]),
      ),
    );

    final dynamicLink = await FirebaseDynamicLinks.instance
        .buildShortLink(dynamicLinkParameters);

    final url = dynamicLink.shortUrl.toString();
    Share.share(url);
  }
}
