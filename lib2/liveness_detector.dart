import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mlkit_facedetection/Painter/face_detector_painter.dart';
import 'package:mlkit_facedetection/camera_view.dart';

class LivenessDetectorView extends StatefulWidget {
  @override
  State<LivenessDetectorView> createState() => _LivenessDetectorViewState();
}

class _LivenessDetectorViewState extends State<LivenessDetectorView> {
  final imageKey = GlobalKey();
  final onColorPicked = ValueNotifier<Color>(Colors.deepOrange);
  List<int> imageDataList = List<int>.empty(growable: false);
  late Image image;
  GradientData get gradient => gradientData[3];
  Size _lastWindowSize = Size.zero;

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
    if (count >= 99 && count < 5) {
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
            Container(
              color: Colors.red,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "${count.toInt()}",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else if (count <= 10.0) {
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
                        "faceCount: ${faceCount}\n"
                        "position: ${position}\n"
                        "headEulerAngleX: ${headEulerAngleX}\n"
                        "headEulerAngleY: ${headEulerAngleY}\n"
                        "headEulerAngleZ: ${headEulerAngleZ}\n"
                        "leftEyeOpenProbability: ${leftEyeOpenProbability}\n"
                        "rightEyeOpenProbability: ${rightEyeOpenProbability}\n"
                        "smilingProbability: ${smilingProbability}\n"
                        "landmarksBottomMouth: ${landmarksBottomMouth}\n"
                        "landmarksLMouth: ${landmarksLMouth}\n"
                        "landmarksRMouth: ${landmarksRMouth}\n"
                        "trueeye: ${trueeye}\n"
                        // "landmarksLEye: ${landmarksLEye}\n"
                        // "landmarksREye: ${landmarksREye}\n"
                        // "landmarksLEar: ${landmarksLEar}\n"
                        // "landmarksREar: ${landmarksREar}\n"
                        // "landmarksLCheek: ${landmarksLCheek}\n"
                        // "landmarksRCheek: ${landmarksRCheek}\n"
                        "landmarksNoseBase: ${landmarksNoseBase}\n"
                        "",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            // GestureDetector(
            //   onPanDown: (event) async {
            //     final windowSize = MediaQuery.of(context).size;

            //     /// re-capture the image only when the window size changed.
            //     /// We might use a LayoutBuilder or similar as well. Is just a way
            //     /// to optimize the CPU required to draw Image.
            //     if (_lastWindowSize != windowSize) {
            //       print('capture image');
            //       _lastWindowSize = windowSize;
            //       imageDataList = await captureImage();
            //     }
            //     getPixelColor(event.localPosition);
            //   },
            //   onPanUpdate: (event) {
            //     getPixelColor(event.localPosition);
            //   },
            //   child: RepaintBoundary(
            //     key: imageKey,
            //     child: DecoratedBox(
            //       decoration: BoxDecoration(
            //         //gradient: LinearGradient(colors: gradient.colors),
            //       ),
            //       child: Center(
            //         // child: Text(
            //         //   gradient.name,
            //         //   style: TextStyle(
            //         //     foreground: Paint()
            //         //       ..color = Colors.white
            //         //       ..blendMode = BlendMode.overlay,
            //         //     fontWeight: FontWeight.w200,
            //         //     fontSize: 80,
            //         //     shadows: [
            //         //       Shadow(color: Colors.black26, blurRadius: 20)
            //         //     ],
            //         //   ),
            //         // ),
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "o",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Flexible(
                      child: Text(
                    'picked color: ',
                    overflow: TextOverflow.ellipsis,
                  )),
                  ValueListenableBuilder<Color>(
                    valueListenable: onColorPicked,
                    builder: (_, color, child) => Text(
                      '#${color.value.toRadixString(16)}',
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 1.5,
                            )
                          ]),
                    ),
                  ),
                ],
              ),
            )),
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
                          child: Text("again")),
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
        final painter = FaceDetectorPainter(
          faces,
          inputImage.metadata!.size,
          inputImage.metadata!.rotation,
          _cameraLensDirection,
        );
        _customPaint = CustomPaint(painter: painter);
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

        if ((leftEyeOpenProbability! >= 0.9 &&
            rightEyeOpenProbability! >= 0.9)) {
          trueeye = true;
        }

        if (action == "หน้าตรง") {
          actionText = "มองตรง และกระพริบตา";
          if (((headEulerAngleX! >= -5) && (headEulerAngleX! <= 5)) &&
              ((headEulerAngleY! >= -5) && (headEulerAngleY! <= 3)) &&
              ((headEulerAngleZ! >= -2) && (headEulerAngleZ! <= 2))) {
            if ((leftEyeOpenProbability! <= 0.3 ||
                    rightEyeOpenProbability! <= 0.3) &&
                (trueeye == true)) {
              trueeye = false;
              setState(() {
                blink++;
              });
            }
            setState(() {
              count += 0.33;
              getPixelColor(Offset(
                  faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x
                      .toDouble(),
                  faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y
                      .toDouble()));
            });
          } else {
            count = 0.0;
            blink = 0;
            trueeye = false;
            // actionText = "วางหน้าให้ตรง";
          }
        }

        if (blink > 0) {
          thisface = "Successfully";
        } else {
          thisface = "Try Again";
        }

        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
        //--------------------->
        // if(true) {
        //   // ตำแหน่งของ landmark nosebase
        //   double noseBaseX =
        //       faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x.toDouble();
        //   double noseBaseY =
        //       faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y.toDouble();

        //   // ใช้ตำแหน่งของ landmark nosebase เพื่อดึงค่าสี
          getPixelColor(Offset(faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x.toDouble(),  faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y.toDouble()));
        // }

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
        } //FaceLandmarkType.noseBase
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

  void getPixelColor(Offset position) {
    /// no process if we in a race condition while image is being captured
    /// and mouse/touch dragged around the screen.
     if (imageDataList.isEmpty) return;

    final w = ((MediaQuery.of(context).size.width)).round();
    final h = ((MediaQuery.of(context).size.height)).round();
    final x = position.dx.round().clamp(0, w - 1);

    /// -1: index is 0 based.
    final y = position.dy
        .round()
        .clamp(0, h - 1); //position.dy.round().clamp(0, h - 1);

    final list = imageDataList;
    var i = y * (w * 4) + x * 4;

    /// pixels are encoded in `RGBA` in the List.
    onColorPicked.value = Color.fromARGB(
      list[i + 3],
      list[i],
      list[i + 1],
      list[i + 2],
    );
  }

  Future<List<int>> captureImage() async {
    final ro =
        imageKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    image = await ro.toImage();
    final bytes = (await image.toByteData(format: ImageByteFormat.rawRgba))!;
    //getPixelColor(Offset(2, 2));
    return bytes.buffer.asUint8List().toList(growable: false);
  }
}

