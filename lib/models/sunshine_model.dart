class SunshineData {
    final DateTime date;
    final double totalHours;
    final List<Map<String, dynamic>> hourlyData;

    SunshineData({
        required this.date,
        required this.totalHours,
        required this.hourlyData,
    });

    factory SunshineData.fromJson(Map<String, dynamic> json) {
        return SunshineData(
            date: DateTime.parse(json['date']),
            totalHours: json['total_hours'].toDouble(),
            hourlyData: List<Map<String, dynamic>>.from(json['hourly_data']),
        );
    }
}