int calculateCRC(List<int> data) {
  int crc = 0xFFFF; // Initialize CRC to 0xFFFF

  for (int byte in data) {
    crc ^= byte;
    for (int i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xA001;
      } else {
        crc >>= 1;
      }
    }
  }

  // The result is a 16-bit integer
  return crc & 0xFFFF;
}

List<int> hexStringToHexArray(String hexString) {
  List<int> hexArray = [];
  for (int i = 0; i < hexString.length - 1; i += 2) {
    String hexByte = hexString.substring(i, i + 2);
    int intValue = int.parse(hexByte, radix: 16);
    hexArray.add(intValue);
  }
  return hexArray;
}

String calculateModbusCRC(String hexString) {
  final data = hexStringToHexArray(hexString);
  int crcResult = calculateCRC(data);

  // Convert the result to a hexadecimal string
  String crcHex = crcResult.toRadixString(16).toUpperCase().padLeft(4, '0');
  String firstByte = crcHex.substring(0, 2);
  String secondByte = crcHex.substring(2, 4);
  crcHex = secondByte + firstByte;
  return crcHex;
}

int hexToInt(String hex) {
  return int.parse(hex, radix: 16);
}

String intToHex(int value) {
  final res = value.toRadixString(16).toUpperCase();
  return res.padLeft(4, '0');
}
