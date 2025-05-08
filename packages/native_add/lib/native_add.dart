import 'native_add_io.dart'
    if (dart.library.html) 'native_add_web.dart'
    as native_add;

int sum(int a, int b) => native_add.sum(a, b);
Future<int> sumAsync(int a, int b) => native_add.sumAsync(a, b);
