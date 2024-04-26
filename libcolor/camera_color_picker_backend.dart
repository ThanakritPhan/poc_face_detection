import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:pickcamera/Painter/face_detector_painter.dart';

class CameraColorPickerBackend extends StatefulWidget {
  const CameraColorPickerBackend(
      {Key? key,
      required this.customPaint,
      this.onCameraFeedReady,
      this.stopProcess = false,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.front})
      : super(key: key);

  final CustomPaint? customPaint;
  final bool? stopProcess;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraColorPickerBackend> createState() =>
      _CameraColorPickerBackendState();
}

Uint8List? bytes;
int f = 0;
Color middleColor = Color.fromARGB(255, 14, 235, 255);
int height = 0;
int width = 0;

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

class _CameraColorPickerBackendState extends State<CameraColorPickerBackend> {
  static List<CameraDescription> _cameras = [];
  int _cameraIndex = -1;
  bool _changingCameraLens = false;
  CameraDescription? _currentCamera;

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
  int blink = 0;
  String? actionText = "มองตรง และกระพริบตา";
  String? action = "หน้าตรง";

  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _currentExposureOffset = 0.0;

  @override
  void initState() {
    super.initState();
    //_currentCamera = _cameras.isNotEmpty ? _cameras.first : null;
    _initializeCamera();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  Future _switchLiveCamera() async {
    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    _currentCamera = _cameras[_cameraIndex];
    await _camera!.stopImageStream();
    await _camera!.dispose();

    _camera = CameraController(
      _currentCamera!,
      ResolutionPreset.veryHigh,
    );
    await _camera!.initialize();
    await _camera!
        .startImageStream((CameraImage image) => _processCameraImage(image));

    setState(() => _changingCameraLens = false);
  }

  Color _getMIddleColorFromYUV420(CameraImage image) {
    width = image.width;
    height = image.height;

    int? bytesPerRow = image.planes[2].bytesPerRow;
    int? bytesPerPixel = image.planes[2].bytesPerPixel;

    int x = (width / 2).floor() - 1;
    int y = (height / 2).floor() - 1;
// print(width);
// print(y);
    int hexFF = 255;
    int uvIndex =
        (bytesPerPixel! * (x / 2).floor()) + (bytesPerRow * ((y / 2).floor()));
    int index = (y * width) + x;
// print(uvIndex);
// print(index);
    int yp = image.planes[0].bytes[index];
    int up = image.planes[1].bytes[uvIndex];
    int vp = image.planes[2].bytes[uvIndex];

    int rt = (yp + vp * 1436 / 1024 - 179).round();
    int gt = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round();
    int bt = (yp + up * 1814 / 1024 - 227).round();
    int r = clamp(0, 255, rt);
    int g = clamp(0, 255, gt);
    int b = clamp(0, 255, bt);

    var newClr = (hexFF << 24) | (b << 16) | (g << 8) | r;

    // print(abgrToColor(newClr));

    return abgrToColor(newClr);
  }

  Color abgrToColor(int argbColor) {
    int r = (argbColor >> 16) & 0xFF;
    int b = argbColor & 0xFF;
    int hex = (argbColor & 0xFF00FF00) | (b << 16) | r;
    return Color(hex);
  }

  int clamp(int lower, int higher, int val) {
    if (val < lower) {
      return 0;
    } else if (val > higher) {
      return 255;
    } else {
      return val;
    }
  }

  CameraController? _camera;
  bool _cameraInitialized = false;
  void _initializeCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    // Get list of cameras of the device

    List<CameraDescription> cameras = await availableCameras();
    // Create the CameraController
    _camera = CameraController(
      cameras[1],
      ResolutionPreset.max,
      enableAudio: false,
      // imageFormatGroup: Platform.isAndroid
      //   ? ImageFormatGroup.nv21
      //   : ImageFormatGroup.bgra8888,
    );
    // Initialize the CameraController
    _camera!.initialize().then((_) async {
      // Start ImageStream
      await _camera!
          .startImageStream((CameraImage image) => _processCameraImage(image));
      setState(() {
        _cameraInitialized = true;
      });
      _camera?.getMinZoomLevel().then((value) {
        _currentZoomLevel = value;
        _minAvailableZoom = value;
      });
      _camera?.getMaxZoomLevel().then((value) {
        _maxAvailableZoom = value;
      });
      _currentExposureOffset = 0.0;
      _camera?.getMinExposureOffset().then((value) {
        _minAvailableExposureOffset = value;
      });
      _camera?.getMaxExposureOffset().then((value) {
        _maxAvailableExposureOffset = value;
      });
      setState(() {});
    });
  }

  var inputImage;
  var nv21;
  void _processCameraImage(CameraImage image) async {
    setState(() {
      middleColor = _getMIddleColorFromYUV420(image);
      count+=0.03;
      //count=1;
    });

    //ต้องแปลง yuv -> nv21 (android)
    // nv21 = await yuv420ToNV21(image);
    // if (nv21 != null) {
    // inputImage = await _inputImageFromCameraImage(image);
    // }

    // if (inputImage != null) {
    //   await _processImage(inputImage);
    // }
  }
  //-------------->

  // PROCESSIMAGE
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

