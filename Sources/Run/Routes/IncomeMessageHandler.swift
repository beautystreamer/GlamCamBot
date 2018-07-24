import Foundation

extension Droplet {
    
    func handleIncomeMessage(subscriber: Subscriber, incomingMessage: String? = nil) {
        analytics?.logDebug("Entered - existing user flow")
        if let message = incomingMessage {
            let lowercasedMessage = message.lowercased()
            analytics?.logIncomingMessage(subscriber: subscriber, message: message)
            if lowercasedMessage == "test payments" {
                let test = TestPayments(console: drop.console)
                do {
                    try test.run(arguments: [subscriber.fb_messenger_id])
                } catch let error {
                    analytics?.logError("Failed to proccess the payment: \(error)")
                    return
                }
            } else if lowercasedMessage == "test shopping" {
                let test = TestShopping(console: drop.console)
                do {
                    try test.run(arguments: [subscriber.fb_messenger_id])
                } catch let error {
                    analytics?.logError("Failed to proccess the shopping flow: \(error)")
                    return
                }
            } else if lowercasedMessage == "test app broadcast" {
                let test = TestAppBroadCast(console: drop.console)
                do {
                    //try test.run(arguments: [subscriber.fb_messenger_id])
                } catch let error {
                    analytics?.logError("Failed to proccess the app broadcast: \(error)")
                    return
                }
            } else if SubscriberStatus.isUnsubscribeMessage(message) {
                analytics?.logDebug("Entered - unsubscribe selected flow. Unsubscribe user if needed.")
                subscriber.setStatus(SubscriberStatus.unsubscribed)
                subscriber.saveIfNedeed()
                let message = "You just unsubscribed from notifications. To resubscribe, type \"subscribe\"."
                self.send(message: message, senderId: subscriber.fb_messenger_id, messagingType: .RESPONSE)
            } else if SubscriberStatus.isSubscribeMessage(message) {
                analytics?.logDebug("Entered - subscribe selected flow. Subscribe user if needed.")
                let message = "You are subscribed."
                subscriber.setStatus(SubscriberStatus.subscribed)
                subscriber.saveIfNedeed()
                self.send(message: message, senderId: subscriber.fb_messenger_id, messagingType: .RESPONSE)
            } else {
                analytics?.logDebug("Entered - unrecognized message")
            }
        } else {
            analytics?.logDebug("Entered - incoming message is nil. Ignore this message.")
        }
    }
}
