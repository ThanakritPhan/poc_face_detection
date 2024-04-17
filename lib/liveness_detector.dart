import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mlkit_facedetection/camera_view.dart';

class LivenessDetectorView extends StatefulWidget {
  @override
  State<LivenessDetectorView> createState() => _LivenessDetectorViewState();
}

class _LivenessDetectorViewState extends State<LivenessDetectorView> {
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
  var _cameraLensDirection = CameraLensDirection.front;
  bool isStop = false;

  String thisface = "L";
  double count = 0.0;
  double leftEyeAverage = 0.0;
  double leftEyeAll = 0.0;
  double rightEyeAverage = 0.0;
  double rightEyeAll = 0.0;
  int blink = 0;
  String? actionText = "มองตรง และกระพริบตา";
  String? action = "หน้าตรง";
  bool trueeye = false;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 5.0) {
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
                    child: Text("${actionText} 4 วินาที",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16.0)),
                  ),
                  Container(
                    margin: EdgeInsets.all(15.0),
                    padding: const EdgeInsets.all(10.0),
                    color: Color.fromARGB(95, 255, 255, 255),
                    child: Text("${count.toInt()}",
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20.0)),
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
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(5.0),
                    margin: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                          "Blink: ${blink}\n"
                        // "faceCount: ${faceCount}\n"
                        // "position: ${position}\n"
                        // "headEulerAngleX: ${headEulerAngleX}\n"
                        // "headEulerAngleY: ${headEulerAngleY}\n"
                        // "headEulerAngleZ: ${headEulerAngleZ}\n"
                        // "leftEyeOpenProbability: ${leftEyeOpenProbability}\n"
                        // "rightEyeOpenProbability: ${rightEyeOpenProbability}\n"
                        // "smilingProbability: ${smilingProbability}\n"
                        // "landmarksBottomMouth: ${landmarksBottomMouth}\n"
                        // "landmarksLMouth: ${landmarksLMouth}\n"
                        // "landmarksRMouth: ${landmarksRMouth}\n"
                        // "trueeye: ${trueeye}\n"
                        // "landmarksLEye: ${landmarksLEye}\n"
                        // "landmarksREye: ${landmarksREye}\n"
                        // "landmarksLEar: ${landmarksLEar}\n"
                        // "landmarksREar: ${landmarksREar}\n"
                        // "landmarksLCheek: ${landmarksLCheek}\n"
                        // "landmarksRCheek: ${landmarksRCheek}\n"
                        // "landmarksNoseBase: ${landmarksNoseBase}\n"
                        "",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Text("${thisface}"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0, top: 0.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          count = 0.0;
                          blink = 0;
                          trueeye = false;
                        });
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text("again")
                      ),
                    ),
                  ),
                ],
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
                    child: Text("BLINK : ${blink}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 16.0)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

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

        if((leftEyeOpenProbability! >= 0.9 && rightEyeOpenProbability! >= 0.9)){
          trueeye = true;
        }

        if (action == "หน้าตรง") {
          actionText = "มองตรง และกระพริบตา";
          if (((headEulerAngleX! >= -5) && (headEulerAngleX! <= 5)) &&
              ((headEulerAngleY! >= -5) && (headEulerAngleY! <= 3)) &&
              ((headEulerAngleZ! >= -2) && (headEulerAngleZ! <= 2))) {
            if ((leftEyeOpenProbability! <= 0.5 ||
                rightEyeOpenProbability! <= 0.5) &&
                (trueeye == true)) {
              trueeye = false;
              setState(() {
                blink++;
              });
            }
            setState(() {
              count += 0.33;
            });
          } else {
            count = 0.0;
            blink = 0;
            trueeye = false;
            // actionText = "วางหน้าให้ตรง";
          }
        }

        if(blink > 0){
          thisface = "Successfully";
        }
        else{
          thisface = "Try Again";
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
