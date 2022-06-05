import 'dart:typed_data';

import 'package:test/test.dart';

void main() {
  test('bigEndian', () {
    var input = <int>[0x12345678, 0x01, 0x02];
    var byteArray = Uint8List(input.length * 4);
    var byteData = byteArray.buffer.asByteData();

    // 默认就是大端，
    input.asMap().forEach((i, e) {
      byteData.setInt32(i * 4, input[i]);
    });
    expect(byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join(),
        "000100100011010001010110011110000000000000000000000000000000000100000000000000000000000000000010");

    input.asMap().forEach((i, e) {
      byteData.setInt32(i * 4, input[i], Endian.big);
    });
    expect(byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join(),
        "000100100011010001010110011110000000000000000000000000000000000100000000000000000000000000000010");

    input.asMap().forEach((i, e) {
      byteData.setInt32(i * 4, input[i], Endian.little);
    });
    expect(byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join(),
        "011110000101011000110100000100100000000100000000000000000000000000000010000000000000000000000000");

    // host就是直接长整数转成数组时的字节序，是小端，
    input.asMap().forEach((i, e) {
      byteData.setInt32(i * 4, input[i], Endian.host);
    });
    expect(byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join(),
        "011110000101011000110100000100100000000100000000000000000000000000000010000000000000000000000000");
  });
  test('listToBinaryString', () {
    var data = <int>[0x12345678, 0x01, 0x02];
    var byteArray = Uint8List(data.length * 4)
      ..buffer.asInt32List().setAll(0, data);
    expect(byteArray.map((e) => e.toRadixString(2).padLeft(8, "0")).join(),
        "011110000101011000110100000100100000000100000000000000000000000000000010000000000000000000000000");
  });
  test('padding', () {
    expect(0x01020304.toRadixString(2).padLeft(4 * 8, "0"),
        "00000001000000100000001100000100");
  });
  test('toRadixString', () {
    expect(0x01020304.toRadixString(2), "1000000100000001100000100");
  });
}
