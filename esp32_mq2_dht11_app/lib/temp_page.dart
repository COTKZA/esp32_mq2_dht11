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
      home: tempDataDisplay(),
    );
  }
}

class tempDataDisplay extends StatefulWidget {
  @override
  _tempDataDisplayState createState() => _tempDataDisplayState();
}

class _tempDataDisplayState extends State<tempDataDisplay> {
  late SensorData latestSensorData;
  bool isLoading = true;
  late Timer timer;
  String statusMessage = ''; // Variable to hold the status message

  @override
  void initState() {
    super.initState();
    fetchLatestSensorData();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchLatestSensorData();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Future<void> fetchLatestSensorData() async {
    try {
      List<SensorData> sensorDataList = await ApiService().fetchSensorData();
      if (sensorDataList.isNotEmpty) {
        setState(() {
          latestSensorData = sensorDataList.first;
          isLoading = false;

          // Set status message based on temperature value
          if (latestSensorData.temperature < 25) {
            statusMessage = 'อุณหภูมิต่ำ';
          } else if (latestSensorData.temperature < 50) {
            statusMessage = 'อุณหภูมิปานกลาง';
          } else if (latestSensorData.temperature < 75) {
            statusMessage = 'อุณหภูมิสูง';
          } else {
            statusMessage = 'อันตราย';
          }
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching sensor data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Temperature Sensor Data Display'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 100,
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: 0, endValue: 25, color: Colors.blue),
                          GaugeRange(
                              startValue: 25,
                              endValue: 50,
                              color: Colors.green),
                          GaugeRange(
                              startValue: 50, endValue: 100, color: Colors.red),
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: latestSensorData
                                .temperature, // Display temperature
                            enableAnimation: true,
                            animationType: AnimationType.ease,
                            animationDuration: 1000,
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                '${latestSensorData.temperature}°C', // Show temperature in degrees Celsius
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                            angle: 90,
                            positionFactor: 0.5,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Add space
                  Text(
                    statusMessage, // Display status message
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
