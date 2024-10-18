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
      title: 'Gauge Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GasPage(),
    );
  }
}

class GasPage extends StatefulWidget {
  @override
  _GasPageState createState() => _GasPageState();
}

class _GasPageState extends State<GasPage> {
  double _currentGasValue = 50; // Initial value for gas
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLatestGasValue(); // Fetch initial gas value
    // Fetch gas data every second
    _timer = Timer.periodic(
      Duration(seconds: 1),
      (Timer t) => fetchLatestGasValue(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Fetch latest gas value from API
  Future<void> fetchLatestGasValue() async {
    try {
      List<SensorData> sensorDataList = await ApiService().fetchSensorData();
      if (sensorDataList.isNotEmpty) {
        // Convert gas value from String to double
        double latestGasValue =
            double.tryParse(sensorDataList.first.gas) ?? 0.0;
        // Ensure the value does not exceed 100
        if (latestGasValue > 100) {
          latestGasValue = 100;
        }
        // Check if the new value is different before updating
        if (latestGasValue != _currentGasValue) {
          setState(() {
            _currentGasValue = latestGasValue; // Update the current gas value
          });
        }
      }
    } catch (e) {
      print('Error fetching gas data: $e');
    }
  }

  String _getLabel(double value) {
    if (value <= 25) {
      return 'แก๊สน้อย';
    } else if (value <= 50) {
      return 'ปานกลาง';
    } else if (value <= 75) {
      return 'ค่อนข้างมาก';
    } else {
      return 'อันตราย';
    }
  }

  Color _getColor(double value) {
    if (value <= 25) {
      return Colors.green;
    } else if (value <= 50) {
      return Colors.yellow;
    } else if (value <= 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-time Gas Gauge'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gas Value: ${_currentGasValue.toInt()} (${_getLabel(_currentGasValue)})',
              style: TextStyle(fontSize: 24),
            ),
            Slider(
              value: _currentGasValue,
              min: 0, // Changed to 0 for better representation
              max: 100, // Ensure the maximum is 100
              divisions: 100, // Divisions for better granularity
              label: _currentGasValue.toStringAsFixed(0),
              onChanged: (double value) {
                setState(() {
                  _currentGasValue = value.clamp(
                      0, 100); // Ensure value is clamped between 0 and 100
                });
              },
            ),
            SizedBox(height: 20),
            CustomPaint(
              size: Size(200, 200),
              painter:
                  GaugePainter(_currentGasValue, _getColor(_currentGasValue)),
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
