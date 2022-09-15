//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class TitleImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickerFn;
  const TitleImagePicker(
    this.imagePickerFn, {
    Key? key,
  }) : super(key: key);

  @override
  State<TitleImagePicker> createState() => _TitleImagePickerState();
}

class _TitleImagePickerState extends State<TitleImagePicker> {
  File? _pickedImage;

  void _pickImageFunction(ImageSource imageSource) async {
    final Size mediaQuerySize = MediaQuery.of(context).size;
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        //we can use pick multi image instead???
        source: imageSource, //image source could be camera
        maxWidth: mediaQuerySize.height, // max for landscape
        maxHeight: mediaQuerySize.width, //max for landscape
      );
      if (pickedImage == null) {
        return;
      }
      setState(() {
        _pickedImage = File(pickedImage.path);
      });
      widget.imagePickerFn(_pickedImage as File);
    } on PlatformException catch (error) {
      print(error);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextButton.icon(
          icon: Icon(
            Icons.image,
            color: isDarkMode ? Colors.white70 : Colors.blue,
          ),
          onPressed: () => _pickImageFunction(ImageSource.gallery),
          label: const Text("Gallery"),
        ),
        TextButton.icon(
          icon: Icon(
            Icons.camera_alt,
            color: isDarkMode ? Colors.white70 : Colors.blue,
          ),
          onPressed: () => _pickImageFunction(ImageSource.camera),
          label: const Text("Camera"),
        ),
      ],
    );
  }
}
