import 'dart:ui';

import 'package:meta/meta.dart';

class ModernBlockThemes {
  static const ModernBlockTheme blue = ModernBlockTheme(
    background: Color.fromARGB(255, 76, 151, 255),
    border: Color.fromARGB(255, 61, 121, 204),
  );

  static const ModernBlockTheme orange = ModernBlockTheme(
    background: Color.fromARGB(255, 255, 171, 25),
    border: Color.fromARGB(255, 207, 139, 23),
  );

  static const ModernBlockTheme yellow = ModernBlockTheme(
    background: Color.fromARGB(255, 237, 190, 63),
    border: Color.fromARGB(255, 189, 152, 51),
  );
}

class ModernBlockTheme {
  final Color background;
  final Color border;

  const ModernBlockTheme({
    @required this.background,
    @required this.border,
  });
}
