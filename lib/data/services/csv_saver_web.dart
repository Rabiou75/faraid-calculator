import 'dart:convert';
import 'package:web/web.dart' as web;

Future<void> saveCsv(String filename, List<int> bytes) async {
  // Convert the UTF-8 bytes directly to a Base64 Data URI
  final base64Data = base64Encode(bytes);
  final dataUri = 'data:text/csv;charset=utf-8;base64,$base64Data';
  
  // Create a hidden anchor element pointing to the Data URI
  final anchor = web.HTMLAnchorElement()
    ..href = dataUri
    ..download = filename
    ..style.display = 'none';
  
  // Append to body, click, and remove to trigger the download
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}