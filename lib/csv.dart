import 'package:csv/csv.dart';

List<Map<String, dynamic>> csvToMap(String input) {
  List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter(eol: '\n').convert(input);
  List<Map<String, dynamic>> ret = [];
  if (rowsAsListOfValues.isEmpty) return List.empty();
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
  return ret;
}
