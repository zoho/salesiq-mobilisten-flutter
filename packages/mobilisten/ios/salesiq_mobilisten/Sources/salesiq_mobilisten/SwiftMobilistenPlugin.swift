import Flutter
import Mobilisten
import MobilistenCore
import UIKit

@objc(MobilistenPlugin)
public class SwiftMobilistenPlugin: NSObject, FlutterPlugin {

    private enum MobilistenChannel {

        case plugin
        case main
        case chat
        case knowledgeBase
        case resource
        case launcher
        case launcherEvent
        case chatModule
        case notificationModule
        case notificationEvent
        case conversationModule
        case visitorModule
        case homepageModule
        case trackingModule
        case chatActionsModule
        case helpCenterModule

        var name: String {
            switch self {
            case .plugin:
                return "salesiq_mobilisten"
            case .main:
                return "mobilistenEventChannel"
            case .chat:
                return "mobilistenChatEventChannel"
            case .knowledgeBase:
                return "salesiq_knowledge_base"
            case .resource:
                return "mobilisten_knowledge_base_events"
            case .launcher:
                return "salesiq_launcher_module"
            case .launcherEvent:
                return "mobilistenLauncherEventChannel"
            case .chatModule:
                return "salesiq_chat_module"
            case .notificationModule:
                return "salesiqNotificationModule"
            case .notificationEvent:
                return "mobilistenNotificationEvents"
            case .conversationModule:
                return "salesiq_conversations_module"
            case .visitorModule:
                return "salesiq_visitor_module"
            case .homepageModule:
                return "salesiq_homepage_module"
            case .trackingModule:
                return "salesiq_tracking_module"
            case .chatActionsModule:
                return "salesiq_chatactions_module"
            case .helpCenterModule:
                return "salesiq_help_center"
            }
        }

        func createMethodChannel(registrar: FlutterPluginRegistrar) -> FlutterMethodChannel {
            return FlutterMethodChannel(name: self.name, binaryMessenger: registrar.messenger())
        }

        func createEventChannel(registrar: FlutterPluginRegistrar) -> FlutterEventChannel {
            return FlutterEventChannel(name: self.name, binaryMessenger: registrar.messenger())
        }

    }

    public enum MobilistenPluginFlag {
        case autoHandlePushNotifications
        case enableDisabledEvents
    }

    enum MobilistenEvent: String {

        static var nameKey: String = "eventName"
        static var errorKey: String = "error"

        case supportOpened = "supportOpened"
        case supportClosed = "supportClosed"
        case operatorsOnline = "operatorsOnline"
        case operatorsOffline = "operatorsOffline"
        case visitorIPBlocked = "visitorIPBlocked"
        case customTrigger = "customTrigger"
        case chatViewOpened = "chatViewOpened"
        case chatViewClosed = "chatViewClosed"
        case chatOpened = "chatOpened"
        case chatClosed = "chatClosed"
        case chatAttended = "chatAttended"
        case chatMissed = "chatMissed"
        case performChatAction = "performChatAction"
        case chatQueuePositionChanged = "chatQueuePositionChanged"
        case chatReopened = "chatReopened"
        case chatRatingReceived = "chatRatingReceived"
        case chatFeedbackReceived = "chatFeedbackReceived"
        case homeViewOpened = "homeViewOpened"
        case homeViewClosed = "homeViewClosed"
        case chatUnreadCountChanged = "chatUnreadCountChanged"
        case handleURL = "handleURL"
        case customLauncherVisibility = "customLauncherVisibility"
        case botTrigger = "botTrigger"
        case resourceOpened = "resourceOpened"
        case resourceClosed = "resourceClosed"
        case resourceLiked = "resourceLiked"
        case resourceDisliked = "resourceDisliked"
        case notificationClicked = "notificationClicked"
        case chatError = "chatError"
        case chatExpired = "chatExpired"
        case resourceError = "resourceError"
        case reRegisterPush = "reRegisterPush"

        var enabled: Bool {
            switch self {
            case .homeViewOpened, .homeViewClosed:
                return SwiftMobilistenPlugin.checkFlag(name: .enableDisabledEvents)
            default:
                return true
            }
        }

    }

    private static var eventChannel: FlutterEventChannel?
    private static var chatEventChannel: FlutterEventChannel?
    private static var resourceEventChannel: FlutterEventChannel?
    private static var launcherEventChannel: FlutterEventChannel?
    private static var notificationEventChannel: FlutterEventChannel?
    private static var chatModuleEventChannel: FlutterEventChannel?
    private static var conversationEventChannel: FlutterEventChannel?
    @objc public static var emptyChatInstance: SIQVisitorChat?

    var eventSink: FlutterEventSink?
    var launcherEventSink: FlutterEventSink?
    var chatEventSink: FlutterEventSink?
    var notificationEventSink: FlutterEventSink?
    var resourceEventSink: FlutterEventSink?
    private var handleURL = true

    static var knowledgeBaseInstance: KnowledgeBasePlugin?
    static var launcherInstance: LauncherPlugin?
    static var notificationInstance: NotificationPlugin?
    static var chatModuleInstance: ChatModulePlugin?
    static var conversationInstance: ConversationPlugin?
    static var visitorInstance: VisitorPlugin?
    static var homepageInstance: HomepagePlugin?
    static var trackingInstance: TrackingPlugin?
    static var helpCenterInstance: HelpCenterPlugin?
    static var sharedInstance: SwiftMobilistenPlugin?
    private var chatActionStore: [String: SIQActionHandler] = [:]

    private static var mobilistenPluginFlags: [MobilistenPluginFlag: Bool] = [
        .autoHandlePushNotifications: true,
        .enableDisabledEvents: false,
    ]

    // Shared fallback error codes. These are the wrapper's OWN synthetic codes (not native
    // SalesIQ codes, which are positive) — negative so a wrapper-origin fallback is unmistakable
    // and can't collide with a native code. Keep in sync with the Android plugin (MobilistenPlugin).
    private enum ErrorCode {
        static let unknown = "-1000"
        static let chatOperationFailed = "-1001"
        static let conversationOperationFailed = "-1002"
        static let fetchAttenderImageFailed = "-1003"
        static let helpCenterAskFailed = "-1004"
        static let invalidResourceType = "-1005"
        static let unknownScreenType = "-1006"
    }

