import UIKit
import Flutter
import PushKit
// The Calls SDK: ZohoSalesIQCalls lives in MobilistenCalls; APNSMode lives in MobilistenCore.
// These mirror what the salesiq_mobilisten_calls plugin imports/calls internally.
import MobilistenCalls
import MobilistenCore

@main
@objc class AppDelegate: FlutterAppDelegate {

    // The VoIP (PushKit) registry must be retained for the app's lifetime, so keep a strong reference.
    private var voipRegistry: PKPushRegistry?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }        
        }

        // Register for VoIP (PushKit) pushes so an incoming SalesIQ call can wake the app even when it's
        // backgrounded/terminated. Requires the "voip" UIBackgroundMode + the Push Notifications
        // capability. The token is forwarded to the Calls SDK in didUpdatePushCredentials below.
        let registry = PKPushRegistry(queue: .main)
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
        voipRegistry = registry

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}

// MARK: - VoIP (PushKit)
extension AppDelegate: PKPushRegistryDelegate {

    // The VoIP push token was issued/updated — hand it to the Calls SDK so the backend can route
    // incoming calls to this device. isTestDevice: true / .sandbox uses the APNs sandbox for dev;
    // flip to .production for release.
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard type == .voIP else { return }
        let token = pushCredentials.token.map { String(format: "%02x", $0) }.joined()
        Task { @MainActor in
            ZohoSalesIQCalls.enableVoIP(token, isTestDevice: true, mode: .sandbox)
        }
    }

    // An incoming VoIP push arrived — forward the payload to the Calls SDK, which presents the call
    // (CallKit) and invokes the completion handler once handled.
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        Task { @MainActor in
            ZohoSalesIQCalls.handleVOIPNotificationAction(payload.dictionaryPayload) {
                completion()
            }
        }
    }
}
