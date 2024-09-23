// ignore_for_file: public_member_api_docs

String? colorToHex(String? color) {
  if (color == null) {
    return null;
  }

  if (color.contains("0x")) {
    final regex = RegExp(r'0x(\w{8})');
    final match = regex.firstMatch(color);
    if (match != null) {
      final argb = match.group(1)!;
      final alphaHex = argb.substring(0, 2);
      final redHex = argb.substring(2, 4);
      final greenHex = argb.substring(4, 6);
      final blueHex = argb.substring(6, 8);

      final alpha = int.parse(alphaHex, radix: 16);
      final red = int.parse(redHex, radix: 16);
      final green = int.parse(greenHex, radix: 16);
      final blue = int.parse(blueHex, radix: 16);
      return 'rgba($red, $green, $blue, ${alpha / 255.0})';
    }
  }
  return color;
}
