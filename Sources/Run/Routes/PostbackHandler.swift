import Foundation
import Vapor

extension Droplet {
    
    func handlePostback(payload: String, subscriber: Subscriber) {
        analytics?.logDebug("Payload = \(payload)")
        let postback = String(payload.split(separator: "|")[0])
        
        if postback == POSTBACK_GET_STARTED {
            self.handleNewUserFlow(subscriber: subscriber)
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
    
    public func handleNewUserFlow(subscriber: Subscriber) {
        analytics?.logDebug("Entered - new user flow")
        analytics?.logAnalytics(event: .NewUserRegistered, for: subscriber)
        
        let greeting = joinNextShowGeneric(subscriber: subscriber)
        self.send(attachment: self.genericAttachment(elements: [greeting]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
}
