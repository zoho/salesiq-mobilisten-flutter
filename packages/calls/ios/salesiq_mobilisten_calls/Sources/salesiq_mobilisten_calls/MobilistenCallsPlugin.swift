import Flutter

public final class MobilistenCallsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftMobilistenCallsPlugin.register(with: registrar)
    }
}
