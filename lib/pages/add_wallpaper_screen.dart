import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:path/path.dart' as path;
import 'package:wallyhub/config/config.dart';

class AddWallpaperScreen extends StatefulWidget {
  const AddWallpaperScreen({super.key});

  @override
  State<AddWallpaperScreen> createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  File? _image;

  List<ImageLabel>? detectedLabels;
  List<String> labelInString = [];

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  bool _isUploading = false;
  bool _isCompleteUploading = false;
  bool _onSelectImage = false;

  void _loadImage() async {
    setState(() {
      _onSelectImage = true;
    });
    final image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (image != null) {
      final File imageFile = File(image.path);

      final inputImage = InputImage.fromFilePath(image.path);
      ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());
      if (imageLabeler != null) {
        List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

        labelInString = [];
        for (var l in labels) {
          labelInString.add(l.label);
        }

        setState(() {
          _image = imageFile;
          detectedLabels = labels;
          _onSelectImage = false;
        });
      }
    }
  }

  void _uploadPhoto() async {
    if (_image != null) {
      String fileName = path.basename(_image!.path);

      User user = _auth.currentUser!;
      String uid = user.uid;

      UploadTask task = _storage
          .ref()
          .child("photos")
          .child(uid)
          .child(fileName)
          .putFile(_image!);

      task.snapshotEvents.listen((e) async {
        if (e.state == TaskState.running) {
          setState(() {
            _isUploading = true;
          });
        }

        if (e.state == TaskState.success) {
          setState(() {
            _isCompleteUploading = true;
            _isUploading = false;
          });

          String url = await e.ref.getDownloadURL();

          _db.collection("photos").add({
            "url": url,
            "date": DateTime.now(),
            "uploaded_by": uid,
            "tags": labelInString,
          });
          Navigator.of(context).pop();
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text("Error"),
            content: Text("Select image to upload..."),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Wallpaper"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                children: [
                  InkWell(
                    onTap: _loadImage,
                    child: _image != null
                        ? Image.file(_image!)
                        : Image(
                            image: AssetImage("assets/placeholder.jpg"),
                          ),
                  ),
                  _image != null
                      ? Text("")
                      : Text("Click on image to add photo"),
                  SizedBox(
                    height: 10,
                  ),
                  detectedLabels != null
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Wrap(
                            spacing: 10,
                            children: detectedLabels!.map((label) {
                              return Chip(
                                label: Text(label.label),
                              );
                            }).toList(),
                          ),
                        )
                      : Container(),
                  if (_isUploading) ...{Text("Uploading Photos...")},
                  if (_isCompleteUploading) ...{Text("Upload Complete")},
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: _uploadPhoto,
                    child: Text('Upload Photo'),
                  ),
                ],
              ),
              _onSelectImage || _isUploading
                  ? Container(
                      color: Colors.black54,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: SpinKitChasingDots(
                          color: primaryColor,
                          size: 80,
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
