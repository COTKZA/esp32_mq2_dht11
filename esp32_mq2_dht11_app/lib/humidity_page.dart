// main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'api.dart';
import 'sensor_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HumidityDataDisplay(), // Updated class name for clarity
    );
  }
}

class HumidityDataDisplay extends StatefulWidget {
  @override
  _HumidityDataDisplayState createState() => _HumidityDataDisplayState();
}

class _HumidityDataDisplayState extends State<HumidityDataDisplay> {
  late SensorData latestSensorData;
  bool isLoading = true;
  late Timer timer;
  String statusMessage = ''; // Variable to hold status message

  @override
  void initState() {
    super.initState();
    fetchLatestSensorData(); // Initial data fetch
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchLatestSensorData(); // Periodic data fetch
    });
  }

  @override
  void dispose() {
    timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  Future<void> fetchLatestSensorData() async {
    try {
      List<SensorData> sensorDataList = await ApiService().fetchSensorData();
      if (sensorDataList.isNotEmpty) {
        setState(() {
          latestSensorData = sensorDataList.first;
          isLoading = false;
          statusMessage = _getHumidityStatus(latestSensorData.humidity);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Update loading state in case of error
      });
      print('Error fetching sensor data: $error');
    }
  }

  String _getHumidityStatus(double humidity) {
    // Helper method to determine humidity status message
    if (humidity < 30) {
      return 'ความชื้นน้อย';
    } else if (humidity < 60) {
      return 'ความชื้นปานกลาง';
    } else {
      return 'ความชื้นสูง';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Humidity Sensor Data Display'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : _buildHumidityDisplay(), // Separate method for display
      ),
    );
  }

  Widget _buildHumidityDisplay() {
    // Method to build the humidity display widget
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 30, color: Colors.blue),
                GaugeRange(startValue: 30, endValue: 60, color: Colors.green),
                GaugeRange(startValue: 60, endValue: 100, color: Colors.red),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: latestSensorData.humidity,
                  enableAnimation: true,
                  animationType: AnimationType.ease,
                  animationDuration: 1000,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      '${latestSensorData.humidity}% RH', // Show humidity percentage
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.5,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20), // Add space between elements
        Text(
          statusMessage, // Display status message
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
