import 'package:dio/dio.dart';

Future<String> fetchUrl(String url) async {
  var response = await Dio().get(url);
  return response.data.toString();
}
