import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'vision/digital_ink_recognition.dart';
import 'vision/face_detection.dart';
import 'vision/image_labeling.dart';
import 'vision/oject_detection.dart';
import 'vision/text_recognition.dart';

void main() {
  runApp(LearningApp());
}

class LearningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
      ),
      home: LearningHome(),
    );
  }
}

class LearningHome extends StatefulWidget {
  @override
  _LearningHomeState createState() => _LearningHomeState();
}

class _LearningHomeState extends State<LearningHome> {
  Widget _menuItem(String text, Widget page) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 7),
      child: ListTile(
        title: Text(text),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('기-log ML 연동'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _menuItem(
              'Text Recognition',
              ChangeNotifierProvider(
                create: (_) => LearningTextRecognitionState(),
                child: LearningTextRecognition(),
              ),
            ),
            _menuItem(
              'Face Detection',
              ChangeNotifierProvider(
                create: (_) => LearningFaceDetectionState(),
                child: LearningFaceDetection(),
              ),
            ),
            _menuItem(
              'Image Labeling',
              ChangeNotifierProvider(
                create: (_) => LearningImageLabelingState(),
                child: LearningImageLabeling(),
              ),
            ),
            _menuItem(
              'Object Detection & Tracking',
              ChangeNotifierProvider(
                create: (_) => LearningObjectDetectionState(),
                child: LearningObjectDetection(),
              ),
            ),
            _menuItem(
              'Digital Ink Recognition',
              ChangeNotifierProvider(
                create: (_) => LearningDigitalInkRecognitionState(),
                child: LearningDigitalInkRecognition(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
