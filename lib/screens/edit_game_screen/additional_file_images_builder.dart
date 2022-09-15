//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';
//helpers
import '../../helpers/custom_route.dart';
//pickers helpers
import './manage_picked_images_screen.dart';

class AdditionalFileImagesBuilder extends StatefulWidget {
  final List<File> imageFiles;
  final void Function(List<bool>) manageImagesFn;
  const AdditionalFileImagesBuilder({
    Key? key,
    required this.imageFiles,
    required this.manageImagesFn,
  }) : super(key: key);

  @override
  State<AdditionalFileImagesBuilder> createState() => _AdditionalFileImagesBuilderState();
}

class _AdditionalFileImagesBuilderState extends State<AdditionalFileImagesBuilder> {
  Widget additionalFileImagesBuilder(List<File> imageFiles) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            fileImageContainerBuilder(imageFiles, ctx, constraints, 0),
            if (imageFiles.isNotEmpty) fileImageContainerBuilder(imageFiles, ctx, constraints, 1),
            if (imageFiles.length >= 2) fileImageContainerBuilder(imageFiles, ctx, constraints, 2),
            if (imageFiles.length >= 3) fileImageContainerBuilder(imageFiles, ctx, constraints, 3),
            if (imageFiles.length > 4)
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CustomRoute(
                              builder: (context) => ManagePickedImagesScreen(
                                filesList: imageFiles,
                                manageImagesFn: widget.manageImagesFn,
                                startingIndex: imageFiles.length - 1,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: '4 file carousel',
                          child: CircleAvatar(
                            backgroundImage: FileImage(
                              imageFiles[imageFiles.length - 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "+${imageFiles.length - 4}",
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                    //const Spacer(),
                  ],
                ),
              ),
            Flexible(
              //flex: 2,

              child: (imageFiles.length > 4)
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CustomRoute(
                            builder: (context) => ManagePickedImagesScreen(
                              filesList: imageFiles,
                              manageImagesFn: widget.manageImagesFn,
                              startingIndex: null,
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(),
                      child: const FittedBox(
                        child: Text(
                          "Manage",
                          textAlign: TextAlign.center,
                          style: TextStyle(),
                        ),
                      ),
                    )
                  : TextButton.icon(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          CustomRoute(
                            builder: (context) => ManagePickedImagesScreen(
                              filesList: imageFiles,
                              manageImagesFn: widget.manageImagesFn,
                              startingIndex: null,
                            ),
                          ),
                        );
                      },
                      //style: TextButton.styleFrom(),
                      label: FittedBox(
                        child: Text(
                          "Manage \nImage(s)",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: isDarkMode ? Colors.white : null),
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget fileImageContainerBuilder(
      List<File> imageFiles, BuildContext ctx, BoxConstraints constraints, int index) {
    return GestureDetector(
      onTap: (imageFiles.length < index + 1)
          ? null
          : () {
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => ManagePickedImagesScreen(
                    filesList: imageFiles,
                    manageImagesFn: widget.manageImagesFn,
                    startingIndex: index,
                  ),
                ),
              );
            },
      child: Container(
        width: constraints.maxWidth / 8,
        height: constraints.maxWidth / 8 / 16 * 12,
        //image usually has a ratio of width : height = 16 / 9 or maybe 16/10
        margin: const EdgeInsets.only(top: 7, right: 9.5),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.grey,
          ),
        ),
        alignment: Alignment.center, //for Text("Add a URL")
        child: (imageFiles.length < index + 1)
            ? const FittedBox(
                child: Text(
                  "Add an image",
                  textAlign: TextAlign.center,
                ),
              )
            : Hero(
                tag: '$index file carousel',
                child: Image.file(
                  errorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AssetImage("assets/images/404_eye.png"),
                    );
                  },
                  imageFiles[index],
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return additionalFileImagesBuilder(widget.imageFiles);
  }
}
