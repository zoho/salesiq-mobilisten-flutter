class LauncherMode {
  const LauncherMode._(this.index);
  final int index;

  static const LauncherMode static = LauncherMode._(0);
  static const LauncherMode floating = LauncherMode._(1);

  static const List<LauncherMode> values = <LauncherMode>[static, floating];

  @override
  String toString() {
    return const <int, String>{0: '1', 1: '2'}[index]!;
  }
}

class LauncherProperties {
  LauncherMode mode = LauncherMode.floating;
  int? y;
  String? icon;
  Horizontal? horizontalDirection;
  Vertical? verticalDirection;
  LauncherProperties(LauncherMode launcherMode) {
    mode = launcherMode;
  }
}

class Horizontal {
  const Horizontal._(this.index);
  final int index;

  static const Horizontal left = Horizontal._(0);
  static const Horizontal right = Horizontal._(1);

  static const List<Horizontal> values = <Horizontal>[left, right];

  @override
  String toString() {
    return const <int, String>{
      0: 'HORIZONTAL_LEFT',
      1: 'HORIZONTAL_RIGHT'
    }[index]!;
  }
}

class Vertical {
  const Vertical._(this.index);
  final int index;

  static const Vertical top = Vertical._(0);
  static const Vertical bottom = Vertical._(1);

  static const List<Vertical> values = <Vertical>[top, bottom];

  @override
  String toString() {
    return const <int, String>{0: 'VERTICAL_TOP', 1: 'VERTICAL_BOTTOM'}[index]!;
  }
}
