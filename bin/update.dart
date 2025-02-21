import 'dart:io';

// 路径处理工具类
class PathUtil {
  static final String separator = Platform.isWindows ? '\\' : '/';

  static String join(List<String> parts) {
    return parts.join(separator);
  }

  // 添加新方法：处理通配符路径
  static List<String> expandWildcardPath(String basePath, String pattern) {
    final results = <String>[];
    if (pattern.contains('*')) {
      // 处理 */README.md 这样的模式
      final parts = pattern.split('/');
      final wildcardIndex = parts.indexOf('*');
      if (wildcardIndex >= 0) {
        final baseDir = Directory(basePath);
        for (var entity in baseDir.listSync()) {
          if (entity is Directory) {
            final remainingPath = parts.sublist(wildcardIndex + 1).join('/');
            final potentialFile = PathUtil.join([entity.path, remainingPath]);
            if (FileSystemEntity.isFileSync(potentialFile)) {
              results.add(potentialFile.substring(basePath.length + 1));
            }
          }
        }
      }
    }
    return results;
  }
}

Future<void> main(List<String> args) async {
  // 保存当前目录
  final currentDir = Directory.current;

  // 获取脚本所在目录和项目根目录
  final scriptFile = File(Platform.script.toFilePath());
  final root = scriptFile.parent.parent;
  final rootTmp = Directory('${root.path}.tmp');

  // 获取Flutter版本
  final versionResult = await Process.run('flutter', ['--version']);
  if (versionResult.exitCode != 0) {
    print('Error getting Flutter version: ${versionResult.stderr}');
    exit(1);
  }
  final flutterVersion =
      (versionResult.stdout as String).split('\n').first.split(' ')[1];

  print('update ${root.path}');

  // 移动目录
  await root.rename(rootTmp.path);

  // 创建新项目
  final createScript = File(
    PathUtil.join([rootTmp.path, 'bin', 'create.dart']),
  );
  final createResult = await Process.run('dart', [
    createScript.path,
    root.path,
  ]);
  if (createResult.exitCode != 0) {
    print('Error creating new project: ${createResult.stderr}');
    exit(1);
  }

  // 切换到新项目目录
  Directory.current = root.path;

  // 修改需要保留的文件列表
  final filesToMove = [
    '.git',
    '.github',
    'LICENSE',
    'bin',
    'script',
    'README.md',
    'android/gradle/signing.gradle',
  ];

  // 添加通配符路径处理
  filesToMove.addAll(PathUtil.expandWildcardPath(rootTmp.path, '*/README.md'));

  for (final item in filesToMove) {
    final source = File(PathUtil.join([rootTmp.path, item]));
    final target = File(PathUtil.join([root.path, item]));

    if (await FileSystemEntity.isDirectory(source.path)) {
      await target.parent.create(recursive: true);
      await Directory(source.path).rename(target.path);
    } else if (await FileSystemEntity.isFile(source.path)) {
      await target.parent.create(recursive: true);
      await source.rename(target.path);
    }
  }

  // 修改主页标题
  final mainDartFile = File(PathUtil.join([root.path, 'lib', 'main.dart']));
  var mainContent = await mainDartFile.readAsString();
  mainContent = mainContent.replaceAll(
    'Flutter Demo',
    'Flutter Demo AoEiuV020',
  );
  await mainDartFile.writeAsString(mainContent);

  // 修改版本号
  final pubspecFile = File(PathUtil.join([root.path, 'pubspec.yaml']));
  var pubspecContent = await pubspecFile.readAsString();
  pubspecContent = pubspecContent.replaceFirst(
    RegExp(r'version: 1\.0\.0\+1'),
    'version: $flutterVersion+1',
  );
  await pubspecFile.writeAsString(pubspecContent);

  // 添加安卓签名配置
  final buildGradleFile = File(
    PathUtil.join([root.path, 'android', 'app', 'build.gradle.kts']),
  );
  await buildGradleFile.writeAsString(
    '\napply(rootDir.resolve("gradle/signing.gradle"))\n',
    mode: FileMode.append,
  );

  // 显示git状态
  final gitResult = await Process.run('git', ['status']);
  print(gitResult.stdout);

  // 清理临时目录
  await rootTmp.delete(recursive: true);

  // 恢复原来的目录
  Directory.current = currentDir;
}
