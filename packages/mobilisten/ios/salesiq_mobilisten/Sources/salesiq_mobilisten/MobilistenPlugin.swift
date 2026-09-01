import Flutter
import Mobilisten

public final class MobilistenPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        SwiftMobilistenPlugin.register(with: registrar)
        SwiftMobilistenPlugin.emptyChatInstance = SIQVisitorChat()
    }
}
