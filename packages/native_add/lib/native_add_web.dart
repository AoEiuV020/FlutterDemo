int sum(int a, int b) => a + b;
Future<int> sumAsync(int a, int b) => Future<int>.delayed(
      const Duration(seconds: 1),
      () => a + b,
    );
