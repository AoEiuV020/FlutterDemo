import 'dart:convert';

import 'package:csv/csv.dart';

String csvToJson(String input) {
  List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter(eol: '\n').convert(input);
  List<Map<String, dynamic>> ret = [];
  if (rowsAsListOfValues.isEmpty) return "[]";
  var nameList = rowsAsListOfValues[0];
  for (int i = 1; i < rowsAsListOfValues.length; i++) {
    var row = rowsAsListOfValues[i];
    Map<String, dynamic> item = {};
    for (int j = 0; j < row.length; j++) {
      var key = nameList[j];
      var value = row[j];
      item[key] = value;
    }
    ret.add(item);
  }
  return const JsonEncoder.withIndent('  ').convert(ret);
}

String jsonToCsv(String input) {
  List<dynamic> list0 = json.decode(input);
  var list = list0.map((e) => e as Map<String, dynamic>).toList();
  if(list.isEmpty) return "";
  var nameList = list[0].keys.toList();
  var values = list.map((e) => e.values.toList()).toList();
  values.insert(0, nameList);
  var ret = const ListToCsvConverter().convert(values);
  return ret;
}