class GradientData {
  final List<Color> colors;
  final String name;

  const GradientData({required this.colors, required this.name});

  GradientData.string(String name, List<String> colors)
      : this.colors = colorsFromStrings(colors),
        this.name = name;

  static List<Color> colorsFromStrings(List<String> list) =>
      list.map((str) => Color(int.parse(str.replaceAll('#', '0xff')))).toList();
}

final gradientData = <GradientData>[
  GradientData(
    name: 'Dark Skies',
    colors: [Color(0xff4B79A1), Color(0xff283E51)],
  ),
  GradientData.string('Red Sunset', ['#355C7D', '#6C5B7B', '#C06C84']),
  GradientData.string('Shifter', ['#bc4e9c', '#f80759']),
  GradientData.string('Wedding Day Blues', ['#40E0D0', '#FF8C00', '#FF0080']),
  GradientData.string('Sand to Blue', ['#3E5151', '#DECBA4']),
  GradientData.string('Quepal', ['#11998e', '#38ef7d']),
  GradientData.string('Sublime Light', ['#FC5C7D', '#6A82FB']),
  GradientData.string('Sublime Vivid', ['#FC466B', '#3F5EFB']),
  GradientData.string('Bighead', ['#c94b4b', '#4b134f']),
  GradientData.string('Taran Tado', ['#23074d', '#cc5333']),
  GradientData.string('Relaxing red', ['#fffbd5', '#b20a2c']),
  GradientData.string('Lawrencium', ['#0f0c29', '#302b63', '#24243e']),
  GradientData.string('Ohhappiness', ['#00b09b', '#96c93d']),
  GradientData.string('Delicate', ['#D3CCE3', '#E9E4F0']),
];
