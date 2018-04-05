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
        } else {
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
}
