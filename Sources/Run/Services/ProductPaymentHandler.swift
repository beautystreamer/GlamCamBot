import Foundation
import Vapor
import HTTP
import Node
import Jay
import Dispatch

extension Droplet {
    func priceAndCoinsForPriceString(_ price: String) -> (Double, Int)? {
        if price == "1.99" {
            return (1.99, 3)
        } else if price == "9.99" {
            return (9.99, 18)
        }
        
        return nil
    }
    
    func priceForCoins(_ coins: Int) -> (String, Double) {
        if coins == 3 {
            return ("1.99", 1.99)
        } else if coins == 18 {
            return ("9.99", 9.99)
        }
        
        return ("n/a", 0)
    }
    
    func priceForCode(_ code: String) -> (String, Double) {
        if code == "earliestadopters" {
            return ("3.50", 3.50)
        } else if code == "jan" {
            return ("3.99", 3.99)
        } else if code == "earlyadopters" {
            return ("4.99", 4.99)
        } else if code == "friendsandfamily" {
            return ("1.99", 1.99)
        } else if code == "nightglide399" {
            return ("3.99", 3.99)
        } else if code == "nightglide299" {
            return ("2.99", 2.99)
        } else if code == "nightglide199" {
            return ("1.99", 1.99)
        }
        
        return ("1.99", 1.99)
    }
    
    func handleChangeDefaultPayment(subscriber: Subscriber) {
        subscriber.stripe_customer_id = nil
        subscriber.remember_card_on_file = false
        subscriber.forceSave()
        
        offerPaymentOptionsWithLowCoinBalance(subscriber: subscriber)
    }
    
    func buyCoinsForExistingClient(subscriber: Subscriber, coins: Int, product: String) {
        analytics?.logDebug("Entered buyCoinsForExistingClient")
        guard let stripe_customer_id = subscriber.stripe_customer_id else {
            analytics?.logError("Can't process purchase for existing client with missing stripe_customer_id")
            self.send(message: "Something went wrong. Please request your horoscope again.",
                      senderId: subscriber.fb_messenger_id,
                      messagingType: .RESPONSE)
            return
        }
        
        let (_, price) = self.priceForCoins(coins)
        processPaymentWithCardOnFile(subscriber: subscriber, price: price, product: product, stripeCustomerId: stripe_customer_id)
    }
    
    func handleExistingClientPurchaseFlow(subscriber: Subscriber, code: String, product: String) {
        analytics?.logDebug("Entered handleExistingClientPurchaseFlow")
        guard let stripe_customer_id = subscriber.stripe_customer_id else {
            analytics?.logError("Can't process purchase for existing client with missing stripe_customer_id")
            self.send(message: "Something went wrong. Please request your horoscope again.",
                      senderId: subscriber.fb_messenger_id,
                      messagingType: .RESPONSE)
            return
        }
        
        let (_, price) = self.priceForCode(code)
        processPaymentWithCardOnFile(subscriber: subscriber, price: price, product: product, stripeCustomerId: stripe_customer_id)
    }
    
    func processPaymentWithCardOnFile(subscriber: Subscriber, price: Double, product: String, stripeCustomerId: String) {
        if let response = stripeClient?.stripeCharge(subscriber: subscriber,
                                                     description: product,
                                                     amount: Int(price * 100),
                                                     stripeCustomerId: stripeCustomerId) {
            if response.status == .ok {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    analytics?.logAnalytics(event: .CompletedPurchase,
                                            for: subscriber,
                                            eventValue: stripeCustomerId)
                    self.deliverTo(subscriber: subscriber)
                }
            } else {
                handleStripeClientChargeFailure(subscriber: subscriber,
                                                stripe_customer_id: stripeCustomerId)
            }
        } else {
            handleStripeClientChargeFailure(subscriber: subscriber,
                                            stripe_customer_id: stripeCustomerId)
        }
        
    }
    
    func handleStripeClientChargeFailure(subscriber: Subscriber, stripe_customer_id: String) {
        analytics?.logError("Failed to charge \(subscriber), stripe_client_id=\(stripe_customer_id)")
        
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            subscriber.stripe_customer_id = nil
            subscriber.remember_card_on_file = false
            let descriptionSentences = ["Something went wrong. Let's try again."]
            
            self.sendResponseWithTyping(
                messages: descriptionSentences,
                senderId: subscriber.fb_messenger_id,
                completion: {
                    let dateString = Utils.dateStringFor(subscriber: subscriber)
                    let attachment = self.privateReadingUpsellJSON(subscriber: subscriber,
                                                                   dateString: dateString)
                    self.send(attachment: attachment,
                              senderId: subscriber.fb_messenger_id,
                              messagingType: .RESPONSE)
            })
        }
    }
    
    func handleMessengerPurchase(subscriber: Subscriber,
                                 token: String,
                                 price: String,
                                 email: String?,
                                 remember: Bool) throws -> Response {
        guard let (amount, coins) = self.priceAndCoinsForPriceString(price) else {
            throw Abort.badRequest
        }
        
        if let result = stripeClient?.processChargeFor(subscriber: subscriber,
                                                       token: token,
                                                       description: "coin_reading",
                                                       amount: Int(amount*100),
                                                       reusePaymentInfo: remember) {
            if result.status != .ok {
                let message = result.json?["error.message"]?.string  ?? "Unknown error, please try later"
                var errorDict = subscriber.toDictionary()
                errorDict["message"] = message
                analytics?.logResponse(result, endpoint: "stripe", dict: errorDict)
                return Response(status: result.status, body: message.makeBody())
            } else {
                // add new coins and immeditely subtract from the customer question price
                let coinBump = coins -  DEFAULT_QUESTION_COIN_PRICE
                subscriber.coins += coinBump
                analytics?.logDebug("Added \(coinBump) coins to \(subscriber).")
                subscriber.forceSave()
                analytics?.logAnalytics(event: .CompletedPurchase, for: subscriber, eventValue: email)
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    self.deliverTo(subscriber: subscriber)
                }
                return result
            }
        }
        
        throw Abort.serverError
    }
    
    func deliverTo(subscriber: Subscriber) {
        let firstLine = "Great! Your live reading will begin shortly and last about 5 minutes. To get started, we’ll need..."
        let secondLine = "1. Your date, time, and location of birth.\n2. A question or topic you want to explore."
        
        slack?.sendTextToSlack(subscriber.description, host: getSlackHostName())
        
        sendResponseWithTyping(
            messages: [firstLine],
            senderId: subscriber.fb_messenger_id,
            completion: {
                self.send(message: secondLine, senderId: subscriber.fb_messenger_id, messagingType: .RESPONSE)
        })
    }
    
}
