import 'package:http/http.dart' as http;

Future<String> fetchUrl(http.Client client, String url) async {
  final response = await client
      .get(Uri.parse(url));

  if (response.statusCode == 200) {
    var sb = StringBuffer();
    if (response.request != null) {
      sb.writeAll(map(response.request!.headers));
    }
    // web端无法得到"set-cookie",
    sb.writeAll(map(response.headers));
    sb.write(response.body);
    return sb.toString();
  } else {
    throw Exception('Failed to load content');
  }
}

List<String> map(Map<String, String> headers)  {
  var ret = headers.entries
      .map((e) => "<-- ${e.key}: ${e.value}\n")
      .toList();
  ret.sort();
  return ret;
}
