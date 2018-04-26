import Foundation
import FluentProvider
import Fluent
import Vapor

final public class StripeCustomer: Model {
    public let storage = Storage()
    
    public static let idKey = "stripe_customer_id"

    public var stripe_customer_id: String
    public var default_paymet_info: String
    public let user_id: String
    
    public var id: Identifier? {
        get {
            return Identifier(.string(self.stripe_customer_id), in: nil)
        }
        set {
            self.stripe_customer_id = newValue?.string ?? "n/a"
        }
    }
    
    public init(stripe_customer_id: String, default_payment_info: String = "n/a", user_id: String) {
        self.stripe_customer_id = stripe_customer_id
        self.default_paymet_info = default_payment_info
        self.user_id = user_id
    }
    
    public init(row: Row) throws {
        stripe_customer_id = try row.get("stripe_customer_id")
        default_paymet_info = try row.get("default_paymet_info")
        user_id = try row.get("user_id")
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("stripe_customer_id", stripe_customer_id)
        try row.set("default_paymet_info", default_paymet_info)
        try row.set("user_id", user_id)
        
        return row
    }
    
    public func toDictionary() -> [String: Any] {
        let dict: [String: Any] = [
            "stripe_customer_id": stripe_customer_id,
            "default_paymet_info": default_paymet_info,
            "user_id": user_id
        ]
        
        return dict
    }
}

extension StripeCustomer: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { table in
            table.string("stripe_customer_id", unique: true)
            table.string("default_payment_info")
            table.string("user_id")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension StripeCustomer: Timestampable { }

extension StripeCustomer: CustomDebugStringConvertible {
    public var description: String {
        return "stripe_customer_id=\(stripe_customer_id) \(self.default_paymet_info) user_id=\(self.user_id)"
    }
    
    public var debugDescription: String {
        return  description
    }
}
