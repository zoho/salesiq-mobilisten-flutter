import MobilistenCallsCore

class MobilistenCallsListeners: NSObject, ZohoSalesIQCallDelegate {
    func queuePositionDidChange(for conversationID: String, position: Int) {
        SwiftMobilistenCallsPlugin.sharedInstance?.queuePositionDidChange(for: conversationID, position: position)
    }
    
    func callStateDidChange(for state: MobilistenCallsCore.SalesIQCallState) {
        SwiftMobilistenCallsPlugin.sharedInstance?.callStateDidChange(for: state)
    }
    
    func callScreenDidAppear() {
        SwiftMobilistenCallsPlugin.sharedInstance?.callScreenDidAppear()
    }
    
    func callScreenDidDisappear() {
        SwiftMobilistenCallsPlugin.sharedInstance?.callScreenDidDisappear()
    }
    
    func callScreenDidEnterPiPMode() {
        SwiftMobilistenCallsPlugin.sharedInstance?.callScreenDidEnterPiPMode()
    }
    
    func callScreenDidEnterFullScreenMode() {
        SwiftMobilistenCallsPlugin.sharedInstance?.callScreenDidEnterFullScreenMode()
    }
    
    override init() {
        super.init()
    }
}
