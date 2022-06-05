import 'dart:typed_data';

String testData() {
  var sb = StringBuffer();
  Map<String, Endian?> endianMap = {
    "null": null,
    "big": Endian.big,
    "little": Endian.little,
    "host": Endian.host,
  };
  var number = 0x12345678;
  endianMap.forEach((endianName, endian) {
    var byteArray = Uint8List(4);
    var byteData = byteArray.buffer.asByteData();
    if (endian != null) {
      byteData.setInt32(0, number, endian);
    } else {
      byteData.setInt32(0, number);
    }
    var result =
        byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join();
    sb.writeln("0x${number.toRadixString(16)} Endian.$endianName");
    sb.writeln(" -> $result");
  });
  return sb.toString();
}
