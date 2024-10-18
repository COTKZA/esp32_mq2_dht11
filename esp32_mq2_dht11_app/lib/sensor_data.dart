class SensorData {
  final String id;
  final DateTime date;
  final String time;
  final double temperature;
  final double humidity;
  final double gas;
  //final String gas;

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
       gas: double.parse(json['gas'].toString()), // Parse gas as double
     // gas: json['gas'] ?? 'Unknown', // ตรวจสอบว่ามีค่า gas หรือไม่
    );
  }
}
