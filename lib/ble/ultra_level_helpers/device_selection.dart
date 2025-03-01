import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the enum for device selection
enum UltraLevelDevice {
  ultraLevelPro,
  ultraLevelMax,
  smartStarter,
  ultraLevelDisplay,
}

// StateNotifier to manage selection
class DeviceSelectionNotifier extends StateNotifier<UltraLevelDevice?> {
  DeviceSelectionNotifier() : super(null); // Initially no selection

  // Method to update selection
  void selectDevice(UltraLevelDevice device) {
    state = device;
  }
}

// Riverpod provider for selection
final deviceSelectionProvider =
    StateNotifierProvider<DeviceSelectionNotifier, UltraLevelDevice?>(
      (ref) => DeviceSelectionNotifier(),
    );
