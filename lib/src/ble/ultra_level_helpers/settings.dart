enum SettingsValueToChange {
  isInMM,
  isTemperatureSensorEnabled,
  dac,
  switchHighLowLevel,
  rs465,
}

class Settings {
  final bool isInMM;
  final bool isTemperatureSensorEnabled;
  final bool dac;
  final bool switchHighLowLevel;
  final bool rs465;

  Settings({
    required this.isInMM,
    required this.isTemperatureSensorEnabled,
    required this.dac,
    required this.switchHighLowLevel,
    required this.rs465,
  });

  static Settings getSettings(String hex) {
    final binary =
        int.parse(hex, radix: 16).toRadixString(2).split('').reversed.join();
    try {
      return Settings(
        isInMM: binary[0] == '1',
        isTemperatureSensorEnabled: binary[1] == '1',
        dac: binary[2] == '1',
        switchHighLowLevel: binary[3] == '1',
        rs465: binary[4] == '1',
      );
    } catch (e) {
      return Settings(
        isInMM: false,
        isTemperatureSensorEnabled: false,
        dac: false,
        switchHighLowLevel: false,
        rs465: false,
      );
    }
  }

  static String settingsToBinaryString(Settings settings) {
    final binary = [
      settings.isInMM ? '1' : '0',
      settings.isTemperatureSensorEnabled ? '1' : '0',
      settings.dac ? '1' : '0',
      settings.switchHighLowLevel ? '1' : '0',
      settings.rs465 ? '1' : '0',
    ].reversed.join();
    return binary;
  }

  static String settingsToHexString(Settings settings) {
    final binary = settingsToBinaryString(settings);
    final hex = int.parse(binary, radix: 2).toRadixString(16);
    return hex;
  }

  static updateNewSettings(
      Settings oldSettings, SettingsValueToChange valueToChange) {
    switch (valueToChange) {
      case SettingsValueToChange.isInMM:
        return Settings(
          isInMM: !oldSettings.isInMM,
          isTemperatureSensorEnabled: oldSettings.isTemperatureSensorEnabled,
          dac: oldSettings.dac,
          switchHighLowLevel: oldSettings.switchHighLowLevel,
          rs465: oldSettings.rs465,
        );
      case SettingsValueToChange.isTemperatureSensorEnabled:
        return Settings(
          isInMM: oldSettings.isInMM,
          isTemperatureSensorEnabled: !oldSettings.isTemperatureSensorEnabled,
          dac: oldSettings.dac,
          switchHighLowLevel: oldSettings.switchHighLowLevel,
          rs465: oldSettings.rs465,
        );
      case SettingsValueToChange.dac:
        return Settings(
          isInMM: oldSettings.isInMM,
          isTemperatureSensorEnabled: oldSettings.isTemperatureSensorEnabled,
          dac: !oldSettings.dac,
          switchHighLowLevel: oldSettings.switchHighLowLevel,
          rs465: oldSettings.rs465,
        );
      case SettingsValueToChange.switchHighLowLevel:
        return Settings(
          isInMM: oldSettings.isInMM,
          isTemperatureSensorEnabled: oldSettings.isTemperatureSensorEnabled,
          dac: oldSettings.dac,
          switchHighLowLevel: !oldSettings.switchHighLowLevel,
          rs465: oldSettings.rs465,
        );
      case SettingsValueToChange.rs465:
        return Settings(
          isInMM: oldSettings.isInMM,
          isTemperatureSensorEnabled: oldSettings.isTemperatureSensorEnabled,
          dac: oldSettings.dac,
          switchHighLowLevel: oldSettings.switchHighLowLevel,
          rs465: !oldSettings.rs465,
        );
    }
  }
}
