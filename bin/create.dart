import 'dart:io';

Future<void> main(List<String> args) async {
  // 默认项目名为FlutterDemo
  final to = args.isEmpty ? 'FlutterDemo' : args[0];
  print('create demo to "$to"');

  // 执行flutter create命令
  final result = await Process.run('flutter', [
    'create',
    '--template',
    'app',
    '--org',
    'com.aoeiuv020.flutter',
    '--project-name',
    'demo',
    to,
  ]);

  if (result.exitCode != 0) {
    print('Error: ${result.stderr}');
    exit(1);
  }

  print(result.stdout);
}
