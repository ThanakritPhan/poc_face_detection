import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mlkit_facedetection/camera_view.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,

    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  int? faceCount;
  String? position;
  double? headEulerAngleX;
  double? headEulerAngleY;
  double? headEulerAngleZ;
  double? leftEyeOpenProbability;
  double? rightEyeOpenProbability;
  double? smilingProbability;
  String? landmarksBottomMouth;
  String? landmarksLMouth;
  String? landmarksRMouth;
  String? landmarksLEye;
  String? landmarksREye;
  String? landmarksNoseBase;
  String? landmarksRCheek;
  String? landmarksLCheek;
  String? landmarksLEar;
  String? landmarksREar;
  String? ct;
  String? ctl;

  double count = 0.0;

  var _cameraLensDirection = CameraLensDirection.front;
  String? actionText = "";
  String? action = "";
  var actions = [
    "หน้าตรง",
    "ก้มหัว",
    "เงยหน้า",
    "อ้าปาก",
    "หลับตา",
    "เอียงซ้าย",
    "เอียงขวา",
    "หันขวา",
    "หันซ้าย"
  ];

  bool isStop = false;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CameraView(
            customPaint: _customPaint,
            onImage: _processImage,
            initialCameraLensDirection: _cameraLensDirection,
            onCameraLensDirectionChanged: (value) =>
                _cameraLensDirection = value,
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, top: 70.0),
              child: RawMaterialButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 10, left: 20, right: 10, top: 10),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                ),
                shape: CircleBorder(),
                fillColor: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Container(
                  margin: EdgeInsets.all(5.0),
                  padding: const EdgeInsets.all(0.0),
                  color: Colors.black,
                  child: Text("${action} 3 วินาที",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16.0)),
                ),
                Container(
                  margin: EdgeInsets.all(15.0),
                  padding: const EdgeInsets.all(10.0),
                  color: Color.fromARGB(95, 255, 255, 255),
                  child: Text(actionText ?? "",
                      style: const TextStyle(
                          color: Color.fromARGB(255, 0, 0, 0), fontSize: 16.0)),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(_text??"-",style: TextStyle(color: Colors.white)),
                // Container(
                //   color: Colors.black54,
                //   padding: const EdgeInsets.all(10.0),
                //   margin: const EdgeInsets.only(bottom: 50.0),
                //   child: Text(
                //       "faceCount: ${faceCount}\n"
                //       "count: ${count.toInt()}\n"
                //       "position: ${position}\n"
                //       "headEulerAngleX: ${headEulerAngleX}\n"
                //       "headEulerAngleY: ${headEulerAngleY}\n"
                //       "headEulerAngleZ: ${headEulerAngleZ}\n"
                //       "leftEyeOpenProbability: ${leftEyeOpenProbability}\n"
                //       "rightEyeOpenProbability: ${rightEyeOpenProbability}\n"
                //       "smilingProbability: ${smilingProbability}\n"
                //       "landmarksBottomMouth: ${landmarksBottomMouth}\n"
                //       "landmarksLMouth: ${landmarksLMouth}\n"
                //       "landmarksRMouth: ${landmarksRMouth}\n"
                //       // "landmarksLEye: ${landmarksLEye}\n"
                //       // "landmarksREye: ${landmarksREye}\n"
                //       // "landmarksLEar: ${landmarksLEar}\n"
                //       // "landmarksREar: ${landmarksREar}\n"
                //       // "landmarksLCheek: ${landmarksLCheek}\n"
                //       // "landmarksRCheek: ${landmarksRCheek}\n"
                //       // "landmarksNoseBase: ${landmarksNoseBase}\n"
                //       "",
                //       style: TextStyle(color: Colors.white)),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int actionsIndex = 0;
  int i = 0;
  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    actionsIndex = i % actions.length;
    action = actions[actionsIndex];
    try {
      final faces = await _faceDetector.processImage(inputImage);
      if (inputImage.metadata?.size != null &&
          inputImage.metadata?.rotation != null) {
        headEulerAngleX = faces.first.headEulerAngleX;
        headEulerAngleY = faces.first.headEulerAngleY;
        headEulerAngleZ = faces.first.headEulerAngleZ;
        leftEyeOpenProbability = faces.first.leftEyeOpenProbability;
        rightEyeOpenProbability = faces.first.rightEyeOpenProbability;
        smilingProbability = faces.first.smilingProbability;
        faceCount = faces.length;
        position = "${faces.first.boundingBox}";
        // FaceLandmarkType, FaceLandmark?
        landmarksBottomMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.bottomMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.bottomMouth]!.position.y}";
        landmarksLMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftMouth]!.position.y}";
        landmarksRMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightMouth]!.position.y}";
        landmarksLEye =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftEye]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftEye]!.position.y}";
        landmarksREye =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightEye]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightEye]!.position.y}";
        landmarksLEar =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftEar]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftEar]!.position.y}";
        landmarksREar =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightEar]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightEar]!.position.y}";
        landmarksLCheek =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftCheek]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftCheek]!.position.y}";
        landmarksRCheek =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightCheek]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightCheek]!.position.y}";
        landmarksNoseBase =
            "X: ${faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y}";
        ct =
            "X: ${faces.first.contours[FaceContourType.face]!.type.name} | Y: ${faces.first.contours[FaceContourType.face]!.type.name}";
        String text = 'Faces found: ${faces.length}\n\n';
        //หน้าตรง
        if (action == "หน้าตรง") {
          actionText = "วางหน้าตรง";
          if (((headEulerAngleX! >= -5) && (headEulerAngleX! <= 5)) &&
              ((headEulerAngleY! >= -5) && (headEulerAngleY! <= 3)) &&
              ((headEulerAngleZ! >= -2) && (headEulerAngleZ! <= 2))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //หน้าตรง

        //อ้าปาก
        if (action == "อ้าปาก") {
          actionText = "วางหน้าตรง";
          if (((headEulerAngleX! >= -4) && (headEulerAngleX! <= 9)) &&
              ((headEulerAngleY! >= -3) && (headEulerAngleY! <= 3))) {
            actionText = "อ้าปาก";
            if ((faces.first.landmarks[FaceLandmarkType.bottomMouth]!.position
                        .y -
                    faces.first.landmarks[FaceLandmarkType.leftMouth]!.position
                        .y >=
                45)) {
              actionText = "${count.toInt()}";
              setState(() {
                count += 0.33;
              });
            }

            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //อ้าปาก

        //หลับตา
        if (action == "หลับตา") {
          actionText = "วางหน้าตรง";
          if (((headEulerAngleX! >= -5) && (headEulerAngleX! <= 7)) &&
              ((headEulerAngleY! >= -5) && (headEulerAngleY! <= 5))) {
            actionText = "หลับตา";
            if ((leftEyeOpenProbability! <= 0.2) &&
                (rightEyeOpenProbability! <= 0.2)) {
              actionText = "${count.toInt()}";
              setState(() {
                count += 0.33;
              });
            }

            if (count >= 1) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //หลับตา

        //หันซ้าย
        if (action == "หันซ้าย") {
          actionText = "หันหน้าทางซ้าย";
          if (((headEulerAngleX! >= 2) && (headEulerAngleX! <= 17)) &&
              ((headEulerAngleY! >= 40) && (headEulerAngleY! <= 60))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //หันซ้าย

        //หันขวา
        if (action == "หันขวา") {
          actionText = "หันหน้าทางขวา";
          if (((headEulerAngleX! >= 2) && (headEulerAngleX! <= 15)) &&
              ((headEulerAngleY! >= -60) && (headEulerAngleY! <= -40))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //หันขวา

        //ก้มหัว
        if (action == "ก้มหัว") {
          actionText = "ก้มหัวลง";
          if (((headEulerAngleX! >= -32) && (headEulerAngleX! <= -16))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //ก้มหัว

        //เงยหน้า
        if (action == "เงยหน้า") {
          actionText = "เงยหน้าขึ้น";
          if (((headEulerAngleX! >= 30) && (headEulerAngleX! <= 55))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //เงยหน้า

        //เอียงขวา
        if (action == "เอียงขวา") {
          actionText = "เอียงหน้าทางขวา";
          if (((headEulerAngleX! >= 2) && (headEulerAngleX! <= 12)) &&
              ((headEulerAngleY! >= -39) && (headEulerAngleY! <= -18))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //เอียงขวา

        //เอียงซ้าย
        if (action == "เอียงซ้าย") {
          actionText = "เอียงหน้าทางซ้าย";
          if (((headEulerAngleX! >= 2) && (headEulerAngleX! <= 9)) &&
              ((headEulerAngleY! >= 18) && (headEulerAngleY! <= 37))) {
            actionText = "${count.toInt()}";
            setState(() {
              count += 0.33;
            });
            if (count >= 3) {
              count = 0.0;
              i++;
            }
          } else {
            count = 0.0;
            // actionText = "วางหน้าให้ตรง";
          }
        }
        //เอียงซ้าย

        if (i == actions.length) {
          Navigator.pop(context);
          i++;
        }

        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
        // _customPaint = CustomPaint(painter: painter);
      } else {
        headEulerAngleX = faces.first.headEulerAngleX;
        headEulerAngleY = faces.first.headEulerAngleY;
        headEulerAngleZ = faces.first.headEulerAngleZ;
        leftEyeOpenProbability = faces.first.leftEyeOpenProbability;
        rightEyeOpenProbability = faces.first.rightEyeOpenProbability;
        smilingProbability = faces.first.smilingProbability;
        faceCount = faces.length;
        position = "${faces.first.boundingBox}";
        // FaceLandmarkType, FaceLandmark?
        landmarksBottomMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.bottomMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.bottomMouth]!.position.y}";
        landmarksLMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftMouth]!.position.y}";
        landmarksRMouth =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightMouth]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightMouth]!.position.y}";
        landmarksLEye =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftEye]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftEye]!.position.y}";
        landmarksREye =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightEye]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightEye]!.position.y}";
        landmarksLEar =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftEar]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftEar]!.position.y}";
        landmarksREar =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightEar]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightEar]!.position.y}";
        landmarksLCheek =
            "X: ${faces.first.landmarks[FaceLandmarkType.leftCheek]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.leftCheek]!.position.y}";
        landmarksRCheek =
            "X: ${faces.first.landmarks[FaceLandmarkType.rightCheek]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.rightCheek]!.position.y}";
        landmarksNoseBase =
            "X: ${faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x} | Y: ${faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y}";
        String text = 'Faces found: ${faces.length}\n\n';
        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
        // TODO: set _customPaint to draw boundingRect on top of image
        _customPaint = null;
      }
    } catch (e) {
      count = 0.0;
      faceCount = 0;
      position = "";
      headEulerAngleX = null;
      headEulerAngleY = null;
      headEulerAngleZ = null;
      leftEyeOpenProbability = null;
      rightEyeOpenProbability = null;
      smilingProbability = null;
      landmarksBottomMouth = "X: ${null} | Y: ${null}";
      landmarksLMouth = "X: ${null} | Y: ${null}";
      landmarksRMouth = "X: ${null} | Y: ${null}";
      landmarksLEye = "X: ${null} | Y: ${null}";
      landmarksREye = "X: ${null} | Y: ${null}";
      landmarksLEar = "X: ${null} | Y: ${null}";
      landmarksREar = "X: ${null} | Y: ${null}";
      landmarksLCheek = "X: ${null} | Y: ${null}";
      landmarksRCheek = "X: ${null} | Y: ${null}";
      landmarksNoseBase = "X: ${null} | Y: ${null}";
      print("catch : ${e}");
    }

    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
