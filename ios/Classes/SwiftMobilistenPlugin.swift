import Flutter
import UIKit
import Mobilisten

public class SwiftMobilistenPlugin: NSObject, FlutterPlugin {
    
    private enum MobilistenChannel {
        
        case plugin
        case main
        case chat
        case faq
        
        var name: String {
            switch self {
            case .plugin:
                return "salesiq_mobilisten"
            case .main:
                return "mobilistenEventChannel"
            case .chat:
                return "mobilistenChatEventChannel"
            case .faq:
                return "mobilistenFAQEventChannel"
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
        
        case supportOpened = "supportOpened";
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
        case articleLiked = "articleLiked"
        case articleDisliked = "articleDisliked"
        case articleOpened = "articleOpened"
        case articleClosed = "articleClosed"
        case homeViewOpened = "homeViewOpened"
        case homeViewClosed = "homeViewClosed"
        case chatUnreadCountChanged = "chatUnreadCountChanged"
        case handleURL = "handleURL"
        
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
    private static var faqEventChannel: FlutterEventChannel?
    private static var chatEventChannel: FlutterEventChannel?
    @objc public static var emptyChatInstance: SIQVisitorChat?
    
    var eventSink: FlutterEventSink?
    var faqEventSink: FlutterEventSink?
    var chatEventSink: FlutterEventSink?
    private var handleURL = true
    
    static var sharedInstance: SwiftMobilistenPlugin?
    private var chatActionStore: [String: SIQActionHandler] = [:]
    private let operationFailedError = FlutterError(code: "1000", message: "operation failed", details: nil)
    
    private static var mobilistenPluginFlags: [MobilistenPluginFlag: Bool] = [.autoHandlePushNotifications: true,
                                                                              .enableDisabledEvents: false]
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        let methodChannel = MobilistenChannel.plugin.createMethodChannel(registrar: registrar)
        eventChannel = MobilistenChannel.main.createEventChannel(registrar: registrar)
        faqEventChannel = MobilistenChannel.faq.createEventChannel(registrar: registrar)
        chatEventChannel = MobilistenChannel.chat.createEventChannel(registrar: registrar)
        
        let instance = SwiftMobilistenPlugin()
        sharedInstance = instance
        
        let eventStreamHandler = MobilistenEventStreamHandler(plugin: instance)
        let chatEventStreamHandler = MobilistenChatEventStreamHandler(plugin: instance)
        let faqEventStreamHandler = MobilistenFAQEventStreamHandler(plugin: instance)
        
        eventChannel?.setStreamHandler(eventStreamHandler)
        faqEventChannel?.setStreamHandler(faqEventStreamHandler)
        chatEventChannel?.setStreamHandler(chatEventStreamHandler)
        
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        
    }
    
    // MARK: Perform any additional setup after initialisation.
    func performAdditionalSetup() {
        // your code goes here.
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        var argument: Any? {
            return call.arguments
        }
        
        switch call.method {
        case "init":
            ZohoSalesIQ.setPlatform(platform: "Flutter")
            if let args = call.argumentDictionary, let appKey = args["appKey"] as? String, let accessKey = args["accessKey"] as? String {
                ZohoSalesIQ.initWithAppKey(appKey, accessKey: accessKey, completion: { (success) in
                    if success {
                        result(nil)
                    } else {
                        result(self.operationFailedError)
                    }
                })
                ZohoSalesIQ.delegate = self
                ZohoSalesIQ.FAQ.delegate = self
                ZohoSalesIQ.Chat.delegate = self
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
        case "setFAQVisibility":
            if let show = argument as? Bool {
                ZohoSalesIQ.FAQ.setVisibility(show)
            }
        case "registerVisitor":
            if let id = argument as? String {
                ZohoSalesIQ.registerVisitor(id) { status in
                    if status {
                        result(nil)
                    } else {
                        result(self.operationFailedError)
                    }
                }
            }
        case "unregisterVisitor":
            ZohoSalesIQ.unregisterVisitor { status in
                if status {
                    result(nil)
                } else {
                    result(self.operationFailedError)
                }
            }
        case "setPageTitle":
            if let pageTitle = argument as? String {
                ZohoSalesIQ.Tracking.setPageTitle(pageTitle)
            }
        case "performCustomAction":
            if let customAction = argument as? String {
                ZohoSalesIQ.Visitor.performCustomAction(customAction)
            }
        case "enableInAppNotification":
            ZohoSalesIQ.Chat.setVisibility(.inAppNotifications, visible: true)
        case "disableInAppNotification":
            ZohoSalesIQ.Chat.setVisibility(.inAppNotifications, visible: false)
        case "setOperatorEmail":
            if let operatorEmail = argument as? String {
                ZohoSalesIQ.Chat.setAgentEmail(operatorEmail)
            }
        case "show":
            ZohoSalesIQ.Chat.show()
        case "openChatWithID":
            if let id = argument as? String {
                ZohoSalesIQ.Chat.show(referenceID: id, new: false)
            }
        case "openNewChat":
            ZohoSalesIQ.Chat.show(new: true)
        case "showOfflineMessage":
            if let show = argument as? Bool {
                ZohoSalesIQ.Chat.showOfflineMessage(show)
            }
        case "endChat":
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
        case "getChats", "getChatsWithFilter":
            var status: ChatStatus = .all
            if let stringFilterValue = argument as? String {
                status = ChatStatus.statusFromString(stringFilterValue)
            }
            ZohoSalesIQ.Chat.getList(filter: status) { error, chats in
                guard error == nil else {
                    result(self.getError(error:error))
                    return
                }
                guard let chatObjects = chats else {
                    result([])
                    return
                }
                let list = self.getChatObjectList(chatObjects)
                result(list)
            }
        case "getArticles", "getArticlesWithCategoryID":
            var categoryID: String?
            if let stringFilterValue = (argument as? String), stringFilterValue.isEmpty == false {
                categoryID = stringFilterValue
            }
            ZohoSalesIQ.FAQ.getArticles(categoryID: categoryID) { error, articles in
                guard error == nil else {
                    result(self.getError(error:error))
                    return
                }
                guard let articleObjects = articles else {
                    result([])
                    return
                }
                let list = self.getArticleObjectList(articleObjects)
                result(list)
            }
        case "getArticleCategories":
            ZohoSalesIQ.FAQ.getCategories { error, categories in
                guard error == nil else {
                    result(self.getError(error:error))
                    return
                }
                guard let categoryObjects = categories else {
                    result([])
                    return
                }
                let list = self.getCategoryObjectList(categoryObjects)
                result(list)
            }
        case "getDepartments":
            ZohoSalesIQ.Chat.getDepartments { error, departments in
                guard error == nil else {
                    result(self.getError(error:error))
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
                            result(self.getError(error:error))
                            return
                        }
                        guard let attenderImage = image, let base64String = attenderImage.toBase64String(compressionQuality: 0.5) else {
                            result(self.operationFailedError)
                            return
                        }
                        result(base64String)
                    }
                } else {
                    result(operationFailedError)
                }
            } else {
                result(operationFailedError)
            }
        case "openArticle":
            if let id = argument as? String {
                ZohoSalesIQ.FAQ.openArticle(articleID: id) { error in
                    result(self.getError(error:error))
                }
            } else {
                result(operationFailedError)
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
                result(operationFailedError)
            }
        case "unregisterChatAction":
            if let name = argument as? String {
                ZohoSalesIQ.ChatActions.unregisterWithName(name: name)
            } else {
                result(operationFailedError)
            }
        case "unregisterAllChatActions":
            ZohoSalesIQ.ChatActions.unregisterAll()
        case "setChatActionTimeout":
            if let time = argument as? Int {
                ZohoSalesIQ.ChatActions.setTimeout(Double(time))
            } else {
                result(operationFailedError)
            }
        case "completeChatAction":
            if let uuid = argument as? String, let handler = chatActionStore[uuid] {
                handler.success()
                chatActionStore.removeValue(forKey: uuid)
            } else {
                result(operationFailedError)
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
                result(operationFailedError)
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
                result(operationFailedError)
            }
        case "handleNotificationResponseForiOS":
            if let userInfo = argument as? [AnyHashable: Any] {
                ZohoSalesIQ.handleNotificationResponse(userInfo)
            } else {
                result(operationFailedError)
            }
        case "processNotificationWithInfoForiOS":
            if let userInfo = argument as? [AnyHashable: Any] {
                ZohoSalesIQ.processNotificationWithInfo(userInfo)
            } else {
                result(operationFailedError)
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
                ZohoSalesIQ.Logger.write(log, logLevel: logLevel, success: { (success) in
                     if success {
                        result(nil)
                    } else {
                        result(self.operationFailedError)
                    }
                })
            }
        case "setTabOrder":
            var tabs:[Int] = []
            if let tabList = call.argumentList as? [String] {
                for tab in tabList {
                    if tab == "TAB_CONVERSATIONS" {
                        tabs.append(SIQTabBarComponent.conversation.rawValue)
                    } else if tab == "TAB_FAQ" {
                        tabs.append(SIQTabBarComponent.knowledgeBase.rawValue)
                    }
                }        
            }
            ZohoSalesIQ.setTabOrder(tabs)
        case "sendEvent":
            if let args = call.argumentDictionary, let eventName = args["eventName"] as? String, let values = args["values"] as? [AnyObject] {
                 var logLevel: SIQDebugLogLevel = .info
                    logLevel = .error
                    ZohoSalesIQ.Logger.write("performChatAction", logLevel: logLevel, success: { (success) in

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
                        result(operationFailedError)
                    }
                }
            }
        case "setPathForiOS":
            if let path = argument as? String {
                let pathURL = NSURL.fileURL(withPath: path)
                ZohoSalesIQ.Logger.setPath(pathURL)
            } 
        default:
            result(FlutterMethodNotImplemented)
        }
        
    }
    
