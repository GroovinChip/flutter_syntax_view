import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import 'syntaxes/base.dart';
import 'syntaxes/index.dart';

class SyntaxView extends StatefulWidget {
  SyntaxView(
      {@required this.code,
      @required this.syntax,
      this.syntaxTheme,
      this.withZoom,
      this.withLinesCount,
      this.fontSize = 12.0});

  final String code;
  final Syntax syntax;
  final bool withZoom;
  final bool withLinesCount;
  final SyntaxTheme syntaxTheme;
  final double fontSize;

  @override
  State<StatefulWidget> createState() => SyntaxViewState();
}

class SyntaxViewState extends State<SyntaxView> {
  double textScaleFactor = 1.0;

  @override
  Widget build(BuildContext context) {
    assert(widget.code != null,
        "Code Content must not be null.\n===| if you are loading a String from assets, make sure you declare it in pubspec.yaml |===");
    assert(widget.syntax != null,
        "Syntax must not be null. select a Syntax by calling Syntax.(Language)");
    final int numLines = '\n'.allMatches(widget.code).length + 1;
    return Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Container(
              padding: (widget.withLinesCount ?? true)
                  ? EdgeInsets.only(left: 5, top: 10, right: 10, bottom: 10)
                  : EdgeInsets.all(10),
              color:
                  (widget.syntaxTheme ?? SyntaxTheme.dracula()).backgroundColor,
              constraints: BoxConstraints.expand(),
              child: Scrollbar(
                  child: SingleChildScrollView(
                      child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: (widget.withLinesCount ?? true)
                              ? buildWithLines(numLines)
                              : buildCode())))),
          (widget.withZoom ?? false) ? zoomControls() : null
        ].where((w) => w != null).toList());
  }

  Widget zoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
            icon: Icon(Icons.zoom_out,
                color: (widget.syntaxTheme ?? SyntaxTheme.dracula())
                    .zoomIconColor),
            onPressed: () => setState(() {
                  textScaleFactor = max(0.8, textScaleFactor - 0.1);
                })),
        IconButton(
            icon: Icon(Icons.zoom_in,
                color: (widget.syntaxTheme ?? SyntaxTheme.dracula())
                    .zoomIconColor),
            onPressed: () => setState(() {
                  textScaleFactor <= 4.0
                      ? textScaleFactor += 0.1
                      : print(
                          "Maximum zoom (4.0) has been reached. more zooming can cause a crash.");
                })),
      ],
    );
  }

  Widget buildCode() {
    return RichText(
      softWrap: false,
      textScaleFactor: textScaleFactor,
      text: buildRichText(),
    );
  }

  TextStyle get baseStyle => TextStyle(
        fontFamily: 'monospace',
        fontSize: widget.fontSize,
      );

  TextSpan buildRichText() {
    return TextSpan(
      style: baseStyle,
      children: <TextSpan>[
        getSyntax(widget.syntax, widget.syntaxTheme).format(widget.code)
      ],
    );
  }

  Widget buildWithLines([int guessNumLines]) {
    int numLines;
    try {
      final textPainter = TextPainter(
        text: buildRichText(),
        textDirection: TextDirection.ltr,
      );
      List<ui.LineMetrics> lines = textPainter.computeLineMetrics();
      numLines = lines?.length ?? 0;
    } catch (e) {}
    numLines ??= guessNumLines;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(children: <Widget>[
          for (int i = 1; i <= numLines; i++)
            RichText(
                textScaleFactor: textScaleFactor,
                text: TextSpan(
                  style: baseStyle.copyWith(
                      color: (widget.syntaxTheme ?? SyntaxTheme.dracula())
                          .linesCountColor),
                  text: "$i",
                ))
        ]),
        VerticalDivider(width: 5),
        buildCode(),
      ],
    );
  }
}
