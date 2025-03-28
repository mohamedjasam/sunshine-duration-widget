import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
    static Future<Map<String, dynamic>> fetchSunshineData() async {
        // Replace with your Django API endpoint
        final response = await http.get(Uri.parse('http://192.168.1.5:8000/api/sunshine/'));
        if (response.statusCode == 200) {
            return json.decode(response.body);
        } else {
            throw Exception('Failed to load data');
        }
    }
}