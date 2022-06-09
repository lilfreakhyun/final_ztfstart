import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:learning_input_image/learning_input_image.dart';
import 'package:learning_object_detection/learning_object_detection.dart';
import 'package:provider/provider.dart';

class LearningObjectDetection extends StatefulWidget {
  @override
  _LearningObjectDetectionState createState() =>
      _LearningObjectDetectionState();
}

class _LearningObjectDetectionState extends State<LearningObjectDetection> {
  LearningObjectDetectionState get state =>
      Provider.of<LearningObjectDetectionState>(context, listen: false);

  ObjectDetector _detector = ObjectDetector(
    isStream: false,
    enableClassification: true,
    enableMultipleObjects: true,
  );

  @override
  void dispose() {
    _detector.dispose();
    super.dispose();
  }

  Future<void> _detectObjects(InputImage image) async {
    if (state.isNotProcessing) {
      state.startProcessing();
      state.image = image;
      state.data = await _detector.detect(image);
      state.stopProcessing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputCameraView(
      cameraDefault: InputCameraType.rear,
      title: 'Object Detection & Tracking',
      onImage: _detectObjects,
      overlay: Consumer<LearningObjectDetectionState>(
        builder: (_, state, __) {
          if (state.isEmpty) {
            return Container();
          }

          Size originalSize = state.size!;
          Size size = MediaQuery.of(context).size;

          // if image source from gallery
          // image display size is scaled to 360x360 with retaining aspect ratio
          if (state.notFromLive) {
            if (originalSize.aspectRatio > 1) {
              size = Size(360.0, 360.0 / originalSize.aspectRatio);
            } else {
              size = Size(360.0 * originalSize.aspectRatio, 360.0);
            }
          }

          return ObjectOverlay(
            size: size,
            originalSize: originalSize,
            rotation: state.rotation,
            objects: state.data,
          );
        },
      ),
    );
  }
}

class LearningObjectDetectionState extends ChangeNotifier {
  InputImage? _image;
  List<DetectedObject> _data = [];
  bool _isProcessing = false;

  InputImage? get image => _image;
  List<DetectedObject> get data => _data;

  String? get type => _image?.type;
  InputImageRotation? get rotation => _image?.metadata?.rotation;
  Size? get size => _image?.metadata?.size;

  bool get isNotProcessing => !_isProcessing;
  bool get isEmpty => _data.isEmpty;
  bool get isFromLive => type == 'bytes';
  bool get notFromLive => !isFromLive;

  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  set image(InputImage? image) {
    _image = image;

    if (notFromLive) {
      _data = [];
    }
    notifyListeners();
  }

  set data(List<DetectedObject> data) {
    _data = data;
    notifyListeners();
  }
}
