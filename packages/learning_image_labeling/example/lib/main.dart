import 'package:flutter/material.dart';
import 'package:learning_image_labeling/learning_image_labeling.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
      ),
      home: ChangeNotifierProvider(
        create: (_) => ImageLabelingState(),
        child: ImageLabelingPage(),
      ),
    );
  }
}

class ImageLabelingPage extends StatefulWidget {
  @override
  _ImageLabelingPageState createState() => _ImageLabelingPageState();
}

class _ImageLabelingPageState extends State<ImageLabelingPage> {
  ImageLabelingState get state => Provider.of(context, listen: false);
  ImageLabeling _imageLabeling = ImageLabeling();

  @override
  void dispose() {
    _imageLabeling.dispose();
    super.dispose();
  }

  Future<void> _processLabeling(InputImage image) async {
    if (state.isNotProcessing) {
      state.startProcessing();
      state.image = image;
      state.labels = await _imageLabeling.process(image);
      state.stopProcessing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InputCameraView(
      cameraDefault: InputCameraType.rear,
      // resolutionPreset: ResolutionPreset.high,
      title: 'Image Labeling',
      onImage: _processLabeling,
      overlay: Consumer<ImageLabelingState>(
        builder: (_, state, __) {
          if (state.isEmpty) {
            return Container();
          }

          if (state.isProcessing && state.notFromLive) {
            return Center(
              child: Container(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Text(state.toString(),
                  style: TextStyle(fontWeight: FontWeight.w500)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ImageLabelingState extends ChangeNotifier {
  InputImage? _image;
  List<Label> _labels = [];
  bool _isProcessing = false;

  InputImage? get image => _image;
  List<Label> get labels => _labels;

  String? get type => _image?.type;
  InputImageRotation? get rotation => _image?.metadata?.rotation;
  Size? get size => _image?.metadata?.size;

  bool get isProcessing => _isProcessing;
  bool get isNotProcessing => !_isProcessing;
  bool get isEmpty => _labels.isEmpty;
  bool get notFromLive => type != 'bytes';

  void startProcessing() {
    _isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  set isProcessing(bool isProcessing) {
    _isProcessing = isProcessing;
    notifyListeners();
  }

  set image(InputImage? image) {
    _image = image;
    notifyListeners();
  }

  set labels(List<Label> labels) {
    _labels = labels;
    notifyListeners();
  }

  @override
  String toString() {
    List<String> result = labels.map((label) => label.label).toList();
    return result.join(', ');
  }
}
