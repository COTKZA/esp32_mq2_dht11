import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sensor_data.dart';

class ApiService {
  final String apiUrl =
      'http://127.0.0.1/esp32_mq2_dht11/api/api_esp32_data.php'; // Replace with your API endpoint

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
