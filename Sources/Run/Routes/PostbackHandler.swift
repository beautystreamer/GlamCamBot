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
        } else if postback == POSTBACK_DONT_SHOW_ME_PRODUCTS {
            handleDontShowProducts(subscriber: subscriber)
        } else if postback == POSTBACK_YES_PAYMENT {
            handlePaymentToWeb(subscriber: subscriber)
        } else if postback == POSTBACK_NO_PAYMENT {
            handleNoPayment(subscriber: subscriber)
        } else if postback == POSTBACK_YES_APP {
            handleYesApp(subscriber: subscriber)
        } else if postback == POSTBACK_NO_APP {
            handleNoApp(subscriber: subscriber)
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
        analytics?.logAnalytics(event: .AgreedToSeeShoppingList, for: subscriber)
        
        let urlOne = "https://amzn.to/2KbW5LT"
        let titleOne = "Anastasia Beverly Hills - DIPBROW Pomade - Ebony"
        let subtitleOne = ""
        let imgUrlOne = "https://app.box.com/shared/static/hxl2fc6gmzahq8ndld20ix4kxoqh1a6k.jpg"
        let buttonBuyNowOne = ["type": "web_url", "title": "Buy on Amazon", "url": urlOne]
        let productOne = drop.carouselElement(title: titleOne, imageUrl: imgUrlOne, subtitle: subtitleOne, buttons: [buttonBuyNowOne])
        
        let urlTwo = "https://amzn.to/2Iz3GHl"
        let titleTwo = "Anastasia Beverly Hills - Stick Foundation - Ebony"
        let subtitleTwo = ""
        let imgUrlTwo = "https://app.box.com/shared/static/sl5ws906mdapauwrtmkrlvoloeim4uhk.jpg"
        let buttonBuyNowTwo = ["type": "web_url", "title": "Buy on Amazon", "url": urlTwo]
        let productTwo = drop.carouselElement(title: titleTwo, imageUrl: imgUrlTwo, subtitle: subtitleTwo, buttons: [buttonBuyNowTwo])
        
        let urlThree = "https://amzn.to/2Id2fLa"
        let titleThree = "Anastasia Beverly Hills - Blush Trios - Berry Adore"
        let subtitleThree = ""
        let imgUrlThree = "https://app.box.com/shared/static/esgr2hcqk2oqwbp3cga47btimxjjp63u.jpg"
        let buttonBuyNowThree = ["type": "web_url", "title": "Buy on Amazon", "url": urlThree]
        let productThree = drop.carouselElement(title: titleThree, imageUrl: imgUrlThree, subtitle: subtitleThree, buttons: [buttonBuyNowThree])
        
        let urlFour = "https://amzn.to/2Id2K80"
        let titleFour = "NARS Natural Radiant Longwear Foundation - Macao"
        let subtitleFour = ""
        let imgUrlFour = "https://app.box.com/shared/static/5wv2ixv6kymdogy1akwapuhtbr2t2u63.jpg"
        let buttonBuyNowFour = ["type": "web_url", "title": "Buy on Amazon", "url": urlFour]
        let productFour = drop.carouselElement(title: titleFour, imageUrl: imgUrlFour, subtitle: subtitleFour, buttons: [buttonBuyNowFour])
        
        let urlFive = "https://amzn.to/2wuGftT"
        let titleFive = "MAC Pro Longwear Powder/Pressed Dark Deep 0.39oz/11g"
        let subtitleFive = ""
        let imgUrlFive = "https://app.box.com/shared/static/he856emm86tbamkv73q0909zgjb39y98.jpg"
        let buttonBuyNowFive = ["type": "web_url", "title": "Buy on Amazon", "url": urlFive]
        let productFive = drop.carouselElement(title: titleFive, imageUrl: imgUrlFive, subtitle: subtitleFive, buttons: [buttonBuyNowFive])
        
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [productTwo, productOne, productThree, productFour, productFive]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func handlePaymentToWeb(subscriber: Subscriber){
        let host = "hannalee"
        let price = "30"
        let product = "hannalee_session20"
        let imageUrl = "https://app.box.com/shared/static/1diiwqna8vsnkvb9yi2ottn981qhdo94.png"
        
        let botHostName = getBotHostName(config)
        
        let url = "\(botHostName)/web?host=\(host)&user_id=\(subscriber.fb_messenger_id)&price=\(price)&product=\(product)&event=1"
        let url2 = "\(botHostName)/web?host=\(host)&user_id=\(subscriber.fb_messenger_id)&price=\(price)&product=\(product)&event=2"
        
        let buttonBookClassOne = ["type": "web_url", "url": url, "messenger_extensions": "true", "title": "Book Your Class"]
        let buttonBookClassTwo = ["type": "web_url", "url": url2, "messenger_extensions": "true", "title": "Book Your Class"]
        let bookClassOne = drop.carouselElement(title: "Thursday 7pm CST",
                                                imageUrl: imageUrl,
                                                subtitle: "for only \(price)$ you can join the class",
            button: buttonBookClassOne)
//        let bookClassTwo = drop.carouselElement(title: "Saturday May 12 4pm CT",
//                                                imageUrl: imageUrl,
//                                                subtitle: "for only \(price)$ you can join the class",
//            button: buttonBookClassTwo)
        analytics?.logAnalytics(event: .StartedToPurchaseTheShow, for: subscriber)
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [bookClassOne]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func handleNoPayment(subscriber: Subscriber){
        analytics?.logAnalytics(event: .RefusedToPurchaseTheShow, for: subscriber)
        drop.send(message: "No worries",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func handleDontShowProducts(subscriber: Subscriber){
        analytics?.logAnalytics(event: .RefusedToSeeShoppingList, for: subscriber)
        drop.send(message: "No worries",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func handleYesApp(subscriber: Subscriber){
        analytics?.logAnalytics(event: .AgreedToInstallApp, for: subscriber)
        drop.send(message: "Great! Sign up here - https://glamcam1.typeform.com/to/LTbNtx",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func handleNoApp(subscriber: Subscriber){
        analytics?.logAnalytics(event: .RefusedToInstallApp, for: subscriber)
        drop.send(message: "No worries, if you change your mind you can always use this link - https://glamcam1.typeform.com/to/LTbNtx",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .RESPONSE)
    }
    
    func getBotHostName(_ config: Config) -> String {
        let key = "bot_host_name"
        let token = config["appkeys", key]?.string
        if token == nil {
            analytics?.logError("FAILED TO GET \(key) from configuration files!")
        }
        
        return token!
    }
}
