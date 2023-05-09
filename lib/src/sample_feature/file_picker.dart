import 'package:file_picker/file_picker.dart';

Future<PlatformFile?> pickFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.any,
    withData: false,
    withReadStream: true,
  );
  if (result == null) return null;
  return result.files.first;
}
