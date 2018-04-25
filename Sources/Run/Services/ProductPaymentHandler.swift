import Foundation
import Vapor
import HTTP
import Node
import Jay
import Dispatch

extension Droplet {
    
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
        
//        offerPaymentOptionsWithLowCoinBalance(subscriber: subscriber)
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
                    //get a spot in the show
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
        }
    }
    
    func handleMessengerPurchase(subscriber: Subscriber,
                                 token: String,
                                 product: String,
                                 host: String,
                                 price: String,
                                 email: String?,
                                 remember: Bool) throws -> Response {
        if let result = stripeClient?.processChargeFor(subscriber: subscriber,
                                                       token: token,
                                                       description: "charge for \(product)",
                                                       amount: Int(price.int! * 100),
                                                       reusePaymentInfo: remember) {
            if result.status != .ok {
                let message = result.json?["error.message"]?.string  ?? "Unknown error, please try later"
                var errorDict = subscriber.toDictionary()
                errorDict["message"] = message
                analytics?.logResponse(result, endpoint: "stripe", dict: errorDict)
                return Response(status: result.status, body: message.makeBody())
            }
        }
        
        throw Abort.serverError
    }
    
}
