import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:pickcamera/Painter/face_detector_painter.dart';
import 'package:pickcamera/camera_color_picker.dart';
import 'package:pickcamera/camera_color_picker_backend.dart';

Color textcolor = middleColor;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Camera Color Picker Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Camera Color Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Color currentColor = Colors.blueAccent;
Color testcolor = Colors.red;

class _MyHomePageState extends State<MyHomePage> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );
  var _cameraLensDirection = CameraLensDirection.front;
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

  String thisface = "L";
  double count = 0.0;
  int blink = 0;
  String? actionText = "มองตรง และกระพริบตา";
  String? action = "หน้าตรง";
  bool trueeye = false;
  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      testcolor = middleColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // example-1 basic implementation
              CameraColorPicker(
                currentColor: currentColor,
                onColorChanged: (Color color) {
                  currentColor = color;
                  setState(() {});
                },
              ),
              const SizedBox(height: 50),
              const SizedBox(height: 50),

              //example-2 if you want to modify the appearance of the button ,but use container without a onTap functionality
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => CameraColorPicker(
              //                   currentColor: currentColor,
              //                   onColorChanged: (Color color) {
              //                   currentColor = color;
              //                   setState(() {});
              //                 })
              //                 )
              //                 );
              //   },
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //   ),
              // ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CameraColorPickerBackend(
                                customPaint: _customPaint,
                                initialCameraLensDirection:
                                    _cameraLensDirection,
                                onCameraLensDirectionChanged: (value) =>
                                    _cameraLensDirection = value,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${testcolor.toString()} Red:${testcolor.red} ,Green:${testcolor.green} , Blue:${testcolor.blue} Alpha:${testcolor.alpha}",
                      style: TextStyle(color: middleColor, fontSize: 10),
                    ),
                    //Icon(Icons.not_started_sharp),
                  ],
                ),
              ),
            ],
          ),
        ));
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
        // getPixelColor(Offset(
        //     faces.first.landmarks[FaceLandmarkType.noseBase]!.position.x
        //         .toDouble(),
        //     faces.first.landmarks[FaceLandmarkType.noseBase]!.position.y
        //         .toDouble()));
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
}
