import 'package:flutter/material.dart';
import 'package:mlkit_facedetection/face_detector_view.dart';
import 'package:mlkit_facedetection/liveness_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "DETECTION",
      home: MyHomePage(
        title: "Face Detection",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[100],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[400],
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin:EdgeInsets.only(top: 40,bottom: 10,left: 10,right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FaceDetectorView()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Actions Face Detector "),
                    Icon(Icons.not_started_sharp),
                    
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LivenessDetectorView()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Liveness Face Detector "),
                    Icon(Icons.not_started_sharp),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
