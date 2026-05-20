import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/dustbin_model.dart';

class DustbinService {
  final List<DustbinModel> _dustbins = [];
  final _controller = StreamController<List<DustbinModel>>.broadcast();
  Timer? _simulationTimer;
  final _random = Random();

  Stream<List<DustbinModel>> get dustbinsStream => _controller.stream;
  List<DustbinModel> get currentDustbins => List.unmodifiable(_dustbins);

  DustbinService() {
    _initializeDustbins();
    _startSimulation();
  }

  void dispose() {
    _simulationTimer?.cancel();
    _controller.close();
  }

  // Set up the initial 25 dustbins from PRD
  void _initializeDustbins() {
    final List<Map<String, String>> initialLocations = [
      {'id': 'GT-001', 'loc': 'ICT Building Floor 1', 'type': 'Plastic'},
      {'id': 'GT-002', 'loc': 'ICT Building Floor 2', 'type': 'Paper'},
      {'id': 'GT-003', 'loc': 'ICT Building Floor 3', 'type': 'Glass'},
      {'id': 'GT-004', 'loc': 'Mechanical Workshop', 'type': 'Metal'},
      {'id': 'GT-005', 'loc': 'Civil Department', 'type': 'Paper'},
      {'id': 'GT-006', 'loc': 'Library Entrance', 'type': 'Organic'},
      {'id': 'GT-007', 'loc': 'Boys Hostel', 'type': 'Organic'},
      {'id': 'GT-008', 'loc': 'Girls Hostel', 'type': 'Organic'},
      {'id': 'GT-009', 'loc': 'Main Gate', 'type': 'Plastic'},
      {'id': 'GT-010', 'loc': 'College Canteen', 'type': 'Organic'},
      {'id': 'GT-011', 'loc': 'Basketball Court', 'type': 'Plastic'},
      {'id': 'GT-012', 'loc': 'Parking Area', 'type': 'Metal'},
      {'id': 'GT-013', 'loc': 'Auditorium', 'type': 'Paper'},
      {'id': 'GT-014', 'loc': 'Computer Lab', 'type': 'Plastic'},
      {'id': 'GT-015', 'loc': 'Electrical Lab', 'type': 'Plastic'},
      {'id': 'GT-016', 'loc': 'Chemistry Lab', 'type': 'Chemical'},
      {'id': 'GT-017', 'loc': 'Garden Area', 'type': 'Organic'},
      {'id': 'GT-018', 'loc': 'Administrative Block', 'type': 'Paper'},
      {'id': 'GT-019', 'loc': 'Cafeteria Zone', 'type': 'Organic'},
      {'id': 'GT-020', 'loc': 'Bus Stand', 'type': 'Plastic'},
      {'id': 'GT-021', 'loc': 'Seminar Hall', 'type': 'Paper'},
      {'id': 'GT-022', 'loc': 'Playground', 'type': 'Plastic'},
      {'id': 'GT-023', 'loc': 'Staff Room Area', 'type': 'Paper'},
      {'id': 'GT-024', 'loc': 'Student Activity Center', 'type': 'Plastic'},
      {'id': 'GT-025', 'loc': 'Medical Room', 'type': 'Clinical'},
    ];

    final now = DateTime.now().subtract(const Duration(hours: 3));
    final format = DateFormat('yyyy-MM-dd hh:mm a');

    for (var loc in initialLocations) {
      // Generate some realistic initial fill levels (mix of low and high)
      double initialFill = 20.0 + _random.nextDouble() * 60.0;
      int batteryPercent = 70 + _random.nextInt(30);
      int temp = 28 + _random.nextInt(10);
      bool isHigh = initialFill >= 85.0;

      _dustbins.add(
        DustbinModel(
          dustbinId: loc['id']!,
          location: loc['loc']!,
          fillPercentage: double.parse(initialFill.toStringAsFixed(1)),
          wasteType: loc['type']!,
          lastCollected: format.format(now),
          status: isHigh ? 'Overflowing' : 'Normal',
          temperature: '${temp}°C',
          badSmellDetected: isHigh || _random.nextBool() && initialFill > 70.0,
          sensorActive: true,
          battery: '${batteryPercent}%',
        ),
      );
    }
    _controller.add(List.from(_dustbins));
  }

  // Periodically increment random dustbin fills to simulate living data
  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_dustbins.isEmpty) return;

      // Select 1 to 3 random dustbins to fill
      final numBinsToUpdate = _random.nextInt(3) + 1;
      for (int i = 0; i < numBinsToUpdate; i++) {
        final index = _random.nextInt(_dustbins.length);
        final bin = _dustbins[index];

        if (!bin.sensorActive) continue; // offline sensors don't update

        double fillAdd = 3.0 + _random.nextDouble() * 8.0;
        double newFill = min(100.0, bin.fillPercentage + fillAdd);
        newFill = double.parse(newFill.toStringAsFixed(1));

        // Battery drain
        int batteryVal = int.parse(bin.battery.replaceAll('%', ''));
        if (_random.nextDouble() > 0.7) {
          batteryVal = max(0, batteryVal - 1);
        }

        // Temperature variations
        int tempVal = int.parse(bin.temperature.replaceAll('°C', ''));
        if (_random.nextBool()) {
          tempVal = max(25, min(45, tempVal + (_random.nextBool() ? 1 : -1)));
        }

        // Handle smell and status updates
        bool smell = bin.badSmellDetected;
        if (newFill >= 75.0 && _random.nextDouble() > 0.4) {
          smell = true;
        }

        String newStatus = 'Normal';
        if (newFill >= 90.0) {
          newStatus = 'Overflowing';
        } else if (newFill >= 80.0) {
          newStatus = 'Alert';
        } else if (smell) {
          newStatus = 'Smell Alert';
        }

        bool active = bin.sensorActive;
        if (batteryVal == 0) {
          active = false;
          newStatus = 'Malfunction';
        }

        _dustbins[index] = bin.copyWith(
          fillPercentage: newFill,
          battery: '${batteryVal}%',
          temperature: '${tempVal}°C',
          badSmellDetected: smell,
          status: newStatus,
          sensorActive: active,
        );
      }
      
      _controller.add(List.from(_dustbins));
    });
  }

  // Reset a dustbin (simulate garbage collection pickup)
  void collectWaste(String id) {
    final index = _dustbins.indexWhere((b) => b.dustbinId == id);
    if (index != -1) {
      final bin = _dustbins[index];
      final now = DateTime.now();
      final format = DateFormat('yyyy-MM-dd hh:mm a');

      _dustbins[index] = DustbinModel(
        dustbinId: bin.dustbinId,
        location: bin.location,
        fillPercentage: 0.0,
        wasteType: bin.wasteType,
        lastCollected: format.format(now),
        status: 'Normal',
        temperature: '26°C',
        badSmellDetected: false,
        sensorActive: true,
        battery: '100%',
      );
      _controller.add(List.from(_dustbins));
    }
  }

  // Reboot sensor to fix malfunctions
  void rebootSensor(String id) {
    final index = _dustbins.indexWhere((b) => b.dustbinId == id);
    if (index != -1) {
      final bin = _dustbins[index];
      _dustbins[index] = bin.copyWith(
        sensorActive: true,
        battery: '100%',
        status: bin.fillPercentage >= 90.0 ? 'Overflowing' : 'Normal',
      );
      _controller.add(List.from(_dustbins));
    }
  }
}
