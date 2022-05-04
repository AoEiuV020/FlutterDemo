import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

/// web端https网站请求http会有mixed-content问题，浏览器规范限制，不是代码能解决的，
/// chrome可以在网站设置(Site settings)中允许不安全内容(Insecure content)就可以了，
/// 或者添加参数--allow-running-insecure-content也能解除这个限制，
/// 设置无效的话可以尝试清除网站数据(Clear data)再刷新，
/// 恶心了，清除数据也只生效一次，
/// 一旦运行了一次，安装上了flutter service worker,
/// 后续就会无视浏览器在flutter service worker内部弹出mixed-content报错，
/// 打包时可以禁用这个service worker,
/// flutter build web --pwa-strategy=none
/// https://github.com/flutter/flutter/issues/74223#issuecomment-763599495
Future<String> fetchContent(http.Client client) async {
  final response = await client
      .get(Uri.parse('http://example.com/'));

  if (response.statusCode == 200) {
    var document = parse(response.body);
    return document.querySelector('body > div > p')!.text;
  } else {
    throw Exception('Failed to load content');
  }
}
