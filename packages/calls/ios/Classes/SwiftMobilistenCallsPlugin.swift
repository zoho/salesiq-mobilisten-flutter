import Flutter
import UIKit
import MobilistenCore
import MobilistenCalls
import MobilistenCallsCore


public class SwiftMobilistenCallsPlugin: NSObject, FlutterPlugin {
    
    // MARK: - Properties
    private static var channel: FlutterMethodChannel?
    
    static var sharedInstance: SwiftMobilistenCallsPlugin?
    
    private var eventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    // MARK: - Flutter Plugin Registration
    public static func register(with registrar: FlutterPluginRegistrar) {
        guard sharedInstance == nil else {
            return
        }
        let channel = FlutterMethodChannel(name: "mobilisten_calls_api", binaryMessenger: registrar.messenger())
        let instance = SwiftMobilistenCallsPlugin()
        sharedInstance = instance
        registrar.addMethodCallDelegate(instance, channel: channel)
        self.channel = channel
        Task { @MainActor in
            ZohoSalesIQCalls.initialise()
            sharedInstance?.registerEvents(with: registrar)
        }
    }
    
    // MARK: - Method Call Handling
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task { @MainActor in
            switch call.method {
            case "isEnabled":
                isEnabled(result: result)
            case "currentCallId":
                currentCallId(result: result)
            case "currentCallState":
                currentCallState(result: result)
            case "enterFullScreenMode":
                enterFullScreenMode(result: result)
            case "enterFloatingViewMode":
                enterFloatingViewMode(result: result)
            case "setTitle":
                setTitle(argument: call.argumentDictionary, result: result)
            case "start":
                start(argument: call.argumentDictionary, result: result)
            case "end":
                end(result: result)
            case "setVisibility":
                setVisibility(argument: call.argumentDictionary, result: result)
            case "getCallConversations":
                getCallConversations(result: result)
            case "setCallKitIcon":
                setCallKitIcon(icon: call.arguments as? String, result: result)
            case "SalesIQAndroidCallStatusBarView": break
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    // MARK: - isEnabled
    @MainActor private func isEnabled(result: @escaping FlutterResult) {
        let isEnabled = ZohoSalesIQCalls.isEnabled
        result(isEnabled)
    }
    
    // MARK: - currentCallId
    @MainActor private func currentCallId(result: @escaping FlutterResult) {
        let callId = ZohoSalesIQCalls.currentCallID
        result(callId)
        
    }
    
    // MARK: - currentCallState
    @MainActor private func currentCallState(result: @escaping FlutterResult) {
        result(getCurrentCallState(ZohoSalesIQCalls.currentState))
    }
    
    // MARK: - enterFullScreenMode
    @MainActor private func enterFullScreenMode(result: @escaping FlutterResult) {
        ZohoSalesIQCalls.switchToFullScreen()
        result(nil)
    }
    
    // MARK: - enterFloatingViewMode
    @MainActor private func enterFloatingViewMode(result: @escaping FlutterResult) {
        ZohoSalesIQCalls.switchToFloatingScreen()
        result(nil)
    }
    
    // MARK: - setTitle
    @MainActor private func setTitle(argument: [String: Any]?, result: @escaping FlutterResult) {
        let onlineTitle = argument?["onlineTitle"] as? String
        let offlineTitle = argument?["offlineTitle"] as? String
        ZohoSalesIQCalls.setTitle(online: onlineTitle, offline: offlineTitle)
        result(nil)
    }
    
    // MARK: - start
    @MainActor private func start(argument: [String: Any]?, result: @escaping FlutterResult) {
        let id = argument?["id"] as? String ?? nil
        let displayActiveCall = argument?["displayActiveCall"] as? Bool ?? false
        var customAttributes: (name: String, additionalInfo: String, dislayPicture: String, departments: [SIQDepartment]) = (
            name: "",
            additionalInfo: "",
            dislayPicture: "",
            departments: []
        )
        
        if let attributes = argument?["attributes"] as? [String: Any] {
            if let name = attributes["name"] as? String {
                customAttributes.name = name
            }
            
            if let additionalInfo = attributes["additionalInfo"] as? String {
                customAttributes.additionalInfo = additionalInfo
            }
            
            if let departments = attributes["departments"] as? [[String: Any]] {
                var departmentsList: [SIQDepartment] = []
                departments.forEach { department in
                    let id = department["id"] as? String
                    let name = department["name"] as? String
                    if id?.isEmpty == false || name?.isEmpty == false {
                        if let mode = department["communicationMode"] as? Int, let communicationMode = SIQCommunicationMode(rawValue: mode) {
                            departmentsList.append(SIQDepartment(id: id, name: name, mode: communicationMode))
                        }
                    }
                }
                customAttributes.departments = departmentsList
            }
            
            if let displayPicture = attributes["displayPicture"] as? String {
                customAttributes.dislayPicture = displayPicture
            }
        }
                
        ZohoSalesIQCalls.start(id: id, name: customAttributes.name, additionalInfo: customAttributes.additionalInfo, displayImage: customAttributes.dislayPicture, departments: customAttributes.departments, displayActiveCall: displayActiveCall) { [self] error, conversation in
            if let conversation = conversation {
                if let chatConversation = conversation as? SalesIQChat {
                    let chatMap = getChatConversationMap(chat: chatConversation)
                    result(chatMap)
                } else if let callConversation = conversation as? SalesIQCall {
                    let callMap = getCallConversationMap(call: callConversation)
                    result(callMap)
                } else {
                    result(nil)
                }
            } else {
                result(getCallError(error: error))
            }
        }
    }
    
    // MARK: - end
    @MainActor private func end(result: @escaping FlutterResult) {
        ZohoSalesIQCalls.end { [self] error,conversation in
            if let conversation = conversation {
                if let chatConversation = conversation as? SalesIQChat {
                    let chatMap = getChatConversationMap(chat: chatConversation)
                    result(chatMap)
                } else if let callConversation = conversation as? SalesIQCall {
                    let callMap = getCallConversationMap(call: callConversation)
                    result(callMap)
                } else {
                    result(nil)
                }
            } else {
                result(getCallError(error: error))
            }
        }
    }
    
    // MARK: - setVisibility
    @MainActor private func setVisibility(argument: [String: Any]?, result: @escaping FlutterResult) {
        guard let visibility = argument?["component"] as? String, let visible = argument?["isVisible"] as? Bool else {
            result(nil)
            return
        }
        
        switch visibility {
        case "operatorName":
            ZohoSalesIQCalls.setVisibility(.operatorName, visible: visible)
        case "operatorImage":
            ZohoSalesIQCalls.setVisibility(.operatorImage, visible: visible)
        case "preChatForm":
            ZohoSalesIQCalls.setVisibility(.preChatForm, visible: visible)
        case "queuePosition":
            ZohoSalesIQCalls.setVisibility(.queuePosition, visible: visible)
        default:
            break
        }
        result(nil)
    }
    
    // MARK: - getCallConversations
    @MainActor private func getCallConversations(result: @escaping FlutterResult) {
        ZohoSalesIQCalls.getList { [self] error, conversations in
            if let error = error {
                result(getCallError(error: error))
                return
            } else {
                var conversationMaps: [[String: Any]] = []
                for conversation in conversations {
                    if let chatConversation = conversation as? SalesIQChat {
                        let chatMap = getChatConversationMap(chat: chatConversation)
                        conversationMaps.append(chatMap)
                    } else if let callConversation = conversation as? SalesIQCall {
                        let callMap = getCallConversationMap(call: callConversation)
                        conversationMaps.append(callMap)
                    }
                }
                result(conversationMaps)
            }
        }
    }
    
    // MARK: - setCallKitIcon
    @MainActor private func setCallKitIcon(icon: String?, result: @escaping FlutterResult) {
        if let icon = icon {
            ZohoSalesIQCalls.setCallKitIcon(icon: icon)
        }
    }
    
    
    @MainActor func getCurrentCallState(_ state: SalesIQCallState) -> [String: Any] {
        let callState = state
        var isIncomingCall: Bool? {
            if callState.direction == .none {
                return nil
            }
            return callState.direction == .incoming
        }
        let currentStateDict: [String: Any] = ["status": getCallStatus(callState.status), "isIncomingCall": isIncomingCall ?? nil]
        return currentStateDict
    }
}

extension SwiftMobilistenCallsPlugin {
    func getCallError(error: SIQError?) -> FlutterError? {
        guard let err = error else { return nil }
        return FlutterError(code: String(err.code), message: err.message, details: nil)
    }
}
    
extension FlutterMethodCall {
    
    var argumentDictionary: [String: Any]? {
        return arguments as? [String: Any]
    }
    
    var argumentList: [Any]? {
        return arguments as? [Any]
    }
}


extension SwiftMobilistenCallsPlugin: @preconcurrency FlutterStreamHandler {
    
    func registerEvents(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterEventChannel(name: "mobilistenCallEvents", binaryMessenger: registrar.messenger())
        channel.setStreamHandler(SwiftMobilistenCallsPlugin())
        SwiftMobilistenCallsPlugin.sharedInstance?.eventChannel = channel
    }
    
    func sendEvent(_ name: String, data: [String: Any]? = nil) {
        guard let sink = SwiftMobilistenCallsPlugin.sharedInstance?.eventSink else { return }
        var event: [String: Any] = ["eventName": name]
        if let data = data {
            event["data"] = data
        }
        sink(event)
    }
    
    @MainActor public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        SwiftMobilistenCallsPlugin.sharedInstance?.eventSink = events
        let listener = MobilistenCallsListeners()
        ZohoSalesIQCalls.delegate = listener
        return nil
    }
    
    @MainActor public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        SwiftMobilistenCallsPlugin.sharedInstance?.eventSink = nil
        ZohoSalesIQCalls.delegate = nil
        return nil
    }
}

// MARK: - ZohoSalesIQCallsDelegate
extension SwiftMobilistenCallsPlugin {
    func queuePositionDidChange(for conversationID: String, position: Int) {
        let data: [String : Any] = ["conversationId": conversationID, "position": position]
        sendEvent("queuePositionChanged", data: data)
    }
    
    func callStateDidChange(for state: MobilistenCallsCore.SalesIQCallState) {
        Task { @MainActor in
            let currentStateDict: [String: Any] = getCurrentCallState(state)
            sendEvent("callStateChanged", data: currentStateDict)
        }
    }
    
    func callScreenDidAppear() {

    }
    
    func callScreenDidDisappear() {
        
    }
    
   func callScreenDidEnterPiPMode() {
       
    }
    
    func callScreenDidEnterFullScreenMode() {
        
    }
}
