import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

import 'package:path/path.dart' as path;

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

  void _loadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

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
        });
      }
    }
  }

  void _uploadPhoto() async {
    if (_image != null) {
      String fileName = path.basename(_image!.path);
      print('Filename : ${fileName}');

      User user = await _auth.currentUser!;
      String uid = user.uid;

      UploadTask task = _storage
          .ref()
          .child("photos")
          .child(uid)
          .child(fileName)
          .putFile(_image!);

      task.snapshotEvents.listen((e) {
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

          e.ref.getDownloadURL().then((url) {
            Navigator.of(context).pop;
          });
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
          child: Column(
            children: [
              InkWell(
                onTap: _loadImage,
                child: _image != null
                    ? Image.file(_image!)
                    : Image(
                        image: AssetImage("assets/placeholder.jpg"),
                      ),
              ),
              Text("Click on image to upload photo"),
              SizedBox(
                height: 20,
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
              SizedBox(
                height: 40,
              ),
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
        ),
      ),
    );
  }
}
