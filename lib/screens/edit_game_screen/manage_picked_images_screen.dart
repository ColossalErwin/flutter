//dart
import 'dart:io';
//packages
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

class ManagePickedImagesScreen extends StatefulWidget {
  final List<File> filesList;
  final void Function(List<bool> deletedIndices) manageImagesFn;
  final int? startingIndex;
  const ManagePickedImagesScreen({
    Key? key,
    required this.filesList,
    required this.manageImagesFn,
    required this.startingIndex,
  }) : super(key: key);

  @override
  State<ManagePickedImagesScreen> createState() => _ManagePickedImagesScreenState();
}

class _ManagePickedImagesScreenState extends State<ManagePickedImagesScreen> {
  late int _currentIndex;
  final List<bool> _deletedIndices = [];
  final List<Widget> _widgets = [];
  final List<Image> _images = [];

  void _convertImageFilesToLists(List<File> imageFiles) {
    int index = 0;
    for (File imageFile in imageFiles) {
      _images.add(
        Image.file(
          imageFile,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Image(
              image: AssetImage("assets/images/404_eye.png"),
            );
          },
        ),
      );
      _widgets.add(_images[index]);
      index++;
    }
  }

  @override
  void initState() {
    _currentIndex = widget.startingIndex ?? 0;
    for (int index = 0; index < widget.filesList.length; index++) {
      _deletedIndices.add(false);
    }
    _convertImageFilesToLists(widget.filesList);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Images"),
        actions: [
          IconButton(
            tooltip: "Save changes",
            icon: const Icon(Icons.delete),
            onPressed: () {
              widget.manageImagesFn(_deletedIndices);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                margin: const EdgeInsets.only(top: 8, right: 10),
                child: InkWell(
                  splashColor: Colors.amber.withOpacity(0.15),
                  onTap: () {
                    SwipeImageGallery(
                      hideStatusBar: false,
                      backgroundColor: Colors.black54,
                      context: context,
                      children: _images,
                    ).show();
                  },
                  child: (widget.filesList.isNotEmpty)
                      ? CarouselSlider(
                          options: CarouselOptions(
                            onPageChanged: (index, reason) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            initialPage: (widget.startingIndex == null || widget.startingIndex! < 0)
                                ? 0
                                : widget.startingIndex!,
                            aspectRatio: 16 / 9,
                            enableInfiniteScroll: (widget.filesList.length >= 2) ? true : false,
                            autoPlay: false,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                          ),
                          items: _widgets,
                        )
                      : const Center(child: Text("No images")),
                ),
              ),
            ],
          ),
          if (widget.filesList.isNotEmpty)
            CheckboxListTile(
              title: const Text(
                "Mark to delete the current shown image:",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              value: _deletedIndices[_currentIndex],
              onChanged: (val) {
                if (val == null) {
                  return;
                }
                setState(() {
                  _deletedIndices[_currentIndex] = val;
                });
              },
            ),
        ],
      ),
    );
  }
}
