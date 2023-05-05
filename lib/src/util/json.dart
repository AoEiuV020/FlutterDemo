
import 'dart:convert';

String jsonToString(dynamic obj) {
  return json.encode(obj);
}

dynamic jsonFromString(String str) {
  return json.decode(str);
}