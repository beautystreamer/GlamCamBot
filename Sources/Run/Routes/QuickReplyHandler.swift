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
        } else if quickReply == POSTBACK_YES_PAYMENT{
            handlePaymentToWeb(subscriber: subscriber)
        } else if quickReply == POSTBACK_NO_PAYMENT{
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
        let host = "tailormadejane"
        let price = "30"
        let product = "tailormadejane_session20"
        
        // http://localhost:3000/?host=hannalee&user_id=123&price=345&product=1211211
        let url = "https://botprod.glamcam.live?host=" + host + "&user_id=" + subscriber.fb_messenger_id + "&price=" + price + "&product=" + product
        let seeNow = ["type": "web_url", "url": url, "title": "Yes"]
        let seeLater = ["type": "web_url", "url": "https://giveaways.glamcam.live/?host=tailormadejane", "title": "No"]
        let pollResults = drop.genericButtonsAttachment(message: "You have an hour to claim your spot for $" + price, buttons:[seeNow, seeLater])
        
        drop.send(attachment: pollResults,
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
        
    func handleNoPayment(subscriber: Subscriber){
        drop.send(message: "No worries",
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
}
