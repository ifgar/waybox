import 'dart:convert';
import 'dart:io';

/// Represents a Hyprland monitor with its reserved and effective area.
class HyprMonitorInfo {
  final int id;
  final String name;
  final int width;
  final int height;

  /// Reserved pixels: [left, top, right, bottom]
  final List<int> reserved;

  /// Width after subtracting left + right reserved space.
  final int effectiveWidth;

  /// Height after subtracting top + bottom reserved space.
  final int effectiveHeight;

  HyprMonitorInfo({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.reserved,
    required this.effectiveWidth,
    required this.effectiveHeight,
  });

  /// Builds a [HyprMonitorInfo] from the JSON returned by `hyprctl monitors -j`.
  factory HyprMonitorInfo.fromJson(Map<String, dynamic> json) {
    final reserved = List<int>.from(json["reserved"]);
    final width = json["width"] as int;
    final height = json["height"] as int;

    return HyprMonitorInfo(
      id: json["id"] as int,
      name: json["name"] as String,
      width: width,
      height: height,
      reserved: reserved,
      effectiveWidth: width - (reserved[0] + reserved[2]), // right + left
      effectiveHeight: height - (reserved[1] + reserved[3]), // top + bottom
    );
  }
}

/// Loads the monitor list using `hyprctl monitors -j`.
Future<List<HyprMonitorInfo>> loadHyprMonitors() async {
  final result = await Process.run("hyprctl", ["monitors", "-j"]);

  if (result.exitCode != 0) {
    // For now just print the error and return an empty list.
    stderr.writeln("Failed to read hyprctl monitors: ${result.stderr}");
    return [];
  }

  final List<dynamic> data = jsonDecode(result.stdout);
  return data.map((e) => HyprMonitorInfo.fromJson(e as Map<String, dynamic>)).toList();
}
