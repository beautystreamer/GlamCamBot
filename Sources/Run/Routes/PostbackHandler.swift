import Foundation
import Vapor

extension Droplet {
    
    func handlePostback(payload: String, subscriber: Subscriber, user_ref: String?) {
        analytics?.logDebug("Payload = \(payload)")
        let postback = String(payload.split(separator: "|")[0])
        
        if postback == POSTBACK_GET_STARTED {
            self.handleNewUserFlow(subscriber: subscriber, user_ref: user_ref)
        } else if postback == POSTBACK_BOT_COUNT_ME_IN {
            handleSubscribe(subscriber: subscriber)
        } else if postback == POSTBACK_UNSUBSCRIBE_RESUBSCRIBE {
            handleUnsubscribeResubscribe(subscriber: subscriber)
            
        } else {
            analytics?.logDebug(postback)
        }
    }
    
    func handleUnsubscribeResubscribe(subscriber: Subscriber) {
        if SubscriberStatus.isSubscribeMessage(subscriber.status ?? "") {
            handleUnsubscribe(subscriber: subscriber)
        } else {
            handleSubscribe(subscriber: subscriber)
        }
    }
    
    func handleSubscribe(subscriber: Subscriber) {
        analytics?.logDebug("Entered - subscribe selected flow. Subscribe user.")
        subscriber.setStatus(.subscribed)
        subscriber.saveIfNedeed()
        self.send(message: "Awesome! You have entered for a chance to be on the next show, we will keep you posted.",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
        analytics?.logAnalytics(event: .SubscribeRequested, for: subscriber)
    }
    
    func handleUnsubscribe(subscriber: Subscriber) {
        analytics?.logDebug("Entered - unsubscribe selected flow. Unsubscribe user.")
        subscriber.setStatus(.unsubscribed)
        subscriber.saveIfNedeed()
        self.send(message: "You just unsubscribed from daily notifications.",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
        analytics?.logAnalytics(event: .UnsubscribeRequested, for: subscriber)
    }

    public func handleNewUserFlow(fb_messenger_id: String, user_ref: String?) {
        analytics?.logDebug("Entered - new user flow")
        analytics?.logEvent(eventString: fb_messenger_id, withValue: user_ref ?? "")
       
        if let ref = user_ref {
            let refDict = [
                "HannaLee": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf1y0s2l05ff0146mo69rlpd",
                "tailormadejane": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wajc05gt0146mzhwfbo3",
                "victoriajameson": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wkrk05gx01462mbge7hy",
                "princessbellaaa": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20xzfa05h101464w2b7m1k",
                ]
            if let url=refDict[ref], let imageAttachmentId = self.getAttachmentIdFor(url: url) {
                self.send(attachmentId: imageAttachmentId, senderId: fb_messenger_id, messagingType: .RESPONSE)
            }
        }
        
        let message = "Hey, thanks for signing up to be on the next show"
        self.send(message: message, senderId: fb_messenger_id, messagingType: .RESPONSE)
    }

    
    public func handleNewUserFlow(subscriber: Subscriber, user_ref: String?) {
        handleNewUserFlow(fb_messenger_id: subscriber.fb_messenger_id, user_ref: user_ref)
//        analytics?.logDebug("Entered - new user flow")
//        analytics?.logAnalytics(event: .NewUserRegistered, for: subscriber, eventValue: user_ref)
//
//        if let ref = user_ref {
//            let refDict = [
//                "HannaLee": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf1y0s2l05ff0146mo69rlpd",
//                "tailormadejane": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wajc05gt0146mzhwfbo3",
//                "victoriajameson": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wkrk05gx01462mbge7hy",
//                "princessbellaaa": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20xzfa05h101464w2b7m1k",
//                ]
//            if let url=refDict[ref], let imageAttachmentId = self.getAttachmentIdFor(url: url) {
//                self.send(attachmentId: imageAttachmentId, senderId: subscriber.fb_messenger_id, messagingType: .RESPONSE)
//            }
//        }
//
//        let message = "Hey \(subscriber.first_name), thanks for signing up to be on the next show"
//        self.send(message: message, senderId: subscriber.fb_messenger_id, messagingType: .RESPONSE)
    }
}
