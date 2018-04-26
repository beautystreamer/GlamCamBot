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
        let host = "tailormadejane"
        let price = "30"
        let product = "tailormadejane_session20"
        let imageUrl = "https://public.boxcloud.com/api/2.0/internal_files/289851363753/versions/305057066073/representations/png_paged_2048x2048/content/1.png?access_token=1!3EWE1-hiJcsOAthouYmWx4-nhLrCot2jxi322DnITk0235ucOhieX_jN1W1WgDuWpq18aMptMPfP6JTXk_UViUpHMlrOEXz3jmFk23JdnaIARqpjK6jHdDuTndHOwb_GguT3wottK2C5etm4DCkBDUB8jSDutAwKUaZz47iSQaGFHCB7b7c_TFKzqAhz9Jmmwh0IgpAE7oK9Qh2b7Al9gWE06gKZ9pmW0Dze2Rpv2jXP0tmZD4ej7zXo638-MG6OzMfYRc5J9lkQG2wWN10rGnnLGxnVYZ9BS0GSDT13c41bo0tmDqUc7TLHYUneLbj73dk8-lUvsOyWqKb-7nTOISYliR39zrkoeW9pjrUoYR-Y_17ha8SoFI6cvU4aMK765cSYD63KP3hOYHfif6E.&box_client_name=box-content-preview&box_client_version=1.40.0"

        let botHostName = getBotHostName(config)
        
        let url = "\(botHostName)/web?host=\(host)&user_id=\(subscriber.fb_messenger_id)&price=\(price)&product=\(product)"

        let buttonClaimSpot = ["type": "web_url", "url": url, "title": "Claim your spot now"]
        let pollResults = drop.carouselElement(title: "Join Tailor made jane show", 
                                               imageUrl: imageUrl, 
                                               subtitle: "for only \(price)$ you can be on the next show", 
                                               button: buttonClaimSpot)
        
        drop.send(attachment: drop.genericAttachmentImageRatioSquare(elements: [pollResults]),
                  senderId: subscriber.fb_messenger_id,
                  messagingType: .NON_PROMOTIONAL_SUBSCRIPTION)
    }
        
    func handleNoPayment(subscriber: Subscriber){
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
