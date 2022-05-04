import 'package:http/http.dart' as http;

Future<String> fetchUrl(http.Client client, String url) async {
  final response = await client
      .get(Uri.parse(url));

  if (response.statusCode == 200) {
    return response.body;
  } else {
    throw Exception('Failed to load content');
  }
}
