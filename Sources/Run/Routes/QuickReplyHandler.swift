import Foundation

extension Droplet {
    
    func handleQuickReply(payload: String, subscriber: Subscriber) {
        analytics?.logDebug("Quick reply payload = \(payload)")
        
        let quickReply = String(payload.split(separator: "|")[0])
        analytics?.logDebug(quickReply)
        
        if quickReply == POSTBACK_BOT_COUNT_ME_IN {
            handleSubscribe(subscriber: subscriber)
        } else if quickReply == QUICK_REPLY_GIVEAWAYS_OPT_IN {
            handleOptInIntoGiveaways(subscriber: subscriber)
        } else if quickReply == QUICK_REPLY_YES_PAYMENT{
            handlePaymentToWeb(subscriber: subscriber)
        } else if quickReply == QUICK_REPLY_NO_PAYMENT{
            handleNoPayment(subscriber: subscriber)
        } 
        else {
            analytics?.logError("Unknown quick reply \(quickReply)")
        }
    }
    
    func handleOptInIntoGiveaways(subscriber: Subscriber) {
        analytics?.logAnalytics(event: .OptIntoGiveaways, for: subscriber)
        subscriber.notify_about_giveaways = true
        subscriber.forceSave()
        
        let button = drop.weblinkButtonTemplate(title: "Follow us on IG",
                                                url: "https://www.instagram.com/glamcam.live/")
        let giveawayImageUrl = "https://app.box.com/shared/static/mwzeihp4qcsx4c7l0j5rg3uubnkbbqpk.jpg"
        let element = drop.getElement(title: "Join more giveaway shows",
                                      subtitle: "",
                                      buttons: [button],
                                      imageUrl: giveawayImageUrl)
        let attachment = drop.genericAttachment(elements: [element])
        drop.send(attachment: attachment,
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
    
    func handlePaymentToWeb(subscriber: Subscriber){
        let host = "hannalee"
        let price = "50"
        let product = "hannalee_session20"
        let imageUrl = "https://app.box.com/shared/static/1diiwqna8vsnkvb9yi2ottn981qhdo94.png"

        let botHostName = getBotHostName(config)
        
        let url = "\(botHostName)/web?host=\(host)&user_id=\(subscriber.fb_messenger_id)&price=\(price)&product=\(product)"

        let buttonClaimSpot = ["type": "web_url", "url": url, "messenger_extensions": "true", "title": "Claim your spot now"]
        let pollResults = drop.carouselElement(title: "Join Hanna Lee show", 
                                               imageUrl: imageUrl, 
                                               subtitle: "for only \(price)$ you can be on the next show", 
                                               button: buttonClaimSpot)
        analytics?.logAnalytics(event: .SubscribeRequested, for: subscriber)
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [pollResults]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
        
    func handleNoPayment(subscriber: Subscriber){
        analytics?.logAnalytics(event: .SubscribeRequested, for: subscriber)
        drop.send(message: "No worries",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
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
