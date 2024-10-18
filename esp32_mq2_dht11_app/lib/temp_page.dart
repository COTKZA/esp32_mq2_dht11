import 'dart:async'; // Import for Timer
import 'package:flutter/material.dart';
import 'api.dart'; // Import your API service
import 'sensor_data.dart'; // Import your sensor data model

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Gauge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TempPage(),
    );
  }
}

class TempPage extends StatefulWidget {
  @override
  _TempPageState createState() => _TempPageState();
}

class _TempPageState extends State<TempPage> {
  double _currentTempValue = 25; // Initial value for temperature
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLatestTempValue(); // Fetch initial temperature value
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => fetchLatestTempValue(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchLatestTempValue() async {
    try {
      List<SensorData> sensorDataList = await ApiService().fetchSensorData();
      if (sensorDataList.isNotEmpty) {
        double latestTempValue = sensorDataList.first.temperature;
        if (latestTempValue != _currentTempValue) {
          setState(() {
            _currentTempValue = latestTempValue;
          });
        }
      }
    } catch (e) {
      print('Error fetching temperature data: $e');
    }
  }

  String _getLabel(double value) {
    if (value <= 10) {
      return 'เย็น'; // Cold
    } else if (value <= 25) {
      return 'อบอุ่น'; // Warm
    } else if (value <= 35) {
      return 'ร้อน'; // Hot
    } else {
      return 'อันตราย'; // Danger
    }
  }

  Color _getColor(double value) {
    if (value <= 10) {
      return Colors.blue; // Blue for cold
    } else if (value <= 25) {
      return Colors.green; // Green for warm
    } else if (value <= 35) {
      return Colors.orange; // Orange for hot
    } else {
      return Colors.red; // Red for danger
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Temperature'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Temperature Value: ${_currentTempValue.toInt()} °C (${_getLabel(_currentTempValue)})',
              style: TextStyle(fontSize: 24),
            ),
            Slider(
              value: _currentTempValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: _currentTempValue.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _currentTempValue = value.clamp(0, 100);
                });
              },
            ),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(200, 200),
              painter:
                  GaugePainter(_currentTempValue, _getColor(_currentTempValue)),
            ),
          ],
        ),
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  GaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2;

    Paint outerCircle = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    Paint valueArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(centerX, centerY), radius, outerCircle);

    double angle = (value / 100) *
        3.6 *
        (3.1416 / 180); // Calculate the angle for the gauge

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
      -3.1416 / 2, // Start at the top of the circle
      angle,
      false,
      valueArc,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
