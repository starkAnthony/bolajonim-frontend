import 'dart:convert';
import 'dart:typed_data';

import 'package:bolajonim_app/core/widgets/profile_photo_crop_screen.dart';
import 'package:bolajonim_app/core/widgets/profile_photo_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2x2 PNG so the crop screen can decode without drawing a test image.
final Uint8List _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAgAAAAECAIAAAA8r+mnAAAAEUlEQVR4nGOIu3wMK2KgngQAO9g+4R96g74AAAAASUVORK5CYII=',
);

void main() {
  testWidgets(
    'crop screen shows framing controls',
    (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfilePhotoCropScreen(imageBytes: _png)),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.text('Rasmni sozlash'), findsOneWidget);
    expect(find.text('Saqlash'), findsOneWidget);
    expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('viewer shows the full photo with change and delete', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePhotoViewer(title: 'Ali', imageBytes: _png),
      ),
    );
    await tester.pump();

    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('O‘zgartirish'), findsOneWidget);
    expect(find.text('O‘chirish'), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  }, timeout: const Timeout(Duration(seconds: 30)));
}
