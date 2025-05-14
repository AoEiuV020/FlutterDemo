import 'dart:convert';

import 'native_add_io.dart'
    if (dart.library.html) 'native_add_web.dart'
    as native_add;

int sum(int a, int b) => native_add.sum(a, b);
Future<int> sumAsync(int a, int b) => native_add.sumAsync(a, b);

String sumString(String a, String b) => native_add.sumString(a, b);

/// 调用HTTP API进行加法计算
/// 如果调用成功，返回结果
/// 如果调用失败，抛出异常
Future<int> sumViaHttp(int a, int b) => native_add.sumViaHttp(a, b);

/// 每次调用将全局计数器加一并返回
int increase() => native_add.increase();

/// 通用调用接口，根据方法名和JSON参数字符串调用对应的Go函数
///
/// 参数:
///   - method: 要调用的方法名
///   - params: 包含参数的Map对象
///
/// 返回: 解析后的结果Map对象
///
/// 异常:
///   - 如果返回的JSON结果包含error字段，将抛出异常
Map<String, dynamic> goCall(String method, Map<String, dynamic> params) {
  // 将Map转换为JSON字符串
  final paramJSON = jsonEncode(params);

  // 调用底层native实现
  final resultJSON = native_add.goCall(method, paramJSON);

  // 解析返回的JSON字符串
  final resultMap = jsonDecode(resultJSON) as Map<String, dynamic>;

  // 检查是否包含error字段
  if (resultMap.containsKey('error') && resultMap['error'] != null) {
    throw Exception(resultMap['error']);
  }

  return resultMap;
}

/// 异步通用调用接口，适用于可能耗时较长的操作
///
/// 参数:
///   - method: 要调用的方法名
///   - params: 包含参数的Map对象
///
/// 返回: Future<Map<String, dynamic>>，解析后的结果Map对象
///
/// 异常:
///   - 如果返回的JSON结果包含error字段，将抛出异常
Future<Map<String, dynamic>> goCallAsync(
  String method,
  Map<String, dynamic> params,
) async {
  // 将Map转换为JSON字符串
  final paramJSON = jsonEncode(params);

  // 调用底层native异步实现
  final resultJSON = await native_add.goCallAsync(method, paramJSON);

  // 解析返回的JSON字符串
  final resultMap = jsonDecode(resultJSON) as Map<String, dynamic>;

  // 检查是否包含error字段
  if (resultMap.containsKey('error') && resultMap['error'] != null) {
    throw Exception(resultMap['error']);
  }

  return resultMap;
}
