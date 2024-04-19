import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
    this.faces,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;
  
  @override
  void paint(Canvas canvas, Size size) {
    // final Paint paint1 = Paint()
    //   ..style = PaintingStyle.stroke
    //   ..strokeWidth = 1.0
    //   ..color = Colors.red;
    final Paint paint2 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0
      ..color = Colors.green;

//
    /*final screenWidth = size.width;
    final screenHeight = size.height;

    final centerX = screenWidth / 2;
    final centerY = screenHeight / 2;

    final boxWidth = screenWidth * 0.6;
    final boxHeight = screenHeight * 0.4;

    final halfBoxWidth = boxWidth / 2;
    final halfBoxHeight = boxHeight / 2;

    final newLeft = centerX - halfBoxWidth;
    final newTop = centerY - halfBoxHeight;
    final newRight = centerX + halfBoxWidth;
    final newBottom = centerY + halfBoxHeight;
    //กลาง 670-690

    canvas.drawRect(
      Rect.fromLTRB(newLeft, newTop, newRight, newBottom),
      paint1,
    );*/

    for (final Face face in faces) {
      final left = translateX(
        face.boundingBox.left,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final top = translateY(
        face.boundingBox.top,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final right = translateX(
        face.boundingBox.right,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      final bottom = translateY(
        face.boundingBox.bottom,
        size,
        imageSize,
        rotation,
        cameraLensDirection,
      );
      //front 1682.0,2554.0,3530.0,4402.0
      //left 1329.0-,2305.0=,3547.0=,4523.0
      //right 1978.0+,2230.0=,4386.0+,4676.0

      //ไกล 1957,2945,3178,4166
      //ใกล้ 261,790,4797,6678
      /*canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint1,
      );*/

      // void paintContour(FaceContourType type) {
      //   final contour = face.contours[type];
      //   if (contour?.points != null) {
      //     for (final Point point in contour!.points) {
      //       canvas.drawCircle(
      //           Offset(
      //             translateX(
      //               point.x.toDouble(),
      //               size,
      //               imageSize,
      //               rotation,
      //               cameraLensDirection,
      //             ),
      //             translateY(
      //               point.y.toDouble(),
      //               size,
      //               imageSize,
      //               rotation,
      //               cameraLensDirection,
      //             ),
      //           ),
      //           1,
      //           paint1);
      //     }
      //   }
      // }

      void paintLandmark(FaceLandmarkType type) {
        final landmark = face.landmarks[type];
        if ((landmark?.position != null)&&landmark!.type==FaceLandmarkType.noseBase) {
          canvas.drawCircle(
              Offset(
                translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
              ),
              2,
              paint2);
        }
        else{
          
        }
      if ((landmark?.position != null)&&landmark!.type==FaceLandmarkType.noseBase) {
        TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: '${landmark?.position}'/*+',${landmark?.position}'*/,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            translateX(
                  landmark!.position.x.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ) -
                textPainter.width / 2,
            translateY(
                  landmark.position.y.toDouble(),
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ) +
                5, // ลดลงของข้อความเพื่อไม่ให้ทับกับวงกลม
          ),
        );
        }
      }

      // for (final type in FaceContourType.values) {
      //   paintContour(type);
      // }

      for (final type in FaceLandmarkType.values) {
        paintLandmark(type);
      }
    }
    
  }
  
  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }

}