    private func getErrorMessage(_ error: String?, code: String = ErrorCode.unknown) -> FlutterError {
        return FlutterError(code: code, message: error ?? "operation failed", details: nil)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {

        let methodChannel = MobilistenChannel.plugin.createMethodChannel(registrar: registrar)
        let knowledgeBaseChannel = MobilistenChannel.knowledgeBase.createMethodChannel(registrar: registrar)
        let launcherChannel = MobilistenChannel.launcher.createMethodChannel(registrar: registrar)
        let notificationChannel = MobilistenChannel.notificationModule.createMethodChannel(registrar: registrar)
        let chatModuleChannel = MobilistenChannel.chatModule.createMethodChannel(registrar: registrar)
        let conversationChannel = MobilistenChannel.conversationModule.createMethodChannel(registrar: registrar)
        let visitorChannel = MobilistenChannel.visitorModule.createMethodChannel(registrar: registrar)
        let homepageChannel = MobilistenChannel.homepageModule.createMethodChannel(registrar: registrar)
        let trackingChannel = MobilistenChannel.trackingModule.createMethodChannel(registrar: registrar)
        let chatActionsChannel = MobilistenChannel.chatActionsModule.createMethodChannel(registrar: registrar)
        let helpCenterChannel = MobilistenChannel.helpCenterModule.createMethodChannel(registrar: registrar)

        eventChannel = MobilistenChannel.main.createEventChannel(registrar: registrar)
        chatEventChannel = MobilistenChannel.chat.createEventChannel(registrar: registrar)
        resourceEventChannel = MobilistenChannel.resource.createEventChannel(registrar: registrar)
        launcherEventChannel = MobilistenChannel.launcherEvent.createEventChannel(registrar: registrar)
        notificationEventChannel = MobilistenChannel.notificationEvent.createEventChannel(registrar: registrar)
        chatModuleEventChannel = MobilistenChannel.chatModule.createEventChannel(registrar: registrar)
        conversationEventChannel = MobilistenChannel.conversationModule.createEventChannel(registrar: registrar)

        let instance = SwiftMobilistenPlugin()
        let knowledgeBase = KnowledgeBasePlugin()
        let launcher = LauncherPlugin()
        let notification = NotificationPlugin()
        let chatModule = ChatModulePlugin()
        let conversationModule = ConversationPlugin(channel: conversationChannel)
        let visitorModule = VisitorPlugin()
        let homepageModule = HomepagePlugin()
        let trackingModule = TrackingPlugin()
        let helpCenterModule = HelpCenterPlugin()
        sharedInstance = instance
        emptyChatInstance = SIQVisitorChat()
        knowledgeBaseInstance = knowledgeBase
        launcherInstance = launcher
        notificationInstance = notification
        chatModuleInstance = chatModule
        conversationInstance = conversationModule
        visitorInstance = visitorModule
        homepageInstance = homepageModule
        trackingInstance = trackingModule
        helpCenterInstance = helpCenterModule

        let eventStreamHandler = MobilistenEventStreamHandler(plugin: instance)
        let chatEventStreamHandler = MobilistenChatEventStreamHandler(plugin: instance)
        let resourceEventStreamHandler = MobilistenResourceEventStreamHandler(plugin: instance)
        let notificationEventStreamHandler = MobilistenNotificationEventStreamHandler(plugin: instance)
        let launcherEventStreamHandler = MobilistenLauncherEventStreamHandler(plugin: instance)

        eventChannel?.setStreamHandler(eventStreamHandler)
        chatEventChannel?.setStreamHandler(chatEventStreamHandler)
        resourceEventChannel?.setStreamHandler(resourceEventStreamHandler)
        notificationEventChannel?.setStreamHandler(notificationEventStreamHandler)
        launcherEventChannel?.setStreamHandler(launcherEventStreamHandler)
        chatModuleEventChannel?.setStreamHandler(eventStreamHandler)

        registrar.addApplicationDelegate(instance)
        registrar.addSceneDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        registrar.addMethodCallDelegate(knowledgeBase, channel: knowledgeBaseChannel)
        registrar.addMethodCallDelegate(launcher, channel: launcherChannel)
        registrar.addMethodCallDelegate(notification, channel: notificationChannel)
        registrar.addMethodCallDelegate(chatModule, channel: chatModuleChannel)
        registrar.addMethodCallDelegate(conversationModule, channel: conversationChannel)
        registrar.addMethodCallDelegate(visitorModule, channel: visitorChannel)
        registrar.addMethodCallDelegate(homepageModule, channel: homepageChannel)
        registrar.addMethodCallDelegate(trackingModule, channel: trackingChannel)
        registrar.addMethodCallDelegate(instance, channel: chatActionsChannel)
        registrar.addMethodCallDelegate(helpCenterModule, channel: helpCenterChannel)
    }

    // MARK: Perform any additional setup after initialisation.
    func performAdditionalSetup() {
        // your code goes here.
    }

    // Tracking: performCustomAction is module-only and handled here; setPageTitle is promoted to
    // the flat `ZohoSalesIQ` facade and stays in the main handle (see TrackingPlugin routing).
    func handleTrackingMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments
        switch call.method {
        case "performCustomAction":
            if let actionName = argument as? String {
                ZohoSalesIQ.Tracking.setCustomAction(actionName)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Visitor: updateVisitorProfile is module-only and handled here; performCustomAction is
    // promoted to the flat `ZohoSalesIQ` facade and stays in the main handle (see VisitorPlugin).
    func handleVisitorMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "updateVisitorProfile":
            if let args = call.argumentDictionary {
                ZohoSalesIQ.Visitor.updateProfile(getVisitorProfile(from: args))
            }
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // Homepage: all its methods are module-only.
    func handleHomepageMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments
        switch call.method {
        case "setHomepageEnabled":
            if let enabled = argument as? Bool {
                ZohoSalesIQ.Homepage.setEnabled(enabled)
            }
        case "setHomepageWidgetVisibility":
            if let args = call.argumentDictionary,
                let widgetName = args["widget"] as? String,
                let visible = args["visible"] as? Bool,
                let widget = getHomepageWidget(widgetName)
            {
                ZohoSalesIQ.Homepage.setVisibility(widget, visible: visible)
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // HelpCenter: helpCenterAsk is module-only.
    func handleHelpCenterMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let argument = call.arguments
        switch call.method {
        case "helpCenterAsk":
            let question = argument as? String
            Task { @MainActor in
                ZohoSalesIQ.HelpCenter.ask(question) { error, success in
                    if let error = error {
                        result(self.getError(error: error))
                    } else {
                        result(nil)
                    }
                }
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        var argument: Any? {
            return call.arguments
        }

        switch call.method {
        case "init":
            ZohoSalesIQ.setPlatform(platform: "Flutter")
            if let args = call.argumentDictionary, let appKey = args["appKey"] as? String, let accessKey = args["accessKey"] as? String {

                ZohoSalesIQ.initWithAppKey(appKey, accessKey: accessKey) { error in
                    if let error = error {
                        result(self.getError(error: error))
                    } else {
                        result(nil)
                    }
                }
                ZohoSalesIQ.delegate = self
                ZohoSalesIQ.Chat.delegate = self
                ZohoSalesIQ.KnowledgeBase.delegate = self
                self.performAdditionalSetup()
            }
        case "showLauncher":
            if let show = argument as? Bool {
                ZohoSalesIQ.showLauncher(show)
            }
        case "setLanguage":
            if let code = argument as? String {
                ZohoSalesIQ.Chat.setLanguageWithCode(code)
            }
        case "setDepartment":
            if let department = argument as? String {
                ZohoSalesIQ.Chat.setDepartment(department)
            }
        case "setDepartments":
            if let departments = argument as? [String] {
                ZohoSalesIQ.Chat.setDepartments(departments)
            }
        case "setQuestion":
            if let question = argument as? String {
                ZohoSalesIQ.Visitor.setQuestion(question)
            }
        case "startChat":
            if let question = argument as? String {
                ZohoSalesIQ.Chat.startChat(question: question)
            }
        case "setConversationVisibility":
            if let show = argument as? Bool {
                ZohoSalesIQ.Conversation.setVisibility(show)
            }
        case "setConversationListTitle":
            if let title = argument as? String {
                ZohoSalesIQ.Conversation.setTitle(title)
            }
        case "registerVisitor":
            if let id = argument as? String {
                ZohoSalesIQ.registerVisitor(id) { status in
                    if status {
                        result(nil)
                    } else {
                        result(self.getErrorMessage("Failed to register visitor"))
                    }
                }
            }
        case "unregisterVisitor":
            ZohoSalesIQ.unregisterVisitor { status in
                if status {
                    result(nil)
                } else {
                    result(self.getErrorMessage("Failed to unregister visitor"))
                }
            }
        case "setPageTitle":
            if let pageTitle = argument as? String {
                ZohoSalesIQ.Tracking.setPageTitle(pageTitle)
            }
        case "performCustomAction":
            if let args = call.argumentDictionary, let action = args["action_name"] as? String {
                ZohoSalesIQ.Visitor.performCustomAction(action, shouldOpenChatWindow: false)
            }
        case "enableInAppNotification":
            if let enabled = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.inAppNotifications, visible: enabled)
            }
        case "setOperatorEmail":
            if let operatorEmail = argument as? String {
                ZohoSalesIQ.Chat.setAgentEmail(operatorEmail)
            }
        case "show":
            ZohoSalesIQ.Chat.show()
        case "openNewChat":
            ZohoSalesIQ.Chat.show(new: true)
        case "showOfflineMessage":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.showOfflineMessage(show)
            }
        case "end":
            if let id = argument as? String {
                ZohoSalesIQ.Chat.endSession(referenceID: id)
            }
        case "setVisitorName":
            if let name = argument as? String {
                ZohoSalesIQ.Visitor.setName(name)
            }
        case "setVisitorEmail":
            if let email = argument as? String {
                ZohoSalesIQ.Visitor.setEmail(email)
            }
        case "setVisitorContactNumber":
            if let phone = argument as? String {
                ZohoSalesIQ.Visitor.setContactNumber(phone)
            }
        case "setVisitorAddInfo":
            if let args = call.argumentDictionary, let key = args["key"] as? String, let value = args["value"] as? String {
                ZohoSalesIQ.Visitor.addInfo(key, value: value)
            }
        case "setVisitorLocation":
            if let args = argument as? [String: AnyObject] {
                ZohoSalesIQ.Visitor.setLocation(getVisitorLocation(using: args))
            }
        case "setChatTitle":
            if let title = argument as? String {
                ZohoSalesIQ.Chat.setTitle(title)
            }
        case "showOperatorImageInLauncher":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.attenderImageOnLauncher, visible: show)
            }
        case "showOperatorImageInChat":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.attenderImageInChat, visible: show)
            }
        case "setVisitorNameVisibility":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.visitorName, visible: show)
            }
        case "setFeedbackVisibility":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.feedback, visible: show)
            }
        case "setRatingVisibility":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.setVisibility(.rating, visible: show)
            }
        case "enableScreenshotOption":
            ZohoSalesIQ.Chat.setVisibility(.screenshotOption, visible: true)
        case "disableScreenshotOption":
            ZohoSalesIQ.Chat.setVisibility(.screenshotOption, visible: false)
        case "enablePreChatForms":
            ZohoSalesIQ.Chat.setVisibility(.preChatForm, visible: true)
        case "disablePreChatForms":
            ZohoSalesIQ.Chat.setVisibility(.preChatForm, visible: false)
        case "setThemeColorForiOS":
            if let colorCode = argument as? String, let themeColor = UIColor(hex: colorCode) {
                let theme = ZohoSalesIQ.Theme.baseTheme
                theme.themeColor = themeColor
                ZohoSalesIQ.Theme.setTheme(theme: theme)
            }
        case "setThemeColor":
            if let colors = call.argumentDictionary {
                ZohoSalesIQ.Theme.setTheme(theme: SIQTheme(colors: colors))
            }
        case "getChats", "getChatsWithFilter":
            var status: ChatStatus = .all
            if let stringFilterValue = argument as? String {
                status = ChatStatus.statusFromString(stringFilterValue)
            }
            ZohoSalesIQ.Chat.getList(filter: status) { error, chats in
                guard error == nil else {
                    result(self.getError(error: error))
                    return
                }
                guard let chatObjects = chats else {
                    result([])
                    return
                }
                let list = self.getChatObjectList(chatObjects)
                result(list)
            }
        case "getDepartments":
            ZohoSalesIQ.Chat.getDepartments { error, departments in
                guard error == nil else {
                    result(self.getError(error: error))
                    return
                }
                guard let departmentObjects = departments else {
                    result([])
                    return
                }
                let list = self.getDepartmentObjectList(departmentObjects)
                result(list)
            }
        case "fetchAttenderImage":
            if let emptyChat = SwiftMobilistenPlugin.emptyChatInstance {
                let chat = emptyChat
                if let args = call.argumentDictionary, let attenderID = args["attenderID"] as? String {
                    chat.attenderID = attenderID
                    var fetchDefaultImage: Bool = false
                    if let fetchDefault = args["fetchDefaultImage"] as? Bool {
                        fetchDefaultImage = fetchDefault
                    }
                    ZohoSalesIQ.Chat.fetchAttenderImage(chat: chat, fetchDefaultImage: fetchDefaultImage) { error, image in
                        guard error == nil else {
                            result(self.getError(error: error))
                            return
                        }
                        guard let attenderImage = image, let base64String = attenderImage.toBase64String(compressionQuality: 0.5) else {
                            result(self.getErrorMessage("Failed to fetch attender image", code: ErrorCode.fetchAttenderImageFailed))
                            return
                        }
                        result(base64String)
                    }
                } else {
                    result(self.getErrorMessage("Failed to fetch attender image", code: ErrorCode.fetchAttenderImageFailed))
                }
            } else {
                result(self.getErrorMessage("Failed to fetch attender image", code: ErrorCode.fetchAttenderImageFailed))
            }
        case "registerChatAction":
            if let name = argument as? String {
                let uuid = UUID().uuidString
                let action = SIQChatAction(name: name) { arguments, handler in
                    let arg = self.getChatActionArgument(arguments, actionName: name, UUID: uuid)
                    self.chatActionStore[uuid] = handler
                    self.sendChatEvent(name: .performChatAction, dataLabel: "chatAction", data: arg)
                }
                ZohoSalesIQ.ChatActions.register(action: action)
            } else {
                result(self.getErrorMessage("Failed to register chat action"))
            }
        case "unregisterChatAction":
            if let name = argument as? String {
                ZohoSalesIQ.ChatActions.unregisterWithName(name: name)
            } else {
                result(self.getErrorMessage("Failed to unregister chat action"))
            }
        case "unregisterAllChatActions":
            ZohoSalesIQ.ChatActions.unregisterAll()
        case "setChatActionTimeout":
            if let time = argument as? Int {
                ZohoSalesIQ.ChatActions.setTimeout(Double(time))
            } else {
                result(self.getErrorMessage("Failed to set chat action timeout"))
            }
        case "completeChatAction":
            if let uuid = argument as? String, let handler = chatActionStore[uuid] {
                handler.success()
                chatActionStore.removeValue(forKey: uuid)
            } else {
                result(self.getErrorMessage("Failed to complete chat action"))
            }
        case "completeChatActionWithMessage":
            if let args = argument as? [String: Any], let uuid = args["actionUUID"] as? String, let success = args["state"] as? Bool, let message = (args["message"] as? String)?.trimSpace(), let handler = chatActionStore[uuid] {
                let msg: String? = message.isEmpty ? nil : message
                if success {
                    handler.success(message: msg)
                } else {
                    handler.faliure(message: msg)
                }
                chatActionStore.removeValue(forKey: uuid)
            } else {
                result(self.getErrorMessage("Failed to complete chat action"))
            }
        case "isMultipleOpenChatRestricted":
            result(ZohoSalesIQ.Chat.multipleOpenRestricted)
        case "getChatUnreadCount":
            result(ZohoSalesIQ.Chat.getUnreadMessageCount())
        case "enablePushForiOS":
            if let args = argument as? [String: Any], let token = args["token"] as? String, let isTestDevice = args["isTestDevice"] as? Bool, let productionMode = args["productionMode"] as? Bool {
                let apnsMode: APNSMode = productionMode ? .production : .sandbox
                ZohoSalesIQ.enablePush(token, isTestDevice: isTestDevice, mode: apnsMode)
            } else {
                result(self.getErrorMessage("Failed to enable push notifications"))
            }
        case "handleNotificationResponseForiOS":
            if let userInfo = argument as? [AnyHashable: Any] {
                ZohoSalesIQ.handleNotificationResponse(userInfo)
            } else {
                result(self.getErrorMessage("Failed to handle Notification Response for iOS"))
            }
        case "processNotificationWithInfoForiOS":
            if let userInfo = argument as? [AnyHashable: Any] {
                ZohoSalesIQ.processNotificationWithInfo(userInfo)
            } else {
                result(self.getErrorMessage("Failed to process Notification Response for iOS"))
            }
        case "shouldOpenUrl":
            if let allow = argument as? Bool {
                handleURL = allow
            }
        case "setLoggerEnabled":
            if let enable = argument as? Bool {
                ZohoSalesIQ.Logger.setEnabled(enable)
            }
        case "isLoggerEnabled":
            result(ZohoSalesIQ.Logger.isEnabled)
        case "clearLogsForiOS":
            ZohoSalesIQ.Logger.clear()
        case "writeLogForiOS":
            if let args = call.argumentDictionary, let log = args["log"] as? String, let level = args["level"] as? String {
                var logLevel: SIQDebugLogLevel = .info
                if level == "INFO" {
                    logLevel = .info
                } else if level == "WARNING" {
                    logLevel = .warning
                } else if level == "ERROR" {
                    logLevel = .error
                }
                ZohoSalesIQ.Logger.write(
                    log, logLevel: logLevel, file: nil, line: nil, function: nil, fileID: nil, filePath: nil, column: nil,
                    success: { (success) in
                        if success {
                            result(nil)
                        } else {
                            result(self.getErrorMessage("Failed to write logs"))
                        }
                    })
            }
        case "sendEvent":
            if let args = call.argumentDictionary, let eventName = args["eventName"] as? String, let values = args["values"] as? [AnyObject] {
                var logLevel: SIQDebugLogLevel = .info
                logLevel = .error
                ZohoSalesIQ.Logger.write(
                    "performChatAction", logLevel: logLevel,
                    success: { (success) in

                    })
                if eventName == "OPEN_URL" {
                    for value in values {
                        if let stringURL = value as? String, let url = URL(string: stringURL) {
                            ZohoSalesIQ.openURL(url)
                            break
                        }
                    }
                } else if eventName == "COMPLETE_CHAT_ACTION" {
                    var uuid: String?
                    var success = false
                    var message: String?
                    for index in 0..<values.count {
                        switch index {
                        case 0:
                            if let id = values[index] as? String {
                                uuid = id
                            }
                        case 1:
                            if let complete = values[index] as? Bool {
                                success = complete
                            }
                        case 2:
                            if let msg = values[index] as? String {
                                message = msg
                            }
                        default:
                            break
                        }
                    }
                    if let uniqueID = uuid, let handler = chatActionStore[uniqueID] {
                        if message == nil {
                            handler.success()
                        } else {
                            if success {
                                handler.success(message: message)
                            } else {
                                handler.faliure(message: message)
                            }
                        }
                        chatActionStore.removeValue(forKey: uniqueID)
                    } else {
                        result(self.getErrorMessage("Failed chat action event"))
                    }
                }
            }
        case "setPathForiOS":
            if let path = argument as? String {
                let pathURL = NSURL.fileURL(withPath: path)
                ZohoSalesIQ.Logger.setPath(pathURL)
            }
        case "dismissUI":
            ZohoSalesIQ.dismissUI()
        case "setSessionID":
            if let sessionID = argument as? String {
                ZohoSalesIQ.Chat.setUserSessionID(sessionID)
            }
        case "registerLocalizationFileForiOS":
            if let fileName = argument as? String {
                ZohoSalesIQ.registerLocalizationFile(with: fileName)
            }
        case "getCommunicationMode":
            let communicationMode = ZohoSalesIQ.getCommunicationMode

            switch communicationMode {
            case .chat:
                result("chat")
            case .call:
                result("call")
            case .chatAndCall:
                result("chatAndCall")
            case .none:
                result(nil)
            @unknown default:
                result(nil)
            }
        case "handlePushNotificationAction":
            if let args = call.argumentDictionary {
                Task { @MainActor in
                    guard let userInfo = args["userInfo"] as? [AnyHashable: Any] else {
                        result(self.getErrorMessage("invalid user info"))
                        return
                    }
                    let actionIdentifier = args["actionIdentifier"] as? String
                    let responseText = args["responseText"] as? String
                    ZohoSalesIQ.handlePushNotificationAction(actionIdentifier: actionIdentifier, userInfo: userInfo, responseText: responseText) {
                        result(nil)
                    }
                }
            }
        case "refreshLauncher":
            ZohoSalesIQ.refreshLauncher()
        case "refreshData":
            if let args = call.argumentDictionary,
                let type = args["type"] as? String,
                let conversationId = args["conversationId"] as? String,
                !conversationId.isEmpty
            {
                refreshData(type: type, conversationId: conversationId, result: result)
            } else {
                result(self.getErrorMessage("Failed to refresh provider data"))
            }
        case "updateConfiguration":
            if let args = call.argumentDictionary, let key = args["key"] as? String, let rawValue = args["value"] {
                guard let flag = getFlag(key) else { return }
                var value = rawValue
                // Android's EnableHomePageBackStackForChatInitiation is the inverse of iOS's
                // dontNeedHomePageInStartFlow, so invert the boolean for this flag to keep the
                // public API consistent across platforms.
                if key == "EnableHomePageBackStackForChatInitiation", let enabled = rawValue as? Bool {
                    value = !enabled
                }
                ZohoSalesIQ.updateConfigurationFlag(flag, value: value)
            }
        case "presentScreen":
            if let args = call.argumentDictionary, let screenMap = args["screen"] as? [String: Any] {
                let showHomepage = args["showHomepage"] as? Bool ?? true
                guard let screen = getScreen(from: screenMap) else {
                    result(self.getErrorMessage("Unknown screenType", code: ErrorCode.unknownScreenType))
                    return
                }
                ZohoSalesIQ.present(screen, showHomepage: showHomepage) { error, success in
                    if let error = error {
                        result(self.getResourceError(error: error))
                    } else {
                        result(success)
                    }
                }
            } else {
                ZohoSalesIQ.present { error, success in
                    if let error = error {
                        result(self.getResourceError(error: error))
                    } else {
                        result(success)
                    }
                }
            }
        case "setThemeSource":
            // Android only: the iOS native SDK does not expose a theme source API.
            break
        case "reRegisterPush":
            ZohoSalesIQ.reregisterPushNotification()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }

    }

    private func getVisitorProfile(from profileMap: [String: Any]) -> SalesIQVisitorProfile {
        let profile = SalesIQVisitorProfile()
        profile.salutation = profileMap["salutation"] as? String
        profile.firstName = profileMap["firstName"] as? String
        profile.lastName = profileMap["lastName"] as? String
        profile.emailID = profileMap["email"] as? String
        profile.userID = profileMap["userID"] as? String

        if let phoneMap = profileMap["phone"] as? [String: Any] {
            let contact = SIQVisitorContact()
            contact.code = phoneMap["code"] as? String
            contact.number = phoneMap["number"] as? String
            profile.phone = contact
        }

        if let customInfo = profileMap["customInfo"] as? [String: String] {
            profile.customInfo = customInfo
        }

        if let locationMap = profileMap["location"] as? [String: Any] {
            let location = SIQVisitorLocation()
            location.countryCode = locationMap["countryCode"] as? String
            location.latitude = locationMap["latitude"] as? NSNumber
            location.longitude = locationMap["longitude"] as? NSNumber
            location.city = locationMap["city"] as? String
            location.zipCode = locationMap["zipCode"] as? String
            location.state = locationMap["state"] as? String
            location.country = locationMap["country"] as? String
            profile.location = location
        }

        return profile
    }

    private func getHomepageWidget(_ widget: String) -> SIQWidget? {
        switch widget {
        case "chat": return .chat
        case "call": return .call
        case "articles": return .articles
        case "previousConversations": return .previousConversation
        case "imageCard": return .imageCard
        case "videoCard": return .videoCard
        default: return nil
        }
    }

    private func getConversationFilter(_ filter: String?) -> ZSIQConversationFilter {
        switch filter {
        case "ongoing": return .ongoing
        case "ended": return .ended
        default: return .all
        }
    }

    private func getConversationList(_ map: [String: Any]?) -> ZSIQConversationList {
        guard let map = map else { return .all() }
        let filter = getConversationFilter(map["filter"] as? String)
        switch map["type"] as? String {
        case "chat": return .chat(filter)
        case "call": return .call(filter)
        case "none": return .none(filter)
        default: return .all(filter)
        }
    }

    private func getSessionType(_ type: String?) -> ZSIQSessionType? {
        switch type {
        case "chat": return .chat
        case "call": return .call
        default: return nil
        }
    }

    private func getSessionBehavior(_ map: [String: Any]?) -> ZSIQSessionBehavior {
        guard let map = map else { return .none }
        let sessionType = getSessionType(map["sessionType"] as? String) ?? .chat
        switch map["type"] as? String {
        case "alwaysNew": return .alwaysNew(sessionType)
        case "continueOrNew": return .continueOrNew(sessionType)
        default: return .none
        }
    }

    private func getScreen(from screenMap: [String: Any]) -> ZSIQScreen? {
        switch screenMap["screenType"] as? String {
        case "conversation":
            let list = getConversationList(screenMap["list"] as? [String: Any])
            if let id = screenMap["id"] as? String, !id.isEmpty {
                let sessionType = getSessionType(screenMap["sessionType"] as? String) ?? .chat
                return ZSIQConversation(id: id, sessionType: sessionType, list: list)
            }
            let sessionBehavior = getSessionBehavior(screenMap["sessionBehavior"] as? [String: Any])
            return ZSIQConversation(list: list, sessionBehavior: sessionBehavior)
        case "knowledgeBase":
            return ZSIQKnowledgeBase(type: .articles, id: screenMap["id"] as? String)
        default:
            return nil
        }
    }

    private func getFlag(_ key: String) -> MobilistenFlag? {
        switch key {
        case "NeutralRatingDisabled":
            return .neutralRatingDisabled
        case "TrackStorageSpace":
            return .trackStorageSpace
        case "TrackAppInstalledTime":
            return .trackAppInstalledTime
        case "TrackAppUpdatedTime":
            return .trackAppUpdatedTime
        case "ShowEndSessionInInAppNotification":
            return .showEndSessionInAppNotification
        case "ChatBotCarousalCardPropertiesOrientation":
            return .inputCarouselCardOrientation
        case "ChatBotCarousalCardImageVisibility":
            return .showInputCarouselCardImage
        case "ChatFallbackDepartmentsOnReopenIfOffline":
            return .fallbackDepartmentsOnReopenIfOffline
        case "HideCreditCardMaskingConsentAlert":
            return .hideCreditCardMaskingConsentAlert
        case "IncludeVisitorInfoInConversationInfo":
            return .includeVisitorInfoInDisplayFields
        case "SecretFieldsProviderTimeout":
            return .getSecretFieldsTimeout
        case "DisplayFieldsProviderTimeout":
            return .getDisplayFieldsTimeout
        case "EnableHomePageBackStackForChatInitiation":
            return .dontNeedHomePageInStartFlow
        default:
            print("Unsupported flag: \(key)")
        }
        return nil
    }

    private func refreshData(type: String, conversationId: String, result: @escaping FlutterResult) {
        let data: SalesIQData
        switch type {
        case "secretFields":
            data = .secretFields(conversationId)
        case "displayFields":
            data = .displayFields(conversationId)
        default:
            result(getErrorMessage("Failed to refresh provider data"))
            return
        }

        ZohoSalesIQ.refreshData(data) { [weak self] error in
            if let error {
                result(self?.getError(error: error))
            } else {
                result(nil)
            }
        }
    }

    private func createEvent(name: MobilistenEvent, dataLabel: String = "data", data: Any? = nil, error: Any? = nil) -> [String: Any]? {
        guard name.enabled else { return nil }
        var event: [String: Any] = [:]
        event[MobilistenEvent.nameKey] = name.rawValue
        event[dataLabel] = data
        if let error {
            event[MobilistenEvent.errorKey] = error
        }
        return formEventData(name: name, dataLabel: dataLabel, event: event)
    }

    private func formEventData(name: MobilistenEvent, dataLabel: String, event: [String: Any]) -> [String: Any]? {
        switch name.rawValue {
        case "handleURL":
            var eventData = event
            if var chat = (eventData["chat"] as? [String: Any]) {
                let url = chat.removeValue(forKey: "url")
                eventData["url"] = url
                eventData[dataLabel] = chat
            }
            return eventData
        default:
            return event
        }
        return event
    }

    public static func setFlag(name: MobilistenPluginFlag, value: Bool) {
        mobilistenPluginFlags[name] = value
    }

    public static func checkFlag(name: MobilistenPluginFlag) -> Bool {
        return mobilistenPluginFlags[name] ?? false
    }

    private func sendCustomTriggerEvent(triggerName: String, visitor: SIQVisitor) {
        let eventType = MobilistenEvent.customTrigger
        guard eventType.enabled else { return }
        var event = getCustomTriggerObject(triggerName: triggerName, visitor: visitor)
        event[MobilistenEvent.nameKey] = eventType.rawValue
        eventSink?(event)
    }

    private func sendEvent(name: MobilistenEvent, dataLabel: String = "data", data: Any? = nil) {
        guard let event = createEvent(name: name, dataLabel: dataLabel, data: data) else { return }
        eventSink?(event)
    }

    private func sendChatEvent(name: MobilistenEvent, dataLabel: String = "chat", data: Any? = nil, error: Any? = nil) {
        guard let event = createEvent(name: name, dataLabel: dataLabel, data: data, error: error) else { return }
        chatEventSink?(event)
    }

    private func sendResourceEvent(name: MobilistenEvent, dataLabel: String = "resource", data: Any? = nil, error: Any? = nil) {
        if name.enabled {
            var event: [String: Any] = [:]
            event[MobilistenEvent.nameKey] = name.rawValue
            if let data = data as? [String: Any] {
                event["type"] = data["type"] as? Int
                event["resource"] = data["resource"]
            }
            if let error {
                event[MobilistenEvent.errorKey] = error
            }
            resourceEventSink?(event)
        } else {
            resourceEventSink?(nil)
        }
    }


    class KnowledgeBasePlugin: NSObject, FlutterPlugin {
        static func register(with registrar: FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            var argument: Any? {
                return call.arguments
            }

            switch call.method {
            case "setVisibility":
                if let args = call.argumentDictionary, let type = args["type"] as? Int, let enable = args["should_show"] as? Bool {
                    switch type {
                    case 0:
                        ZohoSalesIQ.KnowledgeBase.setVisibility(.articles, enable: enable)
                    default: break
                    }
                }
            case "combineDepartments":
                if let args = call.argumentDictionary, let type = args["type"] as? Int, let enable = args["merge"] as? Bool {
                    switch type {
                    case 0:
                        ZohoSalesIQ.KnowledgeBase.combineDepartments(.articles, enable: enable)
                    default: break
                    }
                }
            case "categorize":
                if let args = call.argumentDictionary, let type = args["type"] as? Int, let enable = args["should_categorize"] as? Bool {
                    switch type {
                    case 0:
                        ZohoSalesIQ.KnowledgeBase.categorize(.articles, enable: enable)
                    default: break
                    }
                }
            case "isEnabled":
                if let args = call.argumentDictionary, let type = args["type"] as? Int {
                    if SIQResourceType(rawValue: type) == .articles {
                        result(ZohoSalesIQ.KnowledgeBase.isEnabled(.articles))
                    } else {
                        result(SwiftMobilistenPlugin().getErrorMessage("The FAQs resource type is not supported on this iOS SDK version.", code: ErrorCode.invalidResourceType))
                    }
                }
            case "setRecentlyViewedCount":
                if let limit = argument as? Int {
                    ZohoSalesIQ.KnowledgeBase.setRecentShowLimit(limit)
                }
            case "openResource":
                if let args = call.argumentDictionary, let type = args["type"] as? Int, let id = args["id"] as? String {
                    switch type {
                    case 0:
                        ZohoSalesIQ.KnowledgeBase.open(.articles, id: id, completion: { success, error in
                            if error != nil {
                                result(SwiftMobilistenPlugin().getResourceError(error:error))
                            } else {
                                result(success)
                            }
                        })
                    default: result(SwiftMobilistenPlugin().getErrorMessage("The FAQs resource type is not supported on this iOS SDK version.", code: ErrorCode.invalidResourceType))
                    }
                } else {
                    result(SwiftMobilistenPlugin().getErrorMessage("Failed to open article"))
                }
            case "getSingleResource":
                if let args = call.argumentDictionary, let type = args["type"] as? Int, let id = args["id"] as? String {
                    switch type {
                    case 0:
                        ZohoSalesIQ.KnowledgeBase.getSingleResource(
                            .articles, id: id,
                            completion: { success, error, resource in
                                guard error == nil else {
                                    result(SwiftMobilistenPlugin().getResourceError(error: error))
                                    return
                                }
                                guard let resourceObjects = resource else {
                                    result(nil)
                                    return
                                }
                                let article = SwiftMobilistenPlugin().getResourceObject(resourceObjects)
                                result(article)
                            })
                    default: result(SwiftMobilistenPlugin().getErrorMessage("The FAQs resource type is not supported on this iOS SDK version.", code: ErrorCode.invalidResourceType))
                    }
                } else {
                    result(SwiftMobilistenPlugin().getErrorMessage("Failed to get single article"))
                }
            case "getResources":
                if let args = call.argumentDictionary, let type = args["type"] as? Int {
                    switch type {
                    case 0:
                        let departmentID = args["departmentId"] as? String ?? nil
                        let parentCategoryId = args["parentCategoryId"] as? String ?? nil
                        let searchKey = args["searchKey"] as? String ?? nil
                        let page = args["page"] as? Int ?? 1
                        let limit = args["limit"] as? Int ?? 99

                        ZohoSalesIQ.KnowledgeBase.getResources(.articles, departmentId: departmentID, parentCategoryId: parentCategoryId, searchKey: searchKey, page: page, limit: limit) { success, error, resources, moreDataAvailable in
                            guard error == nil else {
                                result(SwiftMobilistenPlugin().getResourceError(error: error))
                                return
                            }
                            guard let resources = resources else {
                                result(nil)
                                return
                            }
                            let resourceList = SwiftMobilistenPlugin().getResourceList(resources)
                            var resourceObject: [String: Any] = [:]
                            resourceObject["resources"] = resourceList
                            resourceObject["more_data_available"] = moreDataAvailable
                            result(resourceObject)
                        }
                    default: result(SwiftMobilistenPlugin().getErrorMessage("The FAQs resource type is not supported on this iOS SDK version.", code: ErrorCode.invalidResourceType))
                    }
                } else {
                    result(SwiftMobilistenPlugin().getErrorMessage("Failed to get resource"))
                }
            case "getCategories":
                if let args = call.argumentDictionary, let type = args["type"] as? Int {
                    switch type {
                    case 0:
                        let departmentID = args["departmentId"] as? String ?? nil
                        let parentCategoryId = args["parentCategoryId"] as? String ?? nil

                        ZohoSalesIQ.KnowledgeBase.getCategories(.articles, departmentId: departmentID, parentCategoryId: parentCategoryId) { success, error, resourceCategories in
                            guard error == nil else {
                                result(SwiftMobilistenPlugin().getResourceError(error: error))
                                return
                            }
                            guard let categoryObjects = resourceCategories else {
                                result(nil)
                                return
                            }
                            let article = SwiftMobilistenPlugin().getResourceCategoryList(categoryObjects)
                            result(article)
                        }
                    default: result(SwiftMobilistenPlugin().getErrorMessage("The FAQs resource type is not supported on this iOS SDK version.", code: ErrorCode.invalidResourceType))
                    }
                } else {
                    result(SwiftMobilistenPlugin().getErrorMessage("Failed to get categories"))
                }
            case "getResourceDepartments":
                ZohoSalesIQ.KnowledgeBase.getResourceDepartments(completion: { error, departments in
                    if let departments = departments {
                        var list: [[String: Any]] = []
                        for department in departments {
                            var deparmentDictionary: [String: Any] = [:]
                            deparmentDictionary["id"] = department.id
                            deparmentDictionary["name"] = department.name
                            list.append(deparmentDictionary)
                        }
                        result(list)
                    } else {
                        result(SwiftMobilistenPlugin().getResourceError(error: error))
                    }
                })
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    class ConversationPlugin: NSObject, FlutterPlugin, ZohoSalesIQConversationDelegate {
        private static var conversationChannel: FlutterMethodChannel?
        private var isSecretFieldsEnabled = false
        private var isDisplayFieldsEnabled = false

        init(channel: FlutterMethodChannel) {
            Self.conversationChannel = channel
        }

        override init() {
            super.init()
        }

        static func register(with registrar: any FlutterPluginRegistrar) {
            conversationChannel = MobilistenChannel.conversationModule.createMethodChannel(registrar: registrar)
        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            var argument: Any? {
                return call.arguments
            }
            switch call.method {
            case "fetchDepartments":
                ZohoSalesIQ.Conversation.getDepartments { [self] error, departments in
                    if let error = error {
                        result(FlutterError(code: "\(error.code)", message: error.message, details: nil))
                    } else {
                        result(getDepartmentList(departments))
                    }
                }
            case "setAttribute":
                if let args = call.argumentDictionary {
                    if let departments = args["departments"] as? [[String: Any]], !departments.isEmpty {
                        var departmentList: [SIQDepartment] = []
                        departments.forEach { department in
                            if let mode = department["communicationMode"] as? String, let siqMode = getCommunicationMode(mode) {
                                let id = department["id"] as? String
                                let name = department["name"] as? String
                                departmentList.append(SIQDepartment(id: id, name: name, mode: siqMode))
                            }
                        }
                        ZohoSalesIQ.Conversation.setDepartment(departmentList)
                    }
                    if let additionalInfo = args["additionalInfo"] as? String {
                        ZohoSalesIQ.Conversation.setAdditionalInfo(additionalInfo)
                    }
                    if let name = args["name"] as? String {
                        ZohoSalesIQ.Conversation.setName(name)
                    }
                    if let displayPicture = args["displayPicture"] as? String {
                        ZohoSalesIQ.Conversation.setDisplayPicture(displayPicture)
                    }
                }
            case "setVisibility":
                if let show = argument as? Bool {
                    ZohoSalesIQ.Conversation.setVisibility(show)
                }
            case "setDataProvider":
                if let args = call.argumentDictionary {
                    isSecretFieldsEnabled = args["secretFieldsEnabled"] as? Bool ?? false
                    isDisplayFieldsEnabled = args["customInfoEnabled"] as? Bool ?? false
                } else {
                    isSecretFieldsEnabled = false
                    isDisplayFieldsEnabled = false
                }

                if isSecretFieldsEnabled || isDisplayFieldsEnabled {
                    ZohoSalesIQ.Conversation.delegate = self
                } else {
                    ZohoSalesIQ.Conversation.delegate = nil
                }
                result(nil)
            default:
                // Any other members promoted from the flat `ZohoSalesIQ` surface
                // are handled by the main plugin; forward to it so the Dart
                // module can use its own channel.
                if let shared = SwiftMobilistenPlugin.sharedInstance {
                    shared.handle(call, result: result)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        func getSecretFields(chat: SIQVisitorChat?, completion: @escaping ([String: Any]) -> Void) -> [String: Any]? {
            if !isSecretFieldsEnabled {
                return nil
            }
            invokeDataProviderMethod(method: "onSecretFieldsRequested", chat: chat, completion: completion)
            return nil
        }

        func getDisplayFields(chat: SIQVisitorChat?, completion: @escaping ([String: Any]) -> Void) -> [String: Any]? {
            if !isDisplayFieldsEnabled {
                return nil
            }
            invokeDataProviderMethod(method: "onDisplayFieldsRequested", chat: chat, completion: completion)
            return nil
        }

        private func invokeDataProviderMethod(method: String, chat: SIQVisitorChat?, completion: @escaping ([String: Any]) -> Void) {
            guard let channel = Self.conversationChannel else {
                completion([:])
                return
            }

            var args: [String: Any] = [:]
            var conversationMap: [String: Any] = ["type": "chat"]
            if let chat = chat {
                if let shared = SwiftMobilistenPlugin.sharedInstance {
                    conversationMap.merge(shared.getChatObject(chat)) { _, new in new }
                }
            }
            args["conversation"] = conversationMap

            DispatchQueue.main.async {
                channel.invokeMethod(method, arguments: args) { result in
                    completion(self.getStringAnyMapOrEmpty(result))
                }
            }
        }

        private func getStringAnyMapOrEmpty(_ value: Any?) -> [String: Any] {
            guard let map = value as? [AnyHashable: Any] else {
                return [:]
            }
            var output: [String: Any] = [:]
            map.forEach { key, value in
                output[String(describing: key)] = value
            }
            return output
        }

        func getDepartmentList(_ list: [SIQDepartment]) -> [[String: Any]] {
            var departmentList: [[String: Any]] = []
            list.forEach { department in
                var mode: String {
                    switch department.mode {
                    case .chat:
                        return "chat"
                    case .call:
                        return "call"
                    case .chatAndCall:
                        return "chatAndCall"
                    case .none:
                        return "none"
                    @unknown default:
                        return "none"
                    }
                }
                let departmentDict = ["id": department.id, "name": department.name, "available": department.available, "communicationMode": mode]
                departmentList.append(departmentDict)
            }
            return departmentList
        }

        // Resolves the native enum name ("CHAT" / "CALL" / "CHAT_AND_CALL")
        // sent from Dart into a SIQCommunicationMode. Mirrors Android and the
        // React Native wrapper so the mode deserializes consistently.
        func getCommunicationMode(_ mode: String?) -> SIQCommunicationMode? {
            switch mode {
            case "CHAT":
                return .chat
            case "CALL":
                return .call
            case "CHAT_AND_CALL":
                return .chatAndCall
            default:
                return nil
            }
        }

    }

    class LauncherPlugin: NSObject, FlutterPlugin {
        static func register(with registrar: FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            var argument: Any? {
                return call.arguments
            }

            switch call.method {
            case "show":
                if let args = call.argumentDictionary, let type = args["visibility_mode"] as? Int {
                    switch type {
                    case 0:
                        ZohoSalesIQ.Launcher.show(.always)
                    case 1:
                        ZohoSalesIQ.Launcher.show(.never)
                    case 2:
                        ZohoSalesIQ.Launcher.show(.whenActiveChat)
                    default: break
                    }
                }
            case "setVisibilityModeToCustomLauncher":
                if let args = call.argumentDictionary, let type = args["visibility_mode"] as? Int {
                    switch type {
                    case 0:
                        ZohoSalesIQ.Launcher.setVisibilityModeToCustomLauncher(.always)
                    case 1:
                        ZohoSalesIQ.Launcher.setVisibilityModeToCustomLauncher(.never)
                    case 2:
                        ZohoSalesIQ.Launcher.setVisibilityModeToCustomLauncher(.whenActiveChat)
                    default: break
                    }
                }
            case "enableDragToDismiss":
                if let enable = argument as? Bool {
                    ZohoSalesIQ.Launcher.enableDragToDismiss(enable)
                }
            case "setMinimumPressDuration":
                if let duration = argument as? Int {
                    ZohoSalesIQ.Launcher.minimumPressDuration(Double(duration))
                }
            case "refresh":
                ZohoSalesIQ.refreshLauncher()
            case "showOperatorImage":
                if let show = argument as? Bool {
                    ZohoSalesIQ.Chat.setVisibility(.attenderImageOnLauncher, visible: show)
                }
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    class NotificationPlugin: NSObject, FlutterPlugin {
        static func register(with registrar: FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            var argument: Any? {
                return call.arguments
            }

            switch call.method {
            case "registerPush":
                if let args = call.argumentDictionary, let token = args["token"] as? String, let isTestDevice = args["isTestDevice"] as? Bool {
                    let mode: APNSMode = isTestDevice ? .sandbox : .production
                    ZohoSalesIQ.enablePush(token, isTestDevice: isTestDevice, mode: mode)
                }
            case "isSDKMessage":
                if let userInfo = argument as? [AnyHashable: Any] {
                    result(ZohoSalesIQ.isMobilistenNotification(userInfo))
                } else {
                    result(SwiftMobilistenPlugin().getErrorMessage("Failed to process isSDKMessage Response for iOS"))
                }
            case "disablePush":
                // Android only: FCM token invalidation. On iOS, push registration is managed
                // through APNS via ZohoSalesIQ.enablePush. Complete the result so the Dart
                // Future<void> doesn't hang (parity with Android's result.success(null)).
                result(nil)
            case "setNotificationActionSource":
                if let type = argument as? String {
                    ZohoSalesIQ.Notification.setAction(with: type == "app" ? .app : .sdk)
                }
            case "getNotificationPayload":
                if let userInfo = argument as? [AnyHashable: Any] {
                    NotificationPlugin().getPayloadObject(userInfo: userInfo, completionhandler: { payload in
                        result(payload)
                    })
                }
            case "getBadgeCount":
                // iOS does not expose a distinct badge-count API;
                // the unread message count is the badge-count equivalent.
                result(ZohoSalesIQ.Chat.getUnreadMessageCount())
            default:
                // Members promoted from the flat `ZohoSalesIQ` surface (e.g.
                // `enableInAppNotification`) are handled by the main plugin;
                // forward to it so the Dart module can use its own channel.
                if let shared = SwiftMobilistenPlugin.sharedInstance {
                    shared.handle(call, result: result)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        func getPayloadObject(userInfo: [AnyHashable: Any], completionhandler: @escaping (_ payload: [String: Any]?) -> Void) {
            ZohoSalesIQ.Notification.getPayload(userInfo, completion: { payload in
                let payloadObject: [String: Any] = NotificationPlugin().getPayloadObjectEventDictionary(payload)
                completionhandler(payloadObject)
            })
        }

        func getPayloadObjectEventDictionary(_ payload: SalesIQNotificationPayload?) -> [String: Any] {
            var payloadObject: [String: Any] = [:]
            if let chatPayload = payload as? SalesIQChatNotificationPayload {
                payloadObject["type"] = "chat"
                payloadObject["payload"] = chatPayload.toDictionary()
            } else if let endChatPayload = payload as? SalesIQEndChatNotificationPayload {
                payloadObject["type"] = "endChatDetails"
                payloadObject["payload"] = endChatPayload.toDictionary()
            } else if let visitorHistoryPayload = payload as? SalesIQVisitorHistoryNotificationPayload {
                payloadObject["type"] = "visitorHistory"
                payloadObject["payload"] = visitorHistoryPayload.toDictionary()
            }
            return payloadObject
        }
    }

    class VisitorPlugin: NSObject, FlutterPlugin {
        static func register(with registrar: any FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            guard let shared = SwiftMobilistenPlugin.sharedInstance else {
                result(FlutterMethodNotImplemented)
                return
            }
            // performCustomAction is promoted to the flat `ZohoSalesIQ` facade (implemented in
            // the main handle); updateVisitorProfile is module-only and handled by the dedicated
            // visitor handler.
            if call.method == "performCustomAction" {
                shared.handle(call, result: result)
            } else {
                shared.handleVisitorMethodCall(call, result: result)
            }
        }
    }

    class HomepagePlugin: NSObject, FlutterPlugin {
        static func register(with registrar: any FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            // Homepage methods are all module-only.
            if let shared = SwiftMobilistenPlugin.sharedInstance {
                shared.handleHomepageMethodCall(call, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    class TrackingPlugin: NSObject, FlutterPlugin {
        static func register(with registrar: any FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            guard let shared = SwiftMobilistenPlugin.sharedInstance else {
                result(FlutterMethodNotImplemented)
                return
            }
            // setPageTitle is promoted to the flat `ZohoSalesIQ` facade (implemented in the main
            // handle); setCustomAction is module-only and handled by the dedicated tracking handler.
            if call.method == "setPageTitle" {
                shared.handle(call, result: result)
            } else {
                shared.handleTrackingMethodCall(call, result: result)
            }
        }
    }

    class HelpCenterPlugin: NSObject, FlutterPlugin {
        static func register(with registrar: any FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            // HelpCenter methods are all module-only.
            if let shared = SwiftMobilistenPlugin.sharedInstance {
                shared.handleHelpCenterMethodCall(call, result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }

    class ChatModulePlugin: NSObject, FlutterPlugin {
        static func register(with registrar: FlutterPluginRegistrar) {

        }

        func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            var argument: Any? {
                return call.arguments
            }

            switch call.method {
            case "showFeedbackUpTo":
                if let args = call.argumentDictionary, let duration = args["up_to_duration"] as? Int {
                    ZohoSalesIQ.Chat.showFeedback(uptoDuration: Double(duration))
                }
            case "showFeedbackAfterSkip":
                if let args = call.argumentDictionary, let show = args["enable"] as? Bool {
                    ZohoSalesIQ.Chat.showFeedbackAfterSkip(show)
                }
            case "hideQueueTime":
                if let hide = argument as? Bool {
                    ZohoSalesIQ.Chat.hideQueueTime(hide)
                }
            case "showPayloadChat":
                if let args = call.argumentDictionary, let type = args["type"] as? String, let payload = args["payload"] as? [String: Any] {
                    if type == "chat" {
                        let chatObject = SalesIQChatNotificationPayload(dictionary: payload)
                        ZohoSalesIQ.Chat.open(with: chatObject)
                    } else if type == "endChatDetails" {
                        let endChatObject = SalesIQEndChatNotificationPayload(dictionary: payload)
                        ZohoSalesIQ.Chat.open(with: endChatObject)
                    }
                }
            case "startNewChat":
                if let args = call.argumentDictionary, let question = args["question"] as? String {
                    let customChatId: String? = args["custom_chat_id"] as? String ?? nil
                    let departmentName: String? = args["department_name"] as? String ?? nil
                    ZohoSalesIQ.Chat.start(question: question, chatID: customChatId, department: departmentName) { error, success in
                        if let object = success {
                            let visitorObject = SwiftMobilistenPlugin().getChatObject(object)
                            result(visitorObject)
                        } else {
                            result(SwiftMobilistenPlugin().getResourceError(error: error))
                        }
                    }
                }
            case "startNewChatWithTrigger":
                if let args = call.argumentDictionary {
                    let customChatId: String? = args["custom_chat_id"] as? String ?? nil
                    let departmentName: String? = args["department_name"] as? String ?? nil
                    ZohoSalesIQ.Chat.startWithTrigger(chatID: customChatId, department: departmentName) { error, success in
                        if let object = success {
                            let visitorObject = SwiftMobilistenPlugin().getChatObject(object)
                            result(visitorObject)
                        } else {
                            result(SwiftMobilistenPlugin().getResourceError(error: error))
                        }
                    }
                }
            case "initiateNewChatWithTrigger":
                if let args = call.argumentDictionary {
                    if let actionName = args["custom_action_name"] as? String, !actionName.isEmpty {
                        let customChatId: String? = args["custom_chat_id"] as? String ?? nil
                        let departmentName: String? = args["department_name"] as? String ?? nil
                        ZohoSalesIQ.Chat.startWithTrigger(actionName: actionName, chatID: customChatId, department: departmentName) { error, success in
                            if let object = success {
                                let visitorObject = SwiftMobilistenPlugin().getChatObject(object)
                                result(visitorObject)
                            } else {
                                result(SwiftMobilistenPlugin().getResourceError(error: error))
                            }
                        }
                    } else {
                        result(SwiftMobilistenPlugin().getErrorMessage("custom action name mandatory"))
                    }
                }
            case "getChat":
                if let args = call.argumentDictionary, let chatId = args["chat_id"] as? String {
                    ZohoSalesIQ.Chat.get(chatID: chatId) { error, chat in
                        if let object = chat {
                            let visitorObject = SwiftMobilistenPlugin().getChatObject(object)
                            result(visitorObject)
                        } else {
                            result(SwiftMobilistenPlugin().getResourceError(error: error))
                        }
                    }
                }
            case "setWaitingTime":
                if let time = argument as? Int {
                    ZohoSalesIQ.Chat.setWaitingTime(upTo: time)
                }
            case "setTitle":
                if let args = call.argumentDictionary {
                    let onlineTitle = args["onlineTitle"] as? String
                    let offlineTitle = args["offlineTitle"] as? String
                    ZohoSalesIQ.Chat.setTitle(online: onlineTitle, offline: offlineTitle)
                }
            case "getUnreadCount":
                result(ZohoSalesIQ.Chat.getUnreadMessageCount())
            case "setComponentVisibility":
                if let args = call.argumentDictionary, let component = args["component_name"] as? String, let visible = args["visible"] as? Bool {
                    guard let chatComponent = getChatComponent(component) else {
                        result(SwiftMobilistenPlugin().getErrorMessage("Failed to set chat component visibility"))
                        return
                    }
                    ZohoSalesIQ.Chat.setVisibility(chatComponent, visible: visible)
                }
                break
            case "setOfflineMessage":
                if let message = argument as? String {
                    ZohoSalesIQ.Chat.setOfflineMessage(message)
                }
            default:
                // Members promoted from the flat `ZohoSalesIQ` surface (e.g.
                // `setOperatorEmail`, `end`, `getChats`, `shouldOpenUrl`) are
                // handled by the main plugin; forward to it so the Dart `Chat`
                // module can use its own channel.
                if let shared = SwiftMobilistenPlugin.sharedInstance {
                    shared.handle(call, result: result)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        func getChatComponent(_ componetRawValue: String) -> ChatComponent? {
            switch componetRawValue {
            case "operator_image":
                return .attenderImageInChat
            case "rating":
                return .rating
            case "feedback":
                return .feedback
            case "screenshot":
                return .screenshotOption
            case "pre_chat_form":
                return .preChatForm
            case "visitor_name":
                return .visitorName
            case "email_transcript":
                return .emailTranscript
            case "file_share":
                return .fileSharing
            case "media_capture":
                return .mediaCapture
            case "take_photo":
                return .takePhoto
            case "record_video":
                return .recordVideo
            case "media_library":
                return .photoLibrary
            case "end":
                return .end
            case "end_when_in_queue":
                return .endWhenInQueue
            case "end_when_bot_connected":
                return .endWhenBotConnected
            case "end_when_operator_connected":
                return .endWhenOperatorConnected
            case "reopen":
                return .reopen
            case "call":
                return .callIcon
            case "fileSharingWhenBotConnected":
                return .attachmentIconWhenBotConnected
            case "voiceNoteWhenBotConnected":
                return .voiceNoteIconWhenBotConnected
            default:
                return nil
            }
        }

    }

}

extension SwiftMobilistenPlugin: UNUserNotificationCenterDelegate {


    var internallyHandlesPushNotificationConfiguration: Bool {
        return SwiftMobilistenPlugin.checkFlag(name: .autoHandlePushNotifications)
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any] = [:]) -> Bool {

        guard internallyHandlesPushNotificationConfiguration else { return true }
        if let notificationData = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable: Any] {
            ZohoSalesIQ.handleNotificationResponse(notificationData)
        }

        return true
    }

    func application(
        _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
            @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard internallyHandlesPushNotificationConfiguration else { return }
        guard ZohoSalesIQ.isMobilistenNotification(userInfo) else { return }
        ZohoSalesIQ.processNotificationWithInfo(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard internallyHandlesPushNotificationConfiguration else { return }
        let deviceTokenString = deviceToken.reduce("", { $0 + String(format: "%02X", $1) })
        var isTestDevice: Bool = false
        var apnsMode: APNSMode = .production
        #if DEBUG
        apnsMode = .sandbox
        isTestDevice = true
        #endif
        ZohoSalesIQ.enablePush(deviceTokenString, isTestDevice: isTestDevice, mode: apnsMode)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
        guard internallyHandlesPushNotificationConfiguration else { return true }
        if ZohoSalesIQ.isMobilistenNotification(userInfo) {
            ZohoSalesIQ.processNotificationWithInfo(userInfo)
            completionHandler(.newData)
        }
        return true
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        guard internallyHandlesPushNotificationConfiguration else { return }
        if ZohoSalesIQ.isMobilistenNotification(notification.request.content.userInfo) {
            ZohoSalesIQ.processNotificationWithInfo(notification.request.content.userInfo)
            completionHandler(.alert)
        }
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard internallyHandlesPushNotificationConfiguration else { return }
        if ZohoSalesIQ.isMobilistenNotification(response.notification.request.content.userInfo) {
            if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
                ZohoSalesIQ.handleNotificationResponse(response.notification.request.content.userInfo)
                completionHandler()
            }
        }
    }

}

extension SwiftMobilistenPlugin: FlutterSceneLifeCycleDelegate {
    public func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions?) -> Bool {
        guard internallyHandlesPushNotificationConfiguration else { return true }
        guard let notificationData = connectionOptions?.notificationResponse?.notification.request.content.userInfo else {
            return true
        }
        guard ZohoSalesIQ.isMobilistenNotification(notificationData) else { return true }
        ZohoSalesIQ.handleNotificationResponse(notificationData)
        return true
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

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            if hexColor.count == 6 {
                hexColor.append("ff")
            }
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension ChatStatus {

    private static var statusMap: [ChatStatus: String] {
        return [
            .all: "all",
            .closed: "closed",
            .connected: "connected",
            .ended: "ended",
            .missed: "missed",
            .open: "open",
            .proactive: "proactive",
            .triggered: "triggered",
            .waiting: "waiting",
        ]
    }

    var string: String {
        if let stringValue = ChatStatus.statusMap[self] {
            return stringValue
        } else {
            return "closed"
        }
    }

    static func statusFromString(_ string: String) -> ChatStatus {
        let statusList = statusMap
        for key in statusList.keys {
            if let value = statusList[key], value == string {
                return key
            }
        }
        return .all
    }

}

extension SIQArticleRatedType {

    private static var statusMap: [SIQArticleRatedType: String] {
        return [
            .liked: "liked",
            .disliked: "disliked",
            .none: "none",
        ]
    }

    var string: String {
        if let stringValue = SIQArticleRatedType.statusMap[self] {
            return stringValue
        } else {
            return "none"
        }
    }

    static func statusFromString(_ string: String) -> SIQArticleRatedType {
        let statusList = statusMap
        for key in statusList.keys {
            if let value = statusList[key], value == string {
                return key
            }
        }
        return .none
    }

}

extension String {
    func trimSpace() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}

extension SwiftMobilistenPlugin {

    private func getError(error: NSError?) -> FlutterError? {
        guard let err = error else { return nil }
        return FlutterError(code: String(err.code), message: err.localizedDescription, details: nil)
    }

    private func getError(error: SIQError?) -> FlutterError? {
        guard let err = error else { return nil }
        return FlutterError(code: String(err.code), message: err.message, details: nil)
    }

    private func getResourceError(error: SIQError?) -> FlutterError? {
        guard let err = error else { return nil }
        return FlutterError(code: String(err.code), message: err.message, details: nil)
    }

    private func getVisitorLocation(using locationDictionary: [String: Any]) -> SIQVisitorLocation? {
        guard locationDictionary.count > 0 else { return nil }
        let location = SIQVisitorLocation()
        if let countryCode = locationDictionary["countryCode"] as? String {
            location.countryCode = countryCode
        }
        if let latitude = locationDictionary["latitude"] as? NSNumber {
            location.latitude = latitude
        }
        if let longitude = locationDictionary["longitude"] as? NSNumber {
            location.longitude = longitude
        }
        if let zipCode = locationDictionary["zipCode"] as? String {
            location.zipCode = zipCode
        }
        if let city = locationDictionary["city"] as? String {
            location.city = city
        }
        if let state = locationDictionary["state"] as? String {
            location.state = state
        }
        if let country = locationDictionary["country"] as? String {
            location.country = country
        }
        return location
    }

    private func getCustomTriggerObject(triggerName: String, visitor: SIQVisitor) -> [String: Any] {
        var triggerInfo: [String: Any] = [:]
        triggerInfo["triggerName"] = triggerName
        triggerInfo["visitorInformation"] = getVisitorObject(using: visitor)
        return triggerInfo
    }

    private func getVisitorObject(using visitor: SIQVisitor) -> [String: Any] {
        var visitorInfo: [String: Any] = [:]
        visitorInfo["browser"] = visitor.browser
        visitorInfo["city"] = visitor.city
        visitorInfo["countryCode"] = visitor.countryCode
        visitorInfo["email"] = visitor.email
        visitorInfo["firstVisitTime"] = visitor.firstVisitTime?.milliSecondIntervalSince1970
        visitorInfo["ip"] = visitor.ip
        visitorInfo["lastVisitTime"] = visitor.lastVisitTime?.milliSecondIntervalSince1970
        visitorInfo["name"] = visitor.name
        visitorInfo["noOfDaysVisited"] = visitor.noOfDaysVisited
        visitorInfo["numberOfChats"] = visitor.numberOfChats
        visitorInfo["numberOfVisits"] = visitor.numberOfVisits
        visitorInfo["os"] = visitor.os
        visitorInfo["phone"] = visitor.phone
        visitorInfo["region"] = visitor.region
        visitorInfo["searchEngine"] = visitor.searchEngine
        visitorInfo["searchQuery"] = visitor.searchQuery
        visitorInfo["state"] = visitor.state
        visitorInfo["totalTimeSpent"] = visitor.totalTimeSpent
        return visitorInfo
    }

    func getChatObject(_ chat: SIQVisitorChat) -> [String: Any] {
        var chatDictionary: [String: Any] = [:]
        if let id = chat.referenceID {
            chatDictionary["id"] = id
        }
        if let question = chat.question {
            chatDictionary["question"] = question
        }

        if let attenderID = chat.attenderID {
            chatDictionary["attenderID"] = attenderID
            chatDictionary["isBotAttender"] = chat.isBotAttender
            if let attenderName = chat.attenderName {
                chatDictionary["attenderName"] = attenderName
            }
            if let attenderEmail = chat.attenderEmail {
                chatDictionary["attenderEmail"] = attenderEmail
            }
        }

        if let departmentName = chat.departmentName {
            chatDictionary["departmentName"] = departmentName
        }
        chatDictionary["status"] = chat.status.string
        chatDictionary["unreadCount"] = chat.unreadCount

        if let lastMessage = chat.lastMessage.text {
            chatDictionary["lastMessage"] = lastMessage
        }
        if let lastMessageTime = chat.lastMessage.time?.milliSecondIntervalSince1970 {
            chatDictionary["lastMessageTime"] = lastMessageTime
        }
        if let lastMessageSender = chat.lastMessage.sender {
            chatDictionary["lastMessageSender"] = lastMessageSender
        }

        var recentMessageDict: [String: Any] = [:]
        recentMessageDict["text"] = chat.lastMessage.text
        recentMessageDict["sender"] = chat.lastMessage.sender
        recentMessageDict["time"] = chat.lastMessage.time?.milliSecondIntervalSince1970
        recentMessageDict["is_read"] = chat.lastMessage.isRead

        if let file = chat.lastMessage.file {
            var recentMessageFileDict: [String: Any] = [:]
            recentMessageFileDict["name"] = file.name
            recentMessageFileDict["comment"] = file.comment
            recentMessageFileDict["content_type"] = file.contentType
            recentMessageFileDict["size"] = file.size
            recentMessageDict["file"] = recentMessageFileDict
        }
        chatDictionary["recentMessage"] = recentMessageDict

        let queuePosition = chat.queuePosition
        if queuePosition > 0 {
            chatDictionary["queuePosition"] = queuePosition
        }
        if let feedback = chat.feedback {
            chatDictionary["feedback"] = feedback
        }
        if let rating = chat.rating {
            chatDictionary["rating"] = rating
        }
        return chatDictionary
    }

    /// Serializes a SIQVisitorChat into a map matching the Dart
    /// SalesIQConversation.fromMap shape (a `type` discriminator plus the
    /// conversation keys). Used by the modern conversation-returning
    /// chat-start APIs; mirrors the calls plugin's conversation mapping.
    func getChatConversationObject(_ chat: SIQVisitorChat) -> [String: Any] {
        var conversationMap: [String: Any] = [:]
        conversationMap["type"] = "chat"
        if let id = chat.referenceID {
            conversationMap["id"] = id
        }
        if let question = chat.question {
            conversationMap["question"] = question
        }
        if let attenderID = chat.attenderID {
            conversationMap["attenderId"] = attenderID
        }
        if let attenderName = chat.attenderName {
            conversationMap["attenderName"] = attenderName
        }
        if let attenderEmail = chat.attenderEmail {
            conversationMap["attenderEmail"] = attenderEmail
        }
        if let departmentName = chat.departmentName {
            conversationMap["departmentName"] = departmentName
        }
        if let feedback = chat.feedback {
            conversationMap["feedback"] = feedback
        }
        if let rating = chat.rating {
            conversationMap["rating"] = rating
        }
        conversationMap["queuePosition"] = chat.queuePosition
        conversationMap["isBotAttender"] = chat.isBotAttender
        conversationMap["unreadCount"] = chat.unreadCount
        if let status = getConversationChatStatus(chat.status) {
            conversationMap["status"] = status
        }

        let lastMessage = chat.lastMessage
        if lastMessage.text != nil || lastMessage.sender != nil {
            var lastMessageMap: [String: Any] = [:]
            if let text = lastMessage.text {
                lastMessageMap["text"] = text
            }
            if let sender = lastMessage.sender {
                lastMessageMap["sender"] = sender
            }
            if let time = lastMessage.time?.milliSecondIntervalSince1970 {
                lastMessageMap["time"] = time
            }
            lastMessageMap["isRead"] = lastMessage.isRead
            if let file = lastMessage.file {
                var fileMap: [String: Any] = [:]
                fileMap["name"] = file.name
                fileMap["contentType"] = file.contentType
                fileMap["comment"] = file.comment
                fileMap["size"] = file.size
                lastMessageMap["file"] = fileMap
            }
            conversationMap["lastSalesIQMessage"] = lastMessageMap
        }
        return conversationMap
    }

    /// Maps the native ChatStatus to the string values expected by the Dart
    /// ChatStatus.fromString parser. Mirrors the calls plugin's mapping.
    func getConversationChatStatus(_ status: ChatStatus) -> String? {
        switch status {
        case .open, .connected:
            return "connected"
        case .triggered:
            return "triggered"
        case .proactive:
            return "proactive"
        case .waiting:
            return "waiting"
        case .missed:
            return "missed"
        case .closed, .ended:
            return "closed"
        default:
            return nil
        }
    }

    func getChatErrorMap(chat: SIQVisitorChat?, error: ChatError) -> ([String: Any]?, [String: Any]?) {
        var errorMap: [String: Any] = [:]

        errorMap["code"] = error.code
        errorMap["message"] = error.message

        var type: String?
        switch error.code {
        case 5000:
            type = "creationFailed"
        case 5001:
            type = "formSyncFailed"
        case 5003:
            type = "messagesSyncFailed"
        case 5002:
            type = "triggerTimedOut"
        case 5005:
            type = "socketConnectionFailedOnCreatingNewConversation"
        case 5004:
            type = "triggerFailed"
        default:
            break
        }

        if let type = type {
            errorMap["type"] = type
        }

        var chatMap: [String: Any] = [:]
        if let chat = chat {
            chatMap = getChatObject(chat)
        }

        return (chatMap, errorMap)
    }

    func getKnowledgeBaseErrorObject(error: ResourceError) -> [String: Any] {
        var errorMap: [String: Any] = [:]
        errorMap["code"] = error.code
        errorMap["message"] = error.message

        switch error.code {
        case 5201:
            errorMap["type"] = "articleCategoriesSyncFailure"
        case 5202:
            errorMap["type"] = "articlesSyncFailure"
        case 5203:
            errorMap["type"] = "articlesSearchFailure"
        default:
            break
        }
        return errorMap
    }

    private func getDepartmentObject(_ department: SIQDepartment) -> [String: Any] {
        var deptDictionary: [String: Any] = [:]
        deptDictionary["id"] = department.id
        deptDictionary["name"] = department.name
        deptDictionary["available"] = department.available
        return deptDictionary
    }

    private func getChatActionArgument(_ actionArguments: SIQChatActionArguments, actionName: String, UUID: String) -> [String: Any] {
        var arguments: [String: Any] = [:]
        arguments["clientActionName"] = actionName
        arguments["elementID"] = actionArguments.elementID
        arguments["name"] = actionArguments.identifier
        arguments["label"] = actionArguments.label
        arguments["type"] = actionArguments.type
        arguments["actionUUID"] = UUID
        return arguments
    }

    private func getResourceObject(_ resource: SIQKnowledgeBaseResource) -> [String: Any] {
        var resourceDictionary: [String: Any] = [:]

        resourceDictionary["id"] = resource.id

        if let category = resource.category {
            var resourceCategory: [String: Any] = [:]
            resourceCategory["id"] = category.id
            resourceCategory["name"] = category.name
            resourceDictionary["category"] = resourceCategory
        }

        resourceDictionary["title"] = resource.title
        resourceDictionary["departmentId"] = resource.departmentId

        if let language = resource.language {
            var resourceLanguage: [String: Any] = [:]
            resourceLanguage["id"] = language.id
            resourceLanguage["code"] = language.code
            resourceDictionary["language"] = resourceLanguage
        }

        if let creator = resource.creator {
            var resourceCreator: [String: Any] = [:]
            resourceCreator["id"] = creator.id
            resourceCreator["name"] = creator.name
            resourceCreator["email"] = creator.email
            resourceCreator["displayName"] = creator.displayName
            resourceCreator["imageUrl"] = creator.imageUrl
            resourceDictionary["creator"] = resourceCreator
        }

        if let modifier = resource.modifier {
            var resourceModifier: [String: Any] = [:]
            resourceModifier["id"] = modifier.id
            resourceModifier["name"] = modifier.name
            resourceModifier["email"] = modifier.email
            resourceModifier["displayName"] = modifier.displayName
            resourceModifier["imageUrl"] = modifier.imageUrl
            resourceDictionary["modifier"] = resourceModifier
        }

        resourceDictionary["createdTime"] = resource.createdTime?.milliSecondIntervalSince1970
        resourceDictionary["modifiedTime"] = resource.modifiedTime?.milliSecondIntervalSince1970
        resourceDictionary["publicUrl"] = resource.publicUrl

        if let stats = resource.stats {
            var resourceStats: [String: Any] = [:]
            resourceStats["liked"] = stats.liked
            resourceStats["disliked"] = stats.disliked
            resourceStats["used"] = stats.used
            resourceStats["viewed"] = stats.viewed
            resourceDictionary["stats"] = resourceStats
        }

        resourceDictionary["content"] = resource.content
        resourceDictionary["ratedType"] = resource.ratedType.string

        return resourceDictionary
    }

    private func getResourceCategoryObject(_ category: SIQKnowledgeBaseCategory) -> [String: Any] {
        var categoryDictionary: [String: Any] = [:]

        categoryDictionary["id"] = category.id
        categoryDictionary["name"] = category.name
        categoryDictionary["departmentId"] = category.departmentId
        categoryDictionary["count"] = category.count
        categoryDictionary["childrenCount"] = category.childrenCount
        categoryDictionary["order"] = category.order
        categoryDictionary["parentCategoryId"] = category.parentCategoryId
        categoryDictionary["resourceModifiedTime"] = category.resourceModifiedTime?.milliSecondIntervalSince1970

        return categoryDictionary
    }

    private func getResourceList(_ articles: [SIQKnowledgeBaseResource]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for article in articles {
            list.append(getResourceObject(article))
        }
        return list
    }

    private func getResourceCategoryList(_ articles: [SIQKnowledgeBaseCategory]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for article in articles {
            list.append(getResourceCategoryObject(article))
        }
        return list
    }

    private func getChatObjectList(_ chats: [SIQVisitorChat]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for chat in chats {
            list.append(getChatObject(chat))
        }
        return list
    }

    private func getDepartmentObjectList(_ departments: [SIQDepartment]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for department in departments {
            list.append(getDepartmentObject(department))
        }
        return list
    }

}

fileprivate class MobilistenEventStreamHandler: NSObject, FlutterStreamHandler {

    weak var plugin: SwiftMobilistenPlugin?

    internal init(plugin: SwiftMobilistenPlugin) {
        self.plugin = plugin
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.eventSink = nil
        return nil
    }
}

fileprivate class MobilistenChatEventStreamHandler: MobilistenEventStreamHandler {
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.chatEventSink = events
        return nil
    }
    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.chatEventSink = nil
        return nil
    }
}

fileprivate class MobilistenResourceEventStreamHandler: MobilistenEventStreamHandler {
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.resourceEventSink = events
        return nil
    }
    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.resourceEventSink = nil
        return nil
    }
}

fileprivate class MobilistenLauncherEventStreamHandler: MobilistenEventStreamHandler {
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.launcherEventSink = events
        return nil
    }
    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.launcherEventSink = nil
        return nil
    }
}

fileprivate class MobilistenNotificationEventStreamHandler: MobilistenEventStreamHandler {
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.notificationEventSink = events
        ZohoSalesIQ.registerNotificationListener(true)
        return nil
    }
    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.notificationEventSink = nil
        ZohoSalesIQ.registerNotificationListener(false)
        return nil
    }
}

extension SwiftMobilistenPlugin: ZohoSalesIQDelegate {

    public func shouldReRegisterPushNotification() {
        sendEvent(name: .reRegisterPush)
    }

    public func agentsOnline() {
        sendEvent(name: .operatorsOnline)
    }

    public func agentsOffline() {
        sendEvent(name: .operatorsOffline)
    }

    public func supportOpened() {
        sendEvent(name: .supportOpened)
    }

    public func supportClosed() {
        sendEvent(name: .supportClosed)
    }

    public func chatViewOpened(id: String?) {
        sendEvent(name: .chatViewOpened, dataLabel: "chatID", data: id)
    }

    public func chatViewClosed(id: String?) {
        sendEvent(name: .chatViewClosed, dataLabel: "chatID", data: id)
    }

    public func homeViewOpened() {
        sendEvent(name: .homeViewOpened)
    }

    public func homeViewClosed() {
        sendEvent(name: .homeViewClosed)
    }

    public func visitorIPBlocked() {
        sendEvent(name: .visitorIPBlocked)
    }

    public func handleTrigger(name: String, visitorInformation: SIQVisitor) {
        sendCustomTriggerEvent(triggerName: name, visitor: visitorInformation)
    }

    public func handleBotTrigger() {
        sendEvent(name: .botTrigger)
    }

    public func handleCustomLauncherVisibility(_ visible: Bool) {
        let event: [String: Any] = [MobilistenEvent.nameKey: MobilistenEvent.customLauncherVisibility.rawValue, "visible": visible]
        eventSink?(event)
        launcherEventSink?(event)
    }
}

extension SwiftMobilistenPlugin: ZohoSalesIQKnowledgeBaseDelegate {
    public func handleResourceOpened(_ type: Mobilisten.SIQResourceType, resource: Mobilisten.SIQKnowledgeBaseResource?) {
        guard let resource = resource else { return }
        let resourceType = type.rawValue
        let resourceDict: [String: Any] = ["type": resourceType, "resource": getResourceObject(resource)]
        sendResourceEvent(name: .resourceOpened, data: resourceDict)
    }

    public func handleResourceClosed(_ type: Mobilisten.SIQResourceType, resource: Mobilisten.SIQKnowledgeBaseResource?) {
        guard let resource = resource else { return }
        let resourceType = type.rawValue
        let resourceDict: [String: Any] = ["type": resourceType, "resource": getResourceObject(resource)]
        sendResourceEvent(name: .resourceClosed, data: resourceDict)
    }

    public func handleResourceLiked(_ type: Mobilisten.SIQResourceType, resource: Mobilisten.SIQKnowledgeBaseResource?) {
        guard let resource = resource else { return }
        let resourceType = type.rawValue
        let resourceDict: [String: Any] = ["type": resourceType, "resource": getResourceObject(resource)]
        sendResourceEvent(name: .resourceLiked, data: resourceDict)
    }

    public func handleResourceDisliked(_ type: Mobilisten.SIQResourceType, resource: Mobilisten.SIQKnowledgeBaseResource?) {
        guard let resource = resource else { return }
        let resourceType = type.rawValue
        let resourceDict: [String: Any] = ["type": resourceType, "resource": getResourceObject(resource)]
        sendResourceEvent(name: .resourceDisliked, data: resourceDict)
    }

    public func didFailWithError(_ type: SIQResourceType, resource: SIQKnowledgeBaseResource?, error: ResourceError) {
        let errorObject = getKnowledgeBaseErrorObject(error: error)
        var knowledgeBaseMap: [String: Any] = ["type": type.rawValue]
        if let resource {
            knowledgeBaseMap = ["resource": getResourceObject(resource)]
        }
        sendResourceEvent(name: .resourceError, data: knowledgeBaseMap, error: errorObject)
    }
}

extension SwiftMobilistenPlugin: ZohoSalesIQChatDelegate {
    public func shouldOpenURL(_ url: URL, in chat: Mobilisten.SIQVisitorChat?) -> Bool {
        if let chat = chat {
            var chatData = getChatObject(chat)
            chatData["url"] = String(describing: url)
            sendChatEvent(name: .handleURL, data: chatData)
        }
        return handleURL
    }


    public func chatOpened(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatOpened, data: getChatObject(chatData))
    }

    public func chatAttended(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatAttended, data: getChatObject(chatData))
    }

    public func chatMissed(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatMissed, data: getChatObject(chatData))
    }

    public func chatClosed(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatClosed, data: getChatObject(chatData))
    }

    public func chatReopened(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatReopened, data: getChatObject(chatData))
    }

    public func chatRatingRecieved(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatRatingReceived, data: getChatObject(chatData))
    }

    public func chatFeedbackRecieved(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatFeedbackReceived, data: getChatObject(chatData))
    }

    public func chatQueuePositionChanged(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatQueuePositionChanged, data: getChatObject(chatData))
    }

    public func unreadCountChanged(_ count: Int) {
        sendChatEvent(name: .chatUnreadCountChanged, dataLabel: "unreadCount", data: count)
    }

    public func handleNotificationAction(_ payload: SalesIQNotificationPayload?) {
        let notificationPayload = NotificationPlugin().getPayloadObjectEventDictionary(payload)
        let event: [String: Any] = [MobilistenEvent.nameKey: MobilistenEvent.notificationClicked.rawValue, "payload": notificationPayload]
        self.notificationEventSink?(event)
    }

    public func didFailWithError(chat: SIQVisitorChat?, error: ChatError) {
        let (chatObj, errorObj) = getChatErrorMap(chat: chat, error: error)
        sendChatEvent(name: .chatError, dataLabel: "chat", data: chatObj, error: errorObj)
    }

    public func chatExpired(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatExpired, data: getChatObject(chatData))
    }
}


fileprivate extension UIImage {
    func toBase64String(compressionQuality: CGFloat) -> String? {
        guard let imageData = self.jpegData(compressionQuality: compressionQuality) else { return nil }
        return imageData.base64EncodedString()
    }
}

extension Date {
    var milliSecondIntervalSince1970: Double {
        return self.timeIntervalSince1970 * 1000
    }
}
