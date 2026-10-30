import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

Future<void> saveCsv(String filename, List<int> bytes) async {
  await FileSaver.instance.saveFile(
    name: filename.replaceAll('.csv', ''),
    bytes: Uint8List.fromList(bytes),
    fileExtension: 'csv',
    mimeType: MimeType.csv,
  );
}