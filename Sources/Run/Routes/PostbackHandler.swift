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
        } else if postback == POSTBACK_SHOW_ME_PRODUCTS {
            handleShowProducts(subscriber: subscriber)
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
        self.send(message: "Awesome! See you soon!",
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

        let giveaway = "giveaway_giveaway"

        if let ref = user_ref {
            let refDict = [
                "HannaLee": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf1y0s2l05ff0146mo69rlpd",
//                "tailormadejane": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wajc05gt0146mzhwfbo3",
                "tailormadejane": "https://app.box.com/shared/static/jpy2almizs84quzz06xvfrnxbiulzadu.png",
                "victoriajameson": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20wkrk05gx01462mbge7hy",
                "princessbellaaa": "https://files.graph.cool/cjf1vq5cz26lh010048bqfrow/cjf20xzfa05h101464w2b7m1k",
                giveaway: "https://app.box.com/shared/static/mwzeihp4qcsx4c7l0j5rg3uubnkbbqpk.jpg",
                "joshalexmua_giveaway": "https://files.graph.cool/cjd9n1xrl1er90167eyl9ib07/cjgcrlz4o043201554ajxa02x",
                "hannalee_giveaway": "https://app.box.com/shared/static/7rg06a35ezf6fpn2lewqkvpee4n72a77.png",
                "tailormadejane_giveaway": "https://files.graph.cool/cjd9n1xrl1er90167eyl9ib07/cjgcrlz4o043201554ajxa02x",
                ]

            var title = "GLAMCAM GIVEAWAY!"
            var subtitle = "lots of amazing products"
            var buttonTitle = "Enter The Giveaway"


            if ref == giveaway {
                // do nothing, default are good
            } else if ref == "hannalee_giveaway" || ref == "joshalexmua_giveaway" || ref == "tailormadejane_giveaway" {
                subtitle = "Win $50 Sephora gift card"
            } else {
                let nameDict = [
                    "HannaLee": "HannaLee",
                    "tailormadejane": "TAILORMADEJANE",
                    "victoriajameson": "Victoria Jameson",
                    "princessbellaaa": "Princess Bellaaa",
                    ]

                let name = nameDict[ref] ?? ""

                title = (ref == "tailormadejane") ? "TAILORMADEJANE GIVEAWAY!" : "Hey, thanks for signing up to be on the next show"
                subtitle = (ref == "tailormadejane") ? "2 Jaclyn hill pallets 1 morphe 350" : "Thanks for watching the \(name) GLAMCAM show"
                buttonTitle = (ref == "tailormadejane") ? "Enter The Giveaway" : "Join the next show"
            }

            if let url = refDict[ref] {
                let greeting = carouselElement(title: title, imageUrl: url, subtitle: subtitle, buttonTitle: buttonTitle)
                self.send(attachment: self.genericAttachment(elements: [greeting]),
                          senderId: fb_messenger_id,
                          messagingType: .RESPONSE)
            } else {
                let message = "Hey, thanks for signing up to be on the next show"
                self.send(message: message, senderId: fb_messenger_id, messagingType: .RESPONSE)
            }
        } else {
            let message = "Hey, thanks for signing up to be on the next show"
            self.send(message: message, senderId: fb_messenger_id, messagingType: .RESPONSE)
        }

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
    
    public func handleShowProducts(subscriber: Subscriber){
        let url = "https://amzn.to/2HioF1k"
        let price = 1.49
        let title = "E.l.f. Moisturizing Lipstick\nRavishing Rose, 0.11 Ounce"
        let subtitle = "$\(price)"
        let buttonBuyNow = ["type": "web_url", "title": "BUY NOW", "url": url]
        let imgUrl = "https://images-na.ssl-images-amazon.com/images/I/31VobMBuK9L.jpg"
        let elements = drop.carouselElement(title: title, imageUrl: imgUrl, subtitle: subtitle, buttons: [buttonBuyNow])
        analytics?.logAnalytics(event: .SubscribeRequested, for: subscriber)
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [elements]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
}
