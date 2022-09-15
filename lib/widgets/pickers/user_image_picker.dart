//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickerFn;

  const UserImagePicker(this.imagePickerFn, {Key? key}) : super(key: key);

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 900,
        maxHeight: 1600,
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
      //print("Platform Exception");
      /*String message = "An error occurred, please select your image again";
      ScaffoldMessenger.of(widget.ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      */
    } catch (error) {
      print(error);
      /*
      String message = "An error occurred, please select your image again";
      ScaffoldMessenger.of(widget.ctx).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: (_pickedImage == null) ? null : FileImage(_pickedImage as File),
        ),
        TextButton.icon(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColor),
          ),
          icon: const Icon(Icons.image),
          onPressed: _pickImage,
          label: const Text("Add Avatar"),
        ),
      ],
    );
  }
}
