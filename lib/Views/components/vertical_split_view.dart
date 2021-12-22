import 'package:flutter/material.dart';

/// Vertical split view used for the landscape visualization in tablet devices.
///
/// It divides the screen into 2 parts where it shows the [left] widget
/// and the [rigth] widget.
///
/// The [ratio] indicates the portion of the screen that the left part will take:
/// it must be between `0` and `1`.
///
/// The [dividerWidth] and [dividerColor] are properties of the line that is drawn
/// between the two halves of the screen and the [resizable] flag indicates if the user
/// can resize the ratio between the 2 parts.
class VerticalSplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double ratio;
  final bool resizable;
  final double dividerWidth;
  final Color dividerColor;

  /// Vertical split view used for the landscape visualization in tablet devices.
  ///
  /// It divides the screen into 2 parts where it shows the [left] widget
  /// and the [rigth] widget.
  ///
  /// The [ratio] indicates the portion of the screen that the left part will take:
  /// it must be between `0` and `1`.
  ///
  /// The [dividerWidth] and [dividerColor] are properties of the line that is drawn
  /// between the two halves of the screen and the [resizable] flag indicates if the user
  /// can resize the ratio between the 2 parts.
  const VerticalSplitView(
      {Key? key,
      required this.left,
      required this.right,
      this.ratio = 0.5,
      this.resizable = false,
      this.dividerWidth = 0,
      this.dividerColor = Colors.black})
      : assert(ratio >= 0),
        assert(ratio <= 1),
        super(key: key);

  @override
  _VerticalSplitViewState createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  late double _ratio;
  double? _maxWidth;

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    _ratio = widget.ratio;
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      if (_ratio != 0 && _ratio != 1) {
        _maxWidth = constraints.maxWidth - widget.dividerWidth;
      } else {
        _maxWidth = constraints.maxWidth;
      }
      return SizedBox(
        width: constraints.maxWidth,
        child: Row(
          children: <Widget>[
            SizedBox(width: _width1, child: widget.left),
            if (widget.resizable) ...[
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                child: SizedBox(
                  width: widget.dividerWidth,
                  height: constraints.maxHeight,
                  child: RotationTransition(
                    child: Icon(Icons.drag_handle),
                    turns: AlwaysStoppedAnimation(0.25),
                  ),
                ),
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _ratio += details.delta.dx / _maxWidth!;
                    if (_ratio > 1)
                      _ratio = 1;
                    else if (_ratio < 0.0) _ratio = 0.0;
                  });
                },
              ),
            ] else if (_ratio != 0 && _ratio != 1) ...[
              Container(
                width: widget.dividerWidth,
                height: constraints.maxHeight,
                color: widget.dividerColor,
              )
            ],
            Expanded(child: SizedBox(width: _width2, child: widget.right)),
          ],
        ),
      );
    });
  }

  get _width1 => _ratio * _maxWidth!;

  get _width2 => (1 - _ratio) * _maxWidth!;
}
