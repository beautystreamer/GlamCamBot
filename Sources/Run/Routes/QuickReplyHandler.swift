import Foundation

extension Droplet {
    
    func handleQuickReply(payload: String, subscriber: Subscriber) {
        analytics?.logDebug("Quick reply payload = \(payload)")
        
        let quickReply = String(payload.split(separator: "|")[0])
        analytics?.logDebug(quickReply)
        
        if quickReply == POSTBACK_BOT_COUNT_ME_IN {
            handleSubscribe(subscriber: subscriber)
        } else {
            analytics?.logError("Unknown quick reply \(quickReply)")
        }
    }
}
