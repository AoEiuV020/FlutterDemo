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
