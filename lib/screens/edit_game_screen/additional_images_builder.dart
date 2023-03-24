//packages
import 'package:flutter/material.dart';
//screens
import './manage_images_screen.dart';
//helpers
import '../../helpers/custom_route.dart';

class AdditionalImagesBuilder extends StatefulWidget {
  final List<String> imageURLs;
  final void Function(List<bool>) manageImagesFn;
  // final void Function(int) deletedIndexFn;
  const AdditionalImagesBuilder({
    Key? key,
    required this.imageURLs,
    required this.manageImagesFn,
    //required this.deletedIndexFn,
  }) : super(key: key);

  @override
  State<AdditionalImagesBuilder> createState() => _AdditionalImagesBuilderState();
}

class _AdditionalImagesBuilderState extends State<AdditionalImagesBuilder> {
  Widget additionalImagesBuilder(List<String> imageURLs) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: [
            imageContainerBuilder(imageURLs, ctx, constraints, 0),
            if (imageURLs.isNotEmpty) imageContainerBuilder(imageURLs, ctx, constraints, 1),
            if (imageURLs.length >= 2) imageContainerBuilder(imageURLs, ctx, constraints, 2),
            if (imageURLs.length >= 3) imageContainerBuilder(imageURLs, ctx, constraints, 3),
            if (imageURLs.length > 4)
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CustomRoute(
                              builder: (context) => ManageImagesScreen(
                                imageURLs: imageURLs,
                                manageImagesFn: widget.manageImagesFn,
                                startingIndex: imageURLs.length - 1,
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: '4 network carousel',
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                              imageURLs[imageURLs.length - 1],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "+${imageURLs.length - 4}",
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
              child: (imageURLs.length > 4)
                  ? TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          CustomRoute(
                            builder: (context) => ManageImagesScreen(
                              imageURLs: imageURLs,
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
                            builder: (context) => ManageImagesScreen(
                              imageURLs: imageURLs,
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

  Widget imageContainerBuilder(
      List<String> imageURLs, BuildContext ctx, BoxConstraints constraints, int index) {
    return GestureDetector(
      onTap: (imageURLs.length < index + 1)
          ? null
          : () {
              Navigator.of(context).push(
                CustomRoute(
                  builder: (context) => ManageImagesScreen(
                    imageURLs: imageURLs,
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
        child: (imageURLs.length < index + 1)
            ? const FittedBox(
                child: Text(
                  "Add a URL",
                  textAlign: TextAlign.center,
                ),
              )
            : Hero(
                tag: '$index network carousel',
                child: Image.network(
                  errorBuilder: (context, error, stackTrace) {
                    return const Image(
                      image: AssetImage("assets/images/404_eye.png"),
                    );
                  },
                  imageURLs[index],
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("length is: ${widget.imageURLs.length}");
    return additionalImagesBuilder(widget.imageURLs);
  }
}
