import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<String?> getBase64EncodedImage(dynamic source) async {
  try {
    if (source == null) return null;

    Uint8List? bytes = null;
    // 1. Network image
    if (source is String && source.startsWith('http')) {
      final response = await http.get(Uri.parse(source));
      if (response.statusCode == 200) bytes = response.bodyBytes;
    }

    // 2. File image
    else if (source is File) {
      bytes = await source.readAsBytes();
    }

    // 3. Memory (raw bytes)
    else if (source is Uint8List) {
      bytes = source;
    }

    // 4. Base64-encoded string
    else if (source is String &&
        source.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
      return source;
    }

    // 5. ByteData
    else if (source is ByteData) {
      bytes = source.buffer.asUint8List();
    }

    // 6. XFile (from image_picker or file_picker)
    else if (source is XFile) {
      bytes = await source.readAsBytes();
    }

    // 7. URI as String (e.g. file:///storage/emulated/0/Pictures/test.jpg)
    else if (source is String && source.startsWith('file://')) {
      final file = File(Uri.parse(source).toFilePath());
      if (await file.exists()) bytes = await file.readAsBytes();
    }

    // 8. Uri
    else if (source is Uri) {
      final file = File(source.toFilePath());
      if (await file.exists()) bytes = await file.readAsBytes();
    }

    // 9. Asset image
    else if (source is String && !source.startsWith('http')) {
      final data = await rootBundle.load(source);
      bytes = data.buffer.asUint8List();
    }

    return bytes != null
        ? "data:image/jpeg;base64,${base64Encode(bytes)}"
        : null;
  } catch (e) {
    debugPrint('Error loading image bytes: $e');
  }

  return null;
}
