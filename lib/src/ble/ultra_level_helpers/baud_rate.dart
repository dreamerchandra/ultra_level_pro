int getBaudRate(String hex) {
  int baudRate = 0;
  final binary =
      int.parse(hex, radix: 16).toRadixString(2).split('').reversed.join();
  try {
    if (binary[0] == '1') baudRate = 1200;
    if (binary[1] == '1') baudRate = 2400;
    if (binary[2] == '1') baudRate = 4800;
    if (binary[3] == '1') baudRate = 9600;
    if (binary[4] == '1') baudRate = 19200;
    if (binary[5] == '1') baudRate = 57600;
    if (binary[6] == '1') baudRate = 115200;
    return baudRate;
  } catch (e) {
    return baudRate;
  }
}

String getBitByBaudRate(int baudRate) {
  String getBitRateInBinary() {
    if (baudRate == 1200) return '00001';
    if (baudRate == 2400) return '00010';
    if (baudRate == 4800) return '00100';
    if (baudRate == 9600) return '01000';
    if (baudRate == 19200) return '10000';
    if (baudRate == 57600) return '00000';
    if (baudRate == 115200) return '00000';
    return '00000';
  }

  return int.parse(getBitRateInBinary(), radix: 2).toRadixString(16);
}
