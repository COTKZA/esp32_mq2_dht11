import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SensorDataDisplay(),
    );
  }
}

class SensorData {
  final String id;
  final DateTime date;
  final String time;
  final double temperature;
  final double humidity;
  final String gas;

  SensorData({
    required this.id,
    required this.date,
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.gas,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      temperature: double.parse(json['temperature']),
      humidity: double.parse(json['humidity']),
      gas: json['gas'] ?? 'Unknown',
    );
  }
}

class ApiService {
  final String apiUrl =
      'http://127.0.0.1/esp32_mq2_dht11/api/api_esp32_data.php';

  Future<List<SensorData>> fetchSensorData() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorData.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class SensorDataDisplay extends StatefulWidget {
  @override
  _SensorDataDisplayState createState() => _SensorDataDisplayState();
}

class _SensorDataDisplayState extends State<SensorDataDisplay> {
  late SensorData latestSensorData;
  bool isLoading = true;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    fetchLatestSensorData();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
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
        title: Text('Sensor Data Display'),
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
                        minimum: -20,
                        maximum: 50,
                        ranges: <GaugeRange>[
                          GaugeRange(
                              startValue: -20, endValue: 0, color: Colors.blue),
                          GaugeRange(
                              startValue: 0, endValue: 30, color: Colors.green),
                          GaugeRange(
                              startValue: 30, endValue: 50, color: Colors.red),
                        ],
                        pointers: <GaugePointer>[
                          NeedlePointer(
                            value: latestSensorData.temperature,
                            enableAnimation: true, // เปิดใช้งาน animation
                            animationType: AnimationType.ease,
                            animationDuration:
                                1000, // ระยะเวลา animation (มิลลิวินาที)
                          ),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Container(
                              child: Text(
                                '${latestSensorData.temperature}°C',
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
                ],
              ),
      ),
    );
  }
}
