import 'package:flutter_test/flutter_test.dart';
import 'package:ecotrack/models/dustbin_model.dart';
import 'package:ecotrack/services/dustbin_service.dart';

void main() {
  group('DustbinModel Tests', () {
    test('Correctly computes overflow state', () {
      final model = DustbinModel(
        dustbinId: 'GT-001',
        location: 'Admin Building',
        fillPercentage: 85.0,
        battery: '82%',
        temperature: '28°C',
        status: 'Normal',
        wasteType: 'Plastic',
        lastCollected: 'Never',
        sensorActive: true,
        badSmellDetected: false,
      );

      expect(model.isOverflowing, true);
    });

    test('Correctly parses temperature and battery levels', () {
      final model = DustbinModel(
        dustbinId: 'GT-001',
        location: 'Admin Building',
        fillPercentage: 45.0,
        battery: '15%',
        temperature: '42.5°C',
        status: 'Odor Detected',
        wasteType: 'Organic',
        lastCollected: 'Never',
        sensorActive: true,
        badSmellDetected: true,
      );

      expect(model.tempValue, 42.5);
      expect(model.batteryLevel, 0.15);
      expect(model.badSmellDetected, true);
    });
  });

  group('DustbinService Simulation Tests', () {
    late DustbinService service;

    setUp(() {
      service = DustbinService();
    });

    tearDown(() {
      service.dispose();
    });

    test('Generates 25 dustbins initially', () {
      final bins = service.currentDustbins;
      expect(bins.length, 25);
    });

    test('collectWaste clears the fill percentage and resets status', () {
      final binId = service.currentDustbins.first.dustbinId;
      
      // Simulate collection
      service.collectWaste(binId);

      final updatedBin = service.currentDustbins.firstWhere((b) => b.dustbinId == binId);
      expect(updatedBin.fillPercentage, 0.0);
      expect(updatedBin.status, 'Normal');
      expect(updatedBin.badSmellDetected, false);
    });

    test('rebootSensor restores sensor online status and charge', () {
      final binId = service.currentDustbins.first.dustbinId;

      service.rebootSensor(binId);

      final updatedBin = service.currentDustbins.firstWhere((b) => b.dustbinId == binId);
      expect(updatedBin.sensorActive, true);
      expect(updatedBin.battery, '100%');
    });
  });
}
