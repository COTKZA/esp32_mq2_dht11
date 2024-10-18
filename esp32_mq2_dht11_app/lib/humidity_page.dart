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
      title: 'Humidity Gauge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HumidityPage(), // Change to HumidityPage
    );
  }
}

class HumidityPage extends StatefulWidget {
  // Change to HumidityPage
  @override
  _HumidityPageState createState() =>
      _HumidityPageState(); // Change to _HumidityPageState
}

class _HumidityPageState extends State<HumidityPage> {
  // Change to _HumidityPageState
  double _currentHumidityValue = 50; // Initial value for humidity
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLatestHumidityValue(); // Fetch initial humidity value
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => fetchLatestHumidityValue(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> fetchLatestHumidityValue() async {
    try {
      List<SensorData> sensorDataList = await ApiService().fetchSensorData();
      if (sensorDataList.isNotEmpty) {
        double latestHumidityValue = sensorDataList
            .first.humidity; // Get humidity instead of temperature
        if (latestHumidityValue != _currentHumidityValue) {
          setState(() {
            _currentHumidityValue =
                latestHumidityValue; // Update current humidity value
          });
        }
      }
    } catch (e) {
      print('Error fetching humidity data: $e'); // Updated message for humidity
    }
  }

  String _getLabel(double value) {
    if (value <= 30) {
      return 'แห้ง'; // Dry
    } else if (value <= 60) {
      return 'ปกติ'; // Normal
    } else if (value <= 80) {
      return 'ชื้น'; // Humid
    } else {
      return 'อันตราย'; // Danger
    }
  }

  Color _getColor(double value) {
    if (value <= 30) {
      return Colors.blue; // Blue for dry
    } else if (value <= 60) {
      return Colors.green; // Green for normal
    } else if (value <= 80) {
      return Colors.orange; // Orange for humid
    } else {
      return Colors.red; // Red for danger
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Humidity'), // Updated title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Humidity Value: ${_currentHumidityValue.toInt()}% (${_getLabel(_currentHumidityValue)})', // Updated text
              style: TextStyle(fontSize: 24),
            ),
            Slider(
              value: _currentHumidityValue,
              min: 0,
              max: 100,
              divisions: 100,
              label: _currentHumidityValue.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _currentHumidityValue = value.clamp(
                      0, 100); // Ensure value is clamped between 0 and 100
                });
              },
            ),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(200, 200),
              painter: GaugePainter(_currentHumidityValue,
                  _getColor(_currentHumidityValue)), // Update for humidity
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
