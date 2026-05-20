import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dustbin_model.dart';
import '../services/dustbin_service.dart';

// Service provider
final dustbinServiceProvider = Provider<DustbinService>((ref) {
  final service = DustbinService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Stream provider for the list of dustbins
final dustbinsStreamProvider = StreamProvider<List<DustbinModel>>((ref) {
  final service = ref.watch(dustbinServiceProvider);
  return service.dustbinsStream;
});

// Helper provider for instant snapshots
final dustbinsProvider = Provider<List<DustbinModel>>((ref) {
  final service = ref.watch(dustbinServiceProvider);
  // AsyncValue loading fallback
  final asyncValue = ref.watch(dustbinsStreamProvider);
  return asyncValue.value ?? service.currentDustbins;
});

// Computed Metrics providers for Admin Dashboard Cards
final totalBinsProvider = Provider<int>((ref) {
  return ref.watch(dustbinsProvider).length;
});

final fullBinsProvider = Provider<int>((ref) {
  final bins = ref.watch(dustbinsProvider);
  return bins.where((b) => b.fillPercentage >= 80.0).length;
});

final overloadedBinsProvider = Provider<int>((ref) {
  final bins = ref.watch(dustbinsProvider);
  return bins.where((b) => b.isOverflowing).length;
});

final smellAlertsProvider = Provider<int>((ref) {
  final bins = ref.watch(dustbinsProvider);
  return bins.where((b) => b.badSmellDetected).length;
});

final activeWorkersCountProvider = Provider<int>((ref) {
  // Static placeholder for phase 2, returns 6 active workers
  return 6;
});

class WasteCollectedNotifier extends Notifier<int> {
  @override
  int build() => 420;

  void increment(int amount) {
    state += amount;
  }
}

final wasteCollectedCountProvider = NotifierProvider<WasteCollectedNotifier, int>(() {
  return WasteCollectedNotifier();
});
