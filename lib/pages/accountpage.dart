import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;

  var images = [
    'https://images.pexels.com/photos/2007647/pexels-photo-2007647.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/36717/amazing-animal-beautiful-beautifull.jpg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/7862485/pexels-photo-7862485.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/9100862/pexels-photo-9100862.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/12672180/pexels-photo-12672180.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/12672185/pexels-photo-12672185.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
    'https://images.pexels.com/photos/1274260/pexels-photo-1274260.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1274260/pexels-photo-1274260.jpeg?auto=compress&cs=tinysrgb&w=600',
    'https://images.pexels.com/photos/1274260/pexels-photo-1274260.jpeg?auto=compress&cs=tinysrgb&w=600',
  ];

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
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: FadeInImage(
                      width: 200,
                      height: 200,
                      image: NetworkImage(_user.photoURL!),
                      placeholder: AssetImage("assets/placeholder.jpg"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text("${_user.displayName}"),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _auth.signOut();
                    },
                    child: Text("Logout"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("My Wallpaper"),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.add),
                        )
                      ],
                    ),
                  ),
                  StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
                    itemCount: images.length,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    itemBuilder: (ctx, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(images[index]),
                        ),
                      );
                    },
                  ),
                ],
              )
            : LinearProgressIndicator(),
      ),
    );
  }
}
