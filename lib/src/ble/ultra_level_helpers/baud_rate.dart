int getBaudRate(String hex) {
  switch (hex) {
    case '01':
      return 1200;
    case '02':
      return 2400;
    case '04':
      return 4800;
    case '08':
      return 9600;
    case '0A':
      return 19200;
    case '0B':
      return 57600;
    case '0C':
      return 115200;
    default:
      return 9600;

    // throw Exception('Invalid baud rate');
  }
}
