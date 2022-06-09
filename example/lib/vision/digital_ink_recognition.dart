import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:learning_digital_ink_recognition/learning_digital_ink_recognition.dart';
import 'package:learning_input_image/learning_input_image.dart';
import 'package:provider/provider.dart';

class LearningDigitalInkRecognition extends StatefulWidget {
  @override
  _LearningDigitalInkRecognitionState createState() =>
      _LearningDigitalInkRecognitionState();
}

class _LearningDigitalInkRecognitionState
    extends State<LearningDigitalInkRecognition> {
  final String _model = 'en-US';

  LearningDigitalInkRecognitionState get state =>
      Provider.of<LearningDigitalInkRecognitionState>(context, listen: false);
  late DigitalInkRecognition _recognition;

  double get _width => MediaQuery.of(context).size.width;
  double _height = 480;

  @override
  void initState() {
    _recognition = DigitalInkRecognition(model: _model);
    super.initState();
  }

  @override
  void dispose() {
    _recognition.dispose();
    super.dispose();
  }

  // need to call start() at the first time before painting the ink
  Future<void> _init() async {
    //print('Writing Area: ($_width, $_height)');
    await _recognition.start(writingArea: Size(_width, _height));
    // always check the availability of model before being used for recognition
    await _checkModel();
  }

  // reset the ink recognition
  Future<void> _reset() async {
    state.reset();
    await _recognition.start(writingArea: Size(_width, _height));
  }

  Future<void> _checkModel() async {
    bool isDownloaded = await DigitalInkModelManager.isDownloaded(_model);

    if (!isDownloaded) {
      await DigitalInkModelManager.download(_model);
    }
  }

  Future<void> _actionDown(Offset point) async {
    state.startWriting(point);
    await _recognition.actionDown(point);
  }

  Future<void> _actionMove(Offset point) async {
    state.writePoint(point);
    await _recognition.actionMove(point);
  }

  Future<void> _actionUp() async {
    state.stopWriting();
    await _recognition.actionUp();
  }

  Future<void> _startRecognition() async {
    if (state.isNotProcessing) {
      state.startProcessing();
      // always check the availability of model before being used for recognition
      await _checkModel();
      state.data = await _recognition.process();
      state.stopProcessing();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('ML Digital Ink Recognition'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Builder(
              builder: (_) {
                _init();

                return GestureDetector(
                  onScaleStart: (details) async =>
                      await _actionDown(details.localFocalPoint),
                  onScaleUpdate: (details) async =>
                      await _actionMove(details.localFocalPoint),
                  onScaleEnd: (details) async => await _actionUp(),
                  child: Consumer<LearningDigitalInkRecognitionState>(
                    builder: (_, state, __) => CustomPaint(
                      painter: DigitalInkPainter(writings: state.writings),
                      child: Container(
                        width: _width,
                        height: _height,
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),
            NormalPinkButton(
              text: 'Start Recognition',
              onPressed: _startRecognition,
            ),
            SizedBox(height: 10),
            NormalBlueButton(
              text: 'Reset Canvas',
              onPressed: _reset,
            ),
            SizedBox(height: 20),
            Consumer<LearningDigitalInkRecognitionState>(
                builder: (_, state, __) {
              if (state.isNotProcessing && state.isNotEmpty) {
                return Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text(
                      state.toCompleteString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              }

              if (state.isProcessing) {
                return Center(
                  child: Container(
                    width: 36,
                    height: 36,
                    color: Colors.transparent,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return Container();
            }),
          ],
        ),
      ),
    );
  }
}

class LearningDigitalInkRecognitionState extends ChangeNotifier {
  List<List<Offset>> _writings = [];
  List<RecognitionCandidate> _data = [];
  bool isProcessing = false;

  List<List<Offset>> get writings => _writings;
  List<RecognitionCandidate> get data => _data;
  bool get isNotProcessing => !isProcessing;
  bool get isEmpty => _data.isEmpty;
  bool get isNotEmpty => _data.isNotEmpty;

  List<Offset> _writing = [];

  void reset() {
    _writings = [];
    notifyListeners();
  }

  void startWriting(Offset point) {
    _writing = [point];
    _writings.add(_writing);
    notifyListeners();
  }

  void writePoint(Offset point) {
    if (_writings.isNotEmpty) {
      _writings[_writings.length - 1].add(point);
      notifyListeners();
    }
  }

  void stopWriting() {
    _writing = [];
    notifyListeners();
  }

  void startProcessing() {
    isProcessing = true;
    notifyListeners();
  }

  void stopProcessing() {
    isProcessing = false;
    notifyListeners();
  }

  set data(List<RecognitionCandidate> data) {
    _data = data;
    notifyListeners();
  }

  @override
  String toString() {
    return isNotEmpty ? _data.first.text : '';
  }

  String toCompleteString() {
    return isNotEmpty ? _data.map((c) => c.text).toList().join(', ') : '';
  }
}

class DigitalInkPainter extends CustomPainter {
  final List<List<Offset>> writings;
  final double strokeWidth;
  final Color strokeColor;

  DigitalInkPainter({
    this.writings = const [],
    this.strokeWidth = 2.0,
    this.strokeColor = Colors.black87,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.clipRect(rect);
    canvas.drawColor(Colors.teal[100]!, BlendMode.multiply);

    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..blendMode = BlendMode.srcOver;

    for (List<Offset> points in writings) {
      _paintLine(points, canvas, paint);
    }
  }

  void _paintLine(List<Offset> points, Canvas canvas, Paint paint) {
    final start = points.first;
    final path = Path()..fillType = PathFillType.evenOdd;

    path.moveTo(start.dx, start.dy);

    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(DigitalInkPainter oldPainter) => true;
}
