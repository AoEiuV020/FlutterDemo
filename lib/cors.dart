import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

/// web端会有跨域（CORS）问题，浏览器规范限制，不是代码能解决的，
/// chrome可以添加启动参数（--disable-web-security）关闭这个限制，
/// https://stackoverflow.com/a/66879350
/// 也可以通过安装拓展解决，
/// https://chrome.google.com/webstore/detail/allow-cors-access-control/lhobafahddgcelffkeicbaginigeejlf/related?hl=en-US
/// 安卓chrome也可以通过adb权限设置这个参数，
/// https://stackoverflow.com/a/52948221
Future<String> fetchContent(http.Client client) async {
  final response = await client
      .get(Uri.parse('https://example.com/'));

  if (response.statusCode == 200) {
    var document = parse(response.body);
    return document.querySelector('body > div > p')!.text;
  } else {
    throw Exception('Failed to load content');
  }
}
