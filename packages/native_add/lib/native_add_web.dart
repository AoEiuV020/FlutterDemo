int sum(int a, int b) => a + b;

Future<int> sumAsync(int a, int b) =>
    Future.delayed(Duration(seconds: 1), () => sum(a, b));
