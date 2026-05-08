import 'dart:async';
import 'package:flutter/material.dart';

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration speed;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.left,
    this.speed = const Duration(milliseconds: 40),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _visibleText = '';
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_index < widget.text.length) {
        setState(() {
          _visibleText += widget.text[_index];
          _index++;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _visibleText,
      textAlign: widget.textAlign,
      style: widget.style,
    );
  }
}