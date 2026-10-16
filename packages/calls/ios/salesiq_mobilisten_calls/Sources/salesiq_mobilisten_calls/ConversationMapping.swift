import MobilistenCore
import MobilistenCallsCore
import MobilistenCalls

extension SwiftMobilistenCallsPlugin {
    func getChatConversationMap(chat: SalesIQChat) -> [String: Any] {
        var conversationMap: [String: Any] = [:]
        conversationMap = getConversationDetails(chat)
        conversationMap["type"] = "chat"
        
        conversationMap["isBotAttender"] = chat.isBotAttender
        conversationMap["status"] = getChatStatus(chat.status)
        conversationMap["unreadCount"] = chat.unreadCount
        
        if let lastMessage = chat.lastMessage {
            var lastMessageMap: [String: Any] = [:]
            lastMessageMap["text"] = lastMessage.text
            if let sender = lastMessage.sender {
                lastMessageMap["sender"] = sender.name
                lastMessageMap["senderId"] = sender.id
            }
            lastMessageMap["time"] = lastMessage.time?.timeIntervalSince1970
            lastMessageMap["isRead"] = lastMessage.isRead
            lastMessageMap["sentByVisitor"] = lastMessage.sentByUser

            var fileMap: [String: Any] = [:]
            if let file = lastMessage.file {
                fileMap["name"] = file.name
                fileMap["contentType"] = file.contentType
                fileMap["comment"] = file.comment
                fileMap["size"] = file.size
            }
            lastMessageMap["file"] = fileMap
            
            lastMessageMap["status"] = getMessageStatus(lastMessage.status)
            conversationMap["lastSalesIQMessage"] = lastMessageMap
        }
        return conversationMap
    }
    
    func getCallConversationMap(call: SalesIQCall) -> [String: Any] {
        var conversationMap: [String: Any] = [:]
        conversationMap = getConversationDetails(call)
        conversationMap["type"] = "call"
        conversationMap["status"] = getCallStatus(call.status)
        return conversationMap
    }
    
    func getConversationDetails(_ conversation: SalesIQConversation) -> [String: Any] {
        var conversationMap: [String: Any] = [:]
        
        conversationMap["id"] = conversation.id
        conversationMap["customConversationId"] = conversation.customConversationId
        conversationMap["question"] = conversation.question
        conversationMap["attenderId"] = conversation.attenderId
        conversationMap["attenderName"] = conversation.attenderName
        conversationMap["attenderEmail"] = conversation.attenderEmail
        conversationMap["departmentName"] = conversation.departmentName
        conversationMap["feedback"] = conversation.feedback
        conversationMap["rating"] = conversation.rating
        conversationMap["queuePosition"] = conversation.queuePosition
        
        if let media = conversation.media {
            var mediaMap: [String: Any] = [:]
            mediaMap["id"] = media.id
            
            if let endTime = media.endTime {
                mediaMap["endTime"] = Int(endTime)
            }
            
            mediaMap["initiatedBy"] = getVisitorType(media.endedBy)
            
            if let pickupTime = media.pickupTime {
                mediaMap["pickupTime"] = Int(pickupTime)
            }
            
            if let connectedTime = media.connectedTime {
                mediaMap["connectedTime"] = Int(connectedTime)
            }
            
            mediaMap["status"] = getMediaStatus(media.status)
            mediaMap["endedBy"] = getVisitorType(media.endedBy)
            mediaMap["type"] = media.type
            if let createdTime = media.createdTime {
                mediaMap["createdTime"] = Int(createdTime)
            }
            
            conversationMap["media"] = mediaMap
        }
        return conversationMap
    }
    
    func getVisitorType(_ userType: UserType?) -> String? {
        guard let userType = userType else {
            return nil
        }
        switch userType {
        case .user:
            return "visitor"
        case .agent:
            return "operator"
        default:
            return nil
        }
    }
    
    func getMediaStatus(_ status: SalesIQMediaStatus?) -> String? {
        guard let status = status else {
            return nil
        }
        switch status {
        case .ended:
            return "ended"
        case .missed, .rejected:
            return "missed"
        case .cancelled:
            return "cancelled"
        case .connected:
            return "connected"
        case .invited:
            return "invited"
        case .initiated:
            return "initiated"
        case .accepted:
            return "accepted"
        default:
            return nil
        }
    }
    
    func getChatStatus(_ status: ChatStatus?) -> String? {
        guard let status = status else {
            return nil
        }
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
    
    func getCallStatus(_ status: SalesIQCallConversationStatus?) -> String? {
        guard let status = status else {
            return nil
        }
        switch status {
        case .waiting:
            return "waiting"
        case .connected:
            return "connected"
        case .missed:
            return "missed"
        case .closed:
            return "closed"
        default:
            return nil
        }
    }
    
    func getMessageStatus(_ status: SalesIQMessageStatus?) -> String? {
        guard let status = status else {
            return nil
        }
        switch status {
        case .sending:
            return "sending"
        case .uploading:
            return "uploading"
        case .sent:
            return "sent"
        case .failed:
            return "failed"
        @unknown default:
            return nil
        }
    }
    
    func getCallStatus(_ status: SalesIQCallStatus?) -> String? {
        guard let status = status else {
            return nil
        }
        switch status {
        case .none:
            return "none"
        case .calling:
            return "calling"
        case .ringing:
            return "ringing"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        case .reconnecting:
            return "reconnecting"
        case .ended:
            return "ended"
        case .missed:
            return "missed"
        case .cancelled:
            return "cancelled"
        case .declined:
            return "declined"
        case .failed:
            return "failed"
        case .queue:
            return "queue"
        case .invalid:
            return "invalid"
        default:
            return nil
        }
    }
}
