import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class AddWallpaperScreen extends StatefulWidget {
  const AddWallpaperScreen({super.key});

  @override
  State<AddWallpaperScreen> createState() => _AddWallpaperScreenState();
}

class _AddWallpaperScreenState extends State<AddWallpaperScreen> {
  File? _image;

  List<ImageLabel>? detectedLabels;

  void _loadImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      final File imageFile = File(image.path);

      final inputImage = InputImage.fromFilePath(image.path);
      ImageLabeler imageLabeler = ImageLabeler(options: ImageLabelerOptions());
      List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      setState(() {
        _image = imageFile;
        detectedLabels = labels;
      });
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
            ],
          ),
        ),
      ),
    );
  }
}
