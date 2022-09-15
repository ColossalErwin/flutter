//package
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:swipe_image_gallery/swipe_image_gallery.dart';

class ManageImagesScreen extends StatefulWidget {
  final List<String> imageURLs;
  final void Function(List<bool> deletedIndices) manageImagesFn;
  final int? startingIndex;
  const ManageImagesScreen({
    Key? key,
    required this.imageURLs,
    required this.manageImagesFn,
    required this.startingIndex,
  }) : super(key: key);

  @override
  State<ManageImagesScreen> createState() => _ManageImagesScreenState();
}

class _ManageImagesScreenState extends State<ManageImagesScreen> {
  late int _currentIndex;
  final List<bool> _deletedIndices = [];
  final List<Widget> _widgets = [];
  final List<Image> _images = [];

  void _convertImageFilesToLists(List<String> imageURLs) {
    int index = 0;
    for (final String imageURL in imageURLs) {
      _images.add(
        Image.network(
          imageURL,
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
    for (int index = 0; index < widget.imageURLs.length; index++) {
      _deletedIndices.add(false);
    }
    _convertImageFilesToLists(widget.imageURLs);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("range is");
    print(widget.imageURLs.length);
    print("starting index is");
    print(widget.startingIndex);
    print("image urls length is");
    print(widget.imageURLs.length);
    print("current index is");
    print(_currentIndex);
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
                      initialIndex: _currentIndex,
                      hideStatusBar: false,
                      backgroundColor: Colors.black54,
                      context: context,
                      children: _images,
                    ).show();
                  },
                  child: (widget.imageURLs.isNotEmpty)
                      ? CarouselSlider(
                          options: CarouselOptions(
                            onPageChanged: (index, reason) {
                              setState(() {
                                //index is current index of the imageURLs not current index of the carousel
                                _currentIndex = index;
                                /*
                                print("current index is");
                                print(_currentIndex);
                                */
                              });
                            },
                            initialPage: (widget.startingIndex == null || widget.startingIndex! < 0)
                                ? 0
                                : widget.startingIndex!,
                            aspectRatio: 16 / 9,
                            enableInfiniteScroll: (widget.imageURLs.length >= 2) ? true : false,
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
          if (widget.imageURLs.isNotEmpty)
            CheckboxListTile(
              title: const Text(
                "Mark to delete the current shown image:",
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              value: _deletedIndices[_currentIndex],
              onChanged: (val) {
                //currentIndex is currentIndex of imageURLS
                //startingIndex is startingIndex of imageURLs that is the initial page of the carousel

                setState(() {
                  if (val == null) {
                    return;
                  }
                  _deletedIndices[_currentIndex] = val;
                  print("current index marked as deleted:");
                  print(_currentIndex);
                });
              },
            ),
        ],
      ),
    );
  }
}
