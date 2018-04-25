//Payment DB model:
//<fk> customer DB
//<pk> transaction ID from Stripe
//<last 4 digits of card> STRING
//<int> price paid ($1.99 should be 199)

import Foundation
import FluentProvider
import Fluent
import Vapor

final public class StripeCharge: Model {
    public let storage = Storage()
    public static let idKey = "charge_id"
    
    public var charge_id: String
    public let payment_info: String
    public let price: Int
    public let stripe_customer_id: String
    
    public init(charge_id: String, payment_info: String, price: Int, stripe_customer_id: String) {
        self.charge_id = charge_id
        self.payment_info = payment_info
        self.price = price
        self.stripe_customer_id = stripe_customer_id
    }
    
    public var id: Identifier? {
        get {
            return Identifier(.string(self.charge_id), in: nil)
        }
        set {
            self.charge_id = (newValue?.string)!
        }
    }
    
    public init(row: Row) throws {
        charge_id = try row.get("charge_id")
        payment_info = try row.get("payment_info")
        price = try row.get("price")
        stripe_customer_id = try row.get("stripe_customer_id")
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("charge_id", charge_id)
        try row.set("payment_info", payment_info)
        try row.set("price", price)
        try row.set("stripe_customer_id", stripe_customer_id)

        return row
    }
    
    public func toDictionary() -> [String: Any] {
        return [
            "charge_id": charge_id,
            "payment_info": payment_info,
            "price": price,
            "stripe_customer_id": stripe_customer_id,
        ]
    }
}

extension StripeCharge: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.string("charge_id")
            table.string("payment_info")
            table.int("price")
            table.string("stripe_customer_id")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension StripeCharge: Timestampable { }
