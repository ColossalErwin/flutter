//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImagesPicker extends StatefulWidget {
  final void Function(List<File> pickedImages) imagesPickerFn;
  const ImagesPicker(
    this.imagesPickerFn, {
    Key? key,
  }) : super(key: key);

  @override
  State<ImagesPicker> createState() => _ImagesPickerState();
}

class _ImagesPickerState extends State<ImagesPicker> {
  final List<File> _pickedImages = [];

  void _pickImagesFunction(ImageSource imageSource) async {
    final Size mediaQuerySize = MediaQuery.of(context).size;
    try {
      final picker = ImagePicker();
      if (imageSource == ImageSource.gallery) {
        final pickedImages = await picker.pickMultiImage(
          imageQuality: 100,
          maxWidth: mediaQuerySize.height, // max for landscape
          maxHeight: mediaQuerySize.width, //max for landscape
        );
        if (pickedImages == null) {
          return;
        }
        setState(() {
          for (XFile xFile in pickedImages) {
            _pickedImages.add(File(xFile.path));
          }
        });
        widget.imagesPickerFn(_pickedImages);
      } else if (imageSource == ImageSource.camera) {
        final pickedImage = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 100,
          maxWidth: mediaQuerySize.height, // max for landscape
          maxHeight: mediaQuerySize.width, //max for landscape
        );
        if (pickedImage == null) {
          return;
        }
        setState(() {
          _pickedImages.add(File(pickedImage.path));
        });
        widget.imagesPickerFn(_pickedImages);
      }
    } on PlatformException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Text(
        "Add additional image(s) \nfrom gallery or camera:",
        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        textAlign: TextAlign.center,
      ),
      title: TextButton.icon(
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: const BorderSide(color: Colors.black),
            ),
          ),
        ),
        icon: Icon(
          Icons.camera,
          color: isDarkMode ? Colors.white70 : Colors.black,
        ),
        // _pickImagesFunction(widget.imageSource);
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("Choose an option."),
                content: const Text("Browse images from the gallery or use the camera."),
                actions: [
                  TextButton.icon(
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text("Camera"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      FocusScope.of(context).unfocus();
                      _pickImagesFunction(ImageSource.camera);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Gallery"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      FocusScope.of(context).unfocus();
                      _pickImagesFunction(ImageSource.gallery);
                    },
                  ),
                ],
              );
            },
          );
        },
        //should have a pop up dialog to ask us what do we want
        //either select multiple images from the gallery or take pictures from camera
        label: Text(
          "Media",
          textAlign: TextAlign.center,
          style: TextStyle(color: isDarkMode ? null : Colors.black54),
        ),
      ),
    );
  }
}
