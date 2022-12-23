import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

Future<String> fetchUrl(String url) async {
  var dio = Dio();
  var cookieJar = CookieJar();
  var cookieManager = CookieManager(cookieJar);
  cookieJar.saveFromResponse(Uri.parse(url), [Cookie("k", "v")]);
  dio.interceptors.add(cookieManager);

  var response = await dio.get(url);
  return response.data.toString();
}
