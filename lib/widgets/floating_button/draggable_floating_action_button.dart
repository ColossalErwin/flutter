//about the floating button if we use temp data to store position of it each time it moves,
//then we can actually keep it at a position (respawn at the exact position)
//if we click on it

//dart
import 'dart:io';
//packages
import 'package:flutter/material.dart';

//this file contains both the portrait class and landscape class for the floating button
//we create two classes to avoid button being unreachable when rotates
//so if rotation occurs, the floating button object would be destroyed and a new one will be created

class DraggableFloatingActionButtonPortrait extends StatefulWidget {
  final Widget child;
  final double deviceWidth;
  final double deviceHeight;

  ///For some reason, on testing the floating button is clickable for simulators
  ///However, on real device, that is not the case
  ///A walk around is to use an IconButton (or other button) wrapped in a Container (such as CircleAvatar),
  ///then pass our function to IconButton's onPressed*/

  //so we don't really need onPressed in this case

  final Function onPressed;
  final GlobalKey parentKey;

  const DraggableFloatingActionButtonPortrait({
    Key? key,
    required this.child,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.onPressed,
    required this.parentKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonPortraitState();
}

class _DraggableFloatingActionButtonPortraitState
    extends State<DraggableFloatingActionButtonPortrait> {
  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;
  late Offset _offset;
  late Offset _minOffset;
  late Offset _maxOffset;

  @override
  void initState() {
    _offset = Offset(widget.deviceWidth * 0.8, widget.deviceHeight * 0.825); //0.8 and 0.85
    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    super.initState();
  }

  //this function forgets about landscape mode
  //so we should think of something like when we change state parentRenderBox should change to fit landscape mode
  //also should generate another floating action button starting at the corner!!!

  void _setBoundary(_) {
    final RenderBox parentRenderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final Size parentSize = parentRenderBox.size;
      final Size size = renderBox.size;

      setState(() {
        _minOffset = const Offset(0, 0);
        _maxOffset = Offset(parentSize.width - size.width, parentSize.height - size.height);
      });
    } catch (e) {
      //print('catch: $e');
    }
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        child: Container(
          key: _key,
          child: widget.child,
        ),
      ),
    );
  }
}

class DraggableFloatingActionButtonLandScape extends StatefulWidget {
  final Widget child;
  final double deviceWidth;
  final double deviceHeight;

  /*
  For some reason, on testing the floating button is clickable for simulators 
  * However, on real device, that is not the case
  * A walk around is to use an IconButton (or other button) wrapped in a Container (such as CircleAvatar), 
  * then pass our function to IconButton's onPressed
  */

  //so we don't really need onPressed in this case

  final Function onPressed;
  final GlobalKey parentKey;