        for (final face in faces) {
          text += 'face: ${face.boundingBox}\n\n';
        }
        _text = text;
      } else {}
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

  //YUV_420_888 to NV21
  List<int> yuv420ToNV21(CameraImage image) {
    int width = image.width;
    int height = image.height;
    int ySize = width * height;
    int uvSize = width * height ~/ 4;

    List<int> nv21 = List<int>.from(List<int>.filled(ySize + uvSize * 2, 0));

    Uint8List yBuffer = image.planes[0].bytes;
    Uint8List uBuffer = image.planes[1].bytes;
    Uint8List vBuffer = image.planes[2].bytes;

    int rowStrideY = image.planes[0].bytesPerRow;
    int rowStrideUV = image.planes[1].bytesPerRow;

    int pos = 0;

    if (rowStrideY == width) {
      // Copy Y directly
      nv21.setRange(0, ySize, yBuffer);
      pos += ySize;
    } else {
      // Copy Y row by row
      for (int i = 0; i < height; i++) {
        nv21.setRange(pos, pos + width,
            yBuffer.sublist(i * rowStrideY, i * rowStrideY + width));
        pos += width;
      }
    }

    if (rowStrideUV == width) {
      // UV data is interleaved
      for (int i = 0; i < uvSize; i++) {
        nv21[pos++] = vBuffer[i];
        nv21[pos++] = uBuffer[i];
      }
    } else {
      // UV data is not interleaved
      for (int i = 0; i < height / 2; i++) {
        for (int j = 0; j < width / 2; j++) {
          nv21[pos++] = vBuffer[i * rowStrideUV + j];
          nv21[pos++] = uBuffer[i * rowStrideUV + j];
        }
      }
    }

    return nv21;
  }

  // INPUTIMAGE
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_camera == null) return null;

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/android/src/main/java/com/google_mlkit_commons/InputImageConverter.java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/ios/Classes/MLKVisionImage%2BFlutterPlugin.m
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas: https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/example/lib/vision_detector_views/painters/coordinates_translator.dart
    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    // print(
    //     'lensDirection: ${camera.lensDirection}, sensorOrientation: $sensorOrientation, ${_controller?.value.deviceOrientation} ${_controller?.value.lockedCaptureOrientation} ${_controller?.value.isCaptureOrientationLocked}');
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_camera!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      print('rotationCompensation: $rotationCompensation');
    }
    if (rotation == null) return null;
    // print('final rotation: $rotation');

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    print(format);
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  //-------------->
  @override
  Widget build(BuildContext context) {
    if (count >= 3.5 && count < 5.0) {
      return Scaffold(
        body: Stack(
          children: [
            if (_cameraInitialized)
              SizedBox(
                height: width * 1.0,
                width: height * 1.0,
                child: AspectRatio(
                  aspectRatio: _camera!.value.aspectRatio,
                  child: CameraPreview(
                    _camera!,
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator()),
            Container(
              color: Color.fromARGB(255, 255, 0, 0),
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(_text??"-",style: TextStyle(color: Colors.white)),
                  Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(7.0),
                    margin: const EdgeInsets.only(bottom: 70.0),
                    child: Column(
                      children: [
                        Text(
                            "Blink: ${blink}\n"
                            "faceCount: ${faceCount}\n"
                            "headEulerAngleX: ${headEulerAngleX}\n"
                            "headEulerAngleY: ${headEulerAngleY}\n"
                            "headEulerAngleZ: ${headEulerAngleZ}\n"
                            "landmarksNoseBase: ${landmarksNoseBase}\n",
                            style: TextStyle(color: Colors.white)),
                        Text("color: ${middleColor}\n",
                            style: TextStyle(color: middleColor)),
                        Text(
                            "blue: ${middleColor.blue} green: ${middleColor.green} red: ${middleColor.red*7654321}\n",
                            style: TextStyle(color: middleColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "o",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      );
    } else if (count <= 5.0) {
      return Scaffold(
        body: Stack(
          children: [
            if (_cameraInitialized)
              Container(
                  color: Colors.black,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Center(
                        child: CameraPreview(
                          _camera!,
                        ),
                      ),
                    ],
                  ))
            else
              const Center(child: CircularProgressIndicator()),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(right: 20.0, top: 70.0),
                child: RawMaterialButton(
                  onPressed: () async {
                    _cameraInitialized = false;
                    await _camera!.dispose();
                    Navigator.pop(context, middleColor.toString());
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
                    margin:
                        EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 12),
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
            Padding(
              padding: EdgeInsets.fromLTRB(0, height - 0, 0, 0),
              child: GestureDetector(
                onTap: () async {
                  _cameraInitialized = false;
                  await _camera!.dispose();
                  if (!context.mounted) return;
                  Navigator.pop(context, middleColor.toString());
                },
                // child: Container(
                //   color: middleColor,
                // ),
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
                    padding: const EdgeInsets.all(7.0),
                    margin: const EdgeInsets.only(bottom: 70.0),
                    child: Column(
                      children: [
                        Text(
                            "Blink: ${blink}\n"
                            "faceCount: ${faceCount}\n"
                            "headEulerAngleX: ${headEulerAngleX}\n"
                            "headEulerAngleY: ${headEulerAngleY}\n"
                            "headEulerAngleZ: ${headEulerAngleZ}\n"
                            "landmarksNoseBase: ${landmarksNoseBase}\n",
                            style: TextStyle(color: Colors.white)),
                        Text("color: ${middleColor}\n",
                            style: TextStyle(color: middleColor)),
                        Text(
                            "blue: ${middleColor.blue} green: ${middleColor.green} red: ${middleColor.red*7654321}\n",
                            style: TextStyle(color: middleColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "o",
                style: TextStyle(color: Colors.black),
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
}
