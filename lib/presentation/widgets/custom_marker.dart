import 'dart:typed_data' as ui;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class CustomMarker {
  static Future<BitmapDescriptor> createCustomMarker(
    String imageUrl, {
    double size = 140,
  }) async {
    try {
      // Download the profile image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }

      // Create a picture recorder
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      // Calculate dimensions
      final double markerWidth = size;
      final double markerHeight = size * 1.2; // Make it taller like original marker
      final double circleRadius = size * 0.35;
      final double circleCenter = size * 0.4;

      // Draw shadow first (slightly offset)
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // Shadow for the circle
      canvas.drawCircle(
        Offset(markerWidth / 2 + 1, circleCenter + 1),
        circleRadius + 2,
        shadowPaint,
      );

      // Shadow for the pointer
      final Path shadowPath = Path();
      shadowPath.moveTo(markerWidth / 2 + 1, circleCenter + circleRadius + 1);
      shadowPath.lineTo(markerWidth / 2 - 8 + 1, markerHeight - 5 + 1);
      shadowPath.lineTo(markerWidth / 2 + 8 + 1, markerHeight - 5 + 1);
      shadowPath.close();
      canvas.drawPath(shadowPath, shadowPaint);

      // Draw the main marker body (circle)
      final Paint markerPaint = Paint()
        ..color = const Color(0xFFEA4335) // Google red color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        circleRadius,
        markerPaint,
      );

      // Draw the pointer (bottom triangle)
      final Path pointerPath = Path();
      pointerPath.moveTo(markerWidth / 2, circleCenter + circleRadius);
      pointerPath.lineTo(markerWidth / 2 - 8, markerHeight - 5);
      pointerPath.lineTo(markerWidth / 2 + 8, markerHeight - 5);
      pointerPath.close();
      canvas.drawPath(pointerPath, markerPaint);

      // Add subtle gradient effect
      final Paint gradientPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(markerWidth / 2, circleCenter),
          circleRadius,
          [
            Colors.white.withOpacity(0.3),
            Colors.transparent,
          ],
          [0.0, 0.7],
        );
      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        circleRadius,
        gradientPaint,
      );

      // Draw white border around the circle
      final Paint borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        circleRadius,
        borderPaint,
      );

      // Process and draw the profile image
      final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image profileImage = frameInfo.image;

      // Calculate the size and position for the profile image (inside the circle)
      final double imageRadius = circleRadius - 6; // Leave space for border
      final double imageSize = imageRadius * 2;

      // Create a circular clip path for the profile image
      final Path clipPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(markerWidth / 2, circleCenter),
          width: imageSize,
          height: imageSize,
        ));

      // Save the canvas state
      canvas.save();
      // Apply the clip path
      canvas.clipPath(clipPath);

      // Draw the profile image
      canvas.drawImageRect(
        profileImage,
        Rect.fromLTWH(0, 0, profileImage.width.toDouble(), profileImage.height.toDouble()),
        Rect.fromCenter(
          center: Offset(markerWidth / 2, circleCenter),
          width: imageSize,
          height: imageSize,
        ),
        Paint()..isAntiAlias = true,
      );

      // Restore the canvas state
      canvas.restore();

      // Add a subtle inner border to the profile image
      final Paint innerBorderPaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        imageRadius,
        innerBorderPaint,
      );

      // Convert the canvas to an image
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image image = await picture.toImage(markerWidth.toInt(), markerHeight.toInt());
      final ui.ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        // ignore: deprecated_member_use
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Error creating custom marker: $e');
    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  // Alternative method with customizable colors
  static Future<BitmapDescriptor> createCustomMarkerWithColor(
    String imageUrl, {
    double size = 140,
    Color markerColor = const Color(0xFFEA4335),
    Color borderColor = Colors.white,
  }) async {
    try {
      // Download the profile image
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }

      // Create a picture recorder
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      // Calculate dimensions
      final double markerWidth = size;
      final double markerHeight = size * 1.2;
      final double circleRadius = size * 0.35;
      final double circleCenter = size * 0.4;

      // Draw shadow
      final Paint shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawCircle(
        Offset(markerWidth / 2 + 1, circleCenter + 1),
        circleRadius + 2,
        shadowPaint,
      );

      final Path shadowPath = Path();
      shadowPath.moveTo(markerWidth / 2 + 1, circleCenter + circleRadius + 1);
      shadowPath.lineTo(markerWidth / 2 - 8 + 1, markerHeight - 5 + 1);
      shadowPath.lineTo(markerWidth / 2 + 8 + 1, markerHeight - 5 + 1);
      shadowPath.close();
      canvas.drawPath(shadowPath, shadowPaint);

      // Draw the main marker body
      final Paint markerPaint = Paint()
        ..color = markerColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        circleRadius,
        markerPaint,
      );

      // Draw the pointer
      final Path pointerPath = Path();
      pointerPath.moveTo(markerWidth / 2, circleCenter + circleRadius);
      pointerPath.lineTo(markerWidth / 2 - 8, markerHeight - 5);
      pointerPath.lineTo(markerWidth / 2 + 8, markerHeight - 5);
      pointerPath.close();
      canvas.drawPath(pointerPath, markerPaint);

      // Draw border
      final Paint borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        Offset(markerWidth / 2, circleCenter),
        circleRadius,
        borderPaint,
      );

      // Process and draw the profile image
      final ui.Codec codec = await ui.instantiateImageCodec(response.bodyBytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image profileImage = frameInfo.image;

      final double imageRadius = circleRadius - 6;
      final double imageSize = imageRadius * 2;

      final Path clipPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(markerWidth / 2, circleCenter),
          width: imageSize,
          height: imageSize,
        ));

      canvas.save();
      canvas.clipPath(clipPath);

      canvas.drawImageRect(
        profileImage,
        Rect.fromLTWH(0, 0, profileImage.width.toDouble(), profileImage.height.toDouble()),
        Rect.fromCenter(
          center: Offset(markerWidth / 2, circleCenter),
          width: imageSize,
          height: imageSize,
        ),
        Paint()..isAntiAlias = true,
      );

      canvas.restore();

      // Convert to image
      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image image = await picture.toImage(markerWidth.toInt(), markerHeight.toInt());
      final ui.ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return BitmapDescriptor.fromBytes(byteData.buffer.asUint8List());
      }
    } catch (e) {
      debugPrint('Error creating custom marker with color: $e');
    }

    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }
}