  const DraggableFloatingActionButtonLandScape({
    Key? key,
    required this.child,
    required this.deviceWidth,
    required this.deviceHeight,
    required this.onPressed,
    required this.parentKey,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DraggableFloatingActionButtonLandScapeState();
}

class _DraggableFloatingActionButtonLandScapeState
    extends State<DraggableFloatingActionButtonLandScape> {
  final GlobalKey _key = GlobalKey();

  bool _isDragging = false;
  late Offset _offset;
  late Offset _minOffset;
  late Offset _maxOffset;

  @override
  void initState() {
    _offset = (Platform.isIOS)
        ? Offset(widget.deviceHeight * 1.75, widget.deviceWidth * 0.3)
        : Offset(widget.deviceHeight * 1.55, widget.deviceWidth * 0.28);

    WidgetsBinding.instance.addPostFrameCallback(_setBoundary);
    super.initState();
  }

  //this function forgets about landscape mode
  //so we should think of something like when we change state parentRenderBox should change to fit landscape mode
  //also should generate another floating action button starting at the corner!!!

  void _setBoundary(_) {
    final RenderBox parentRenderBox =
        widget.parentKey.currentContext?.findRenderObject() as RenderBox;
    final RenderBox renderBox = _key.currentContext?.findRenderObject() as RenderBox;

    try {
      final Size parentSize = parentRenderBox.size;
      final Size size = renderBox.size;

      setState(() {
        _minOffset = const Offset(0, 0);
        _maxOffset = Offset(parentSize.width - size.width, parentSize.height - size.height);
      });
    } catch (e) {
      //print('catch: $e');
    }
  }

  void _updatePosition(PointerMoveEvent pointerMoveEvent) {
    double newOffsetX = _offset.dx + pointerMoveEvent.delta.dx;
    double newOffsetY = _offset.dy + pointerMoveEvent.delta.dy;

    if (newOffsetX < _minOffset.dx) {
      newOffsetX = _minOffset.dx;
    } else if (newOffsetX > _maxOffset.dx) {
      newOffsetX = _maxOffset.dx;
    }

    if (newOffsetY < _minOffset.dy) {
      newOffsetY = _minOffset.dy;
    } else if (newOffsetY > _maxOffset.dy) {
      newOffsetY = _maxOffset.dy;
    }

    setState(() {
      _offset = Offset(newOffsetX, newOffsetY);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: Listener(
        onPointerMove: (PointerMoveEvent pointerMoveEvent) {
          _updatePosition(pointerMoveEvent);

          setState(() {
            _isDragging = true;
          });
        },
        onPointerUp: (PointerUpEvent pointerUpEvent) {
          if (_isDragging) {
            setState(() {
              _isDragging = false;
            });
          } else {
            widget.onPressed();
          }
        },
        child: Container(
          key: _key,
          child: widget.child,
        ),
      ),
    );
  }
}

StatefulWidget draggableFloatingActionButtonBuilder({
  required BuildContext context,
  required GlobalKey parentKey,
  required Icon icon,
  required VoidCallback handler, //void Function() handler,
  //String tooltip = "perform action", //1st way of declaring optional arg
  String? tooltip, //2nd way of declaring optional arg
  //we can also use String? tooltip = "perfom action",
  double? radius,
  Color? iconColor,
  Color? backgroundColor,
  Color? splashColor, //only for Android
}) {
  Icon iosIcon = Icon(
    icon.icon,
    color: iconColor,
  );

  final mediaQuery = MediaQuery.of(context);
  final isLandScape = (mediaQuery.orientation == Orientation.landscape);
  final isIOS = Platform.isIOS;
  double width = mediaQuery.size.width;
  double height = mediaQuery.size.height;

  return (isLandScape)
      ? DraggableFloatingActionButtonLandScape(
          deviceWidth: width,
          deviceHeight: height,
          parentKey: parentKey,
          onPressed: () {}, //should leave this as is.
          //we will deal with onPressed once in GestureDetector or IconButton
          child: (isIOS)
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: handler,
                  child: CircleAvatar(
                    radius: (radius == null) ? 0.035 * width : radius,
                    backgroundColor: backgroundColor,
                    child: (icon.color == null && iconColor != null) ? iosIcon : icon,
                    //if the icon passed has no color option and iconColor argument is not null,
                    // then choose color from iconColor argument
                  ),
                )
              : CircleAvatar(
                  radius: (radius == null) ? 0.035 * width : radius,
                  backgroundColor: backgroundColor, //background color
                  child: IconButton(
                    icon: icon,
                    color: iconColor, //colors of what inside (the icon)
                    splashColor: splashColor,
                    tooltip: tooltip,
                    onPressed: handler,
                  ),
                ),
        )
      : DraggableFloatingActionButtonPortrait(
          deviceWidth: width,
          deviceHeight: height,
          parentKey: parentKey,
          onPressed: () {},
          child: (isIOS)
              ? GestureDetector(
                  onTap: handler,
                  child: CircleAvatar(
                    radius: (radius == null) ? 0.07 * width : radius,
                    backgroundColor: backgroundColor,
                    child: (icon.color == null && iconColor != null) ? iosIcon : icon,
                    //if the icon passed has no color option and iconColor argument is not null,
                    // then choose color from iconColor argument
                  ),
                )
              : CircleAvatar(
                  radius: (radius == null) ? 0.07 * width : radius,
                  backgroundColor: backgroundColor, //background color
                  child: IconButton(
                    icon: icon,
                    color: iconColor, //colors of what inside (the icon)
                    splashColor: splashColor,
                    tooltip: tooltip,
                    onPressed: handler,
                  ),
                ),
        );
}
