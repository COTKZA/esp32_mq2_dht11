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
      home: GasDataDisplay(), // Updated class name for clarity
    );
  }
}

class GasDataDisplay extends StatefulWidget {
  @override
  _GasDataDisplayState createState() => _GasDataDisplayState();
}

class _GasDataDisplayState extends State<GasDataDisplay> {
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

          // Set status message based on gas level
          statusMessage = _getGasStatus(latestSensorData.gas);
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Update loading state in case of error
      });
      print('Error fetching sensor data: $error');
    }
  }

  String _getGasStatus(double gas) {
    // Helper method to determine gas status message
    if (gas < 25) {
      return 'แก๊สน้อย'; // Low gas
    } else if (gas < 50) {
      return 'ปานกลาง'; // Medium gas
    } else if (gas < 80) {
      return 'ปานกลางค่อนข้างมาก'; // High gas
    } else {
      return 'อันตราย'; // Dangerous gas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GAS Sensor Data Display'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : _buildGasDisplay(), // Call method to build gas display
      ),
    );
  }

  Widget _buildGasDisplay() {
    // Method to build the gas display widget
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: 0,
              maximum: 100,
              ranges: <GaugeRange>[
                GaugeRange(startValue: 0, endValue: 25, color: Colors.blue),
                GaugeRange(startValue: 25, endValue: 50, color: Colors.green),
                GaugeRange(startValue: 50, endValue: 100, color: Colors.red),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: latestSensorData.gas, // Directly use gas value
                  enableAnimation: true,
                  animationType: AnimationType.ease,
                  animationDuration: 1000,
                ),
              ],
              annotations: <GaugeAnnotation>[
                GaugeAnnotation(
                  widget: Container(
                    child: Text(
                      latestSensorData.gas
                          .toString(), // Show gas level as string
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
