class DustbinModel {
  final String dustbinId;
  final String location;
  final double fillPercentage;
  final String wasteType; // e.g. Plastic, Organic, Paper, Glass
  final String lastCollected;
  final String status; // Normal, Alert, Overflowing, Malfunction
  final String temperature; // e.g. "34°C"
  final bool badSmellDetected;
  final bool sensorActive;
  final String battery; // e.g. "81%"

  DustbinModel({
    required this.dustbinId,
    required this.location,
    required this.fillPercentage,
    required this.wasteType,
    required this.lastCollected,
    required this.status,
    required this.temperature,
    required this.badSmellDetected,
    required this.sensorActive,
    required this.battery,
  });

  bool get isOverflowing => fillPercentage >= 85.0;
  bool get hasAlert => isOverflowing || badSmellDetected || !sensorActive;

  // Convert status color
  double get batteryLevel {
    try {
      return double.parse(battery.replaceAll('%', '')) / 100.0;
    } catch (_) {
      return 1.0;
    }
  }

  double get tempValue {
    try {
      return double.parse(temperature.replaceAll('°C', ''));
    } catch (_) {
      return 25.0;
    }
  }

  factory DustbinModel.fromJson(Map<String, dynamic> json) {
    return DustbinModel(
      dustbinId: json['dustbin_id'] as String,
      location: json['location'] as String,
      fillPercentage: (json['fill_percentage'] as num).toDouble(),
      wasteType: json['waste_type'] as String,
      lastCollected: json['last_collected'] as String,
      status: json['status'] as String,
      temperature: json['temperature'] as String,
      badSmellDetected: json['bad_smell_detected'] as bool,
      sensorActive: json['sensor_active'] as bool,
      battery: json['battery'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dustbin_id': dustbinId,
      'location': location,
      'fill_percentage': fillPercentage,
      'waste_type': wasteType,
      'last_collected': lastCollected,
      'status': status,
      'temperature': temperature,
      'bad_smell_detected': badSmellDetected,
      'sensor_active': sensorActive,
      'battery': battery,
    };
  }

  DustbinModel copyWith({
    String? dustbinId,
    String? location,
    double? fillPercentage,
    String? wasteType,
    String? lastCollected,
    String? status,
    String? temperature,
    bool? badSmellDetected,
    bool? sensorActive,
    String? battery,
  }) {
    return DustbinModel(
      dustbinId: dustbinId ?? this.dustbinId,
      location: location ?? this.location,
      fillPercentage: fillPercentage ?? this.fillPercentage,
      wasteType: wasteType ?? this.wasteType,
      lastCollected: lastCollected ?? this.lastCollected,
      status: status ?? this.status,
      temperature: temperature ?? this.temperature,
      badSmellDetected: badSmellDetected ?? this.badSmellDetected,
      sensorActive: sensorActive ?? this.sensorActive,
      battery: battery ?? this.battery,
    );
  }
}
