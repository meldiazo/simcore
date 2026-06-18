import 'dart:io';

Future<String> downloadFile(List<int> bytes, String fileName) async {
  final directory = Directory.systemTemp;
  final file = File('${directory.path}${Platform.pathSeparator}$fileName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