    private func createEvent(name: MobilistenEvent, dataLabel: String = "data", data: Any? = nil) -> [String: Any]? {
        guard name.enabled else { return nil }
        var event: [String: Any] = [:]
        event[MobilistenEvent.nameKey] = name.rawValue
        event[dataLabel] = data
        return formEventData(name: name, dataLabel: dataLabel, event: event)
    }

    private func formEventData(name: MobilistenEvent, dataLabel: String, event: [String: Any]) -> [String: Any]?  {
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
    
    private func sendChatEvent(name: MobilistenEvent, dataLabel: String = "chat", data: Any? = nil) {
        guard let event = createEvent(name: name, dataLabel: dataLabel, data: data) else { return }
        chatEventSink?(event)
    }
    
    private func sendFAQEvent(name: MobilistenEvent, dataLabel: String = "articleID", data: Any? = nil) {
        guard let event = createEvent(name: name, dataLabel: dataLabel, data: data) else { return }
        faqEventSink?(event)
    }
    
}

extension SwiftMobilistenPlugin {
    
    var internallyHandlesPushNotificationConfiguration: Bool {
        return SwiftMobilistenPlugin.checkFlag(name: .autoHandlePushNotifications)
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        
        guard internallyHandlesPushNotificationConfiguration else { return true }
        if let notificationData = launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] as? [AnyHashable : Any] {
            ZohoSalesIQ.handleNotificationResponse(notificationData)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification
                        userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler:
                            @escaping (UIBackgroundFetchResult) -> Void){
        guard internallyHandlesPushNotificationConfiguration else { return }
        guard ZohoSalesIQ.isMobilistenNotification(userInfo) else { return }
        ZohoSalesIQ.processNotificationWithInfo(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard internallyHandlesPushNotificationConfiguration else { return }
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        var isTestDevice: Bool = false
        var apnsMode: APNSMode = .production
        #if DEBUG
        apnsMode = .sandbox
        isTestDevice = true
        #endif
        ZohoSalesIQ.enablePush(deviceTokenString, isTestDevice: isTestDevice, mode: apnsMode)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Bool {
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
        return [.all: "all",
                .closed: "closed",
                .connected: "connected",
                .ended: "ended",
                .missed: "missed",
                .open: "open",
                .proactive: "proactive",
                .triggered: "triggered",
                .waiting: "waiting"]
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
    
    private func getVisitorLocation(using locationDictionary: [String: Any]) -> SIQVisitorLocation? {
        guard locationDictionary.count > 0 else { return nil }
        let location = SIQVisitorLocation()
        if let countryCode = locationDictionary["countryCode"] as? String {
            location.countryCode = countryCode
        }
        if let latitude = locationDictionary["latitude"] as? NSNumber{
            location.latitude = latitude
        }
        if let longitude = locationDictionary["longitude"] as? NSNumber{
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
        triggerInfo["visitorInformation"] = getVisitorObject(using:visitor)
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
    
    private func getChatObject(_ chat: SIQVisitorChat) -> [String: Any] {
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
        if let lastmessageTime = chat.lastMessage.time?.milliSecondIntervalSince1970 {
            chatDictionary["lastMessageTime"] = lastmessageTime
        }
        if let lastmessageSender = chat.lastMessage.sender {
            chatDictionary["lastMessageSender"] = lastmessageSender
        }
        
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
    
    private func getDepartmentObject(_ department: SIQDepartment) -> [String: Any] {
        var deptDictionary: [String: Any] = [:]
        deptDictionary["id"] = department.id
        deptDictionary["name"] = department.name
        deptDictionary["available"] = department.available
        return deptDictionary
    }
    
    private func getArticleObject(_ article: SIQFAQArticle) -> [String: Any] {
        var articleDictionary: [String: Any] = [:]
        articleDictionary["id"] = article.id
        articleDictionary["name"] = article.name
        articleDictionary["categoryID"] = article.categoryID
        articleDictionary["categoryName"] = article.categoryName
        articleDictionary["viewCount"] = article.viewCount
        articleDictionary["likeCount"] = article.likeCount
        articleDictionary["dislikeCount"] = article.dislikeCount
        articleDictionary["createdTime"] = article.createdTime?.milliSecondIntervalSince1970
        articleDictionary["modifiedTime"] = article.lastModifiedTime?.milliSecondIntervalSince1970
        return articleDictionary
    }
    
    private func getCategoryObject(_ category: SIQFAQCategory) -> [String: Any] {
        var categoryDictionary: [String: Any] = [:]
        categoryDictionary["id"] = category.id
        categoryDictionary["name"] = category.name
        categoryDictionary["articleCount"] = category.articleCount
        return categoryDictionary
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
    
    private func getChatObjectList(_ chats: [SIQVisitorChat]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for chat in chats {
            list.append(getChatObject(chat))
        }
        return list
    }
    
    private func getArticleObjectList(_ articles: [SIQFAQArticle]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for article in articles {
            list.append(getArticleObject(article))
        }
        return list
    }
    
    private func getCategoryObjectList(_ categories: [SIQFAQCategory]) -> [[String: Any]] {
        var list: [[String: Any]] = []
        for category in categories {
            list.append(getCategoryObject(category))
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

fileprivate class MobilistenFAQEventStreamHandler: MobilistenEventStreamHandler {
    override func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        plugin?.faqEventSink = events
        return nil
    }
    override func onCancel(withArguments arguments: Any?) -> FlutterError? {
        plugin?.faqEventSink = nil
        return nil
    }
}

extension SwiftMobilistenPlugin: ZohoSalesIQDelegate {
    
    public func agentsOnline() {
        sendEvent(name:.operatorsOnline)
    }
    
    public func agentsOffline() {
        sendEvent(name:.operatorsOffline)
    }
    
    public func supportOpened() {
        sendEvent(name:.supportOpened)
    }
    
    public func supportClosed() {
        sendEvent(name:.supportClosed)
    }
    
    public func chatViewOpened(id: String?) {
        sendEvent(name:.chatViewOpened, dataLabel: "chatID", data: id)
    }
    
    public func chatViewClosed(id: String?) {
        sendEvent(name:.chatViewClosed, dataLabel: "chatID", data: id)
    }
    
    public func homeViewOpened() {
        sendEvent(name:.homeViewOpened)
    }
    
    public func homeViewClosed() {
        sendEvent(name:.homeViewClosed)
    }
    
    public func visitorIPBlocked() {
        sendEvent(name:.visitorIPBlocked)
    }
    
    public func handleTrigger(name: String, visitorInformation: SIQVisitor) {
        sendCustomTriggerEvent(triggerName: name, visitor: visitorInformation)
    }
    
}

extension SwiftMobilistenPlugin: ZohoSalesIQFAQDelegate {
    
    public func articleOpened(id: String?) {
        sendFAQEvent(name: .articleOpened, data:id)
    }
    
    public func articleClosed(id: String?) {
        sendFAQEvent(name: .articleClosed, data:id)
    }
    
    public func articleLiked(id: String?) {
        sendFAQEvent(name: .articleLiked, data:id)
    }
    
    public func articleDisliked(id: String?) {
        sendFAQEvent(name: .articleDisliked, data:id)
    }
    
}

extension SwiftMobilistenPlugin: ZohoSalesIQChatDelegate {
    public func shouldOpenURL(_ url: URL, in chat: Mobilisten.SIQVisitorChat?) -> Bool {
        if let chat = chat {
            var chatData = getChatObject(chat)
            chatData["url"] = String(describing: url)
            sendChatEvent(name: .handleURL, data:chatData)
        }
        return handleURL
    }
    
    
    public func chatOpened(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatOpened, data:getChatObject(chatData))
    }
    
    public func chatAttended(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatAttended, data:getChatObject(chatData))
    }
    
    public func chatMissed(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatMissed, data:getChatObject(chatData))
    }
    
    public func chatClosed(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatClosed, data:getChatObject(chatData))
    }
    
    public func chatReopened(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatReopened, data:getChatObject(chatData))
    }
    
    public func chatRatingRecieved(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatRatingReceived, data:getChatObject(chatData))
    }
    
    public func chatFeedbackRecieved(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatFeedbackReceived, data:getChatObject(chatData))
    }
    
    public func chatQueuePositionChanged(chat: SIQVisitorChat?) {
        guard let chatData = chat else { return }
        sendChatEvent(name: .chatQueuePositionChanged, data:getChatObject(chatData))
    }
    
    public func unreadCountChanged(_ count: Int) {
        sendChatEvent(name: .chatUnreadCountChanged, dataLabel: "unreadCount", data: count)
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
