//
//  LiveVideoUsers.swift
//  barebonesBot
//
//  Created by suvorov on 3/31/18.
//

import Foundation
import FluentProvider
import Fluent
import Vapor

final public class LiveVideoUsers: Model {
    public let storage = Storage()
    public let first_name: String
    public let last_name: String
    public let handle: String
    public var session_id: String
    public var auth_hash: String
    public var current_party_id: String
    
    public init(first_name: String, last_name: String, handle: String, session_id: String, auth_hash: String, current_party_id: String) {
        self.first_name = first_name
        self.last_name = last_name
        self.handle = handle
        self.session_id = session_id
        self.auth_hash = auth_hash
        self.current_party_id = current_party_id
    }
    
    public init(row: Row) throws {
        first_name = try row.get("first_name")
        last_name = try row.get("last_name")
        handle = try row.get("handle")
        session_id = try row.get("session_id")
        auth_hash = try row.get("auth_hash")
        current_party_id = try row.get("current_party_id")
    }
    
    public func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("first_name", first_name)
        try row.set("last_name", last_name)
        try row.set("handle", handle)
        try row.set("session_id", session_id)
        try row.set("auth_hash", auth_hash)
        try row.set("current_party_handle", current_party_id)
        
        return row
    }
}

extension LiveVideoUsers: Preparation {
    public static func prepare(_ database: Database) throws {
        try database.create(self) { subscribers in
            subscribers.string("first_name")
            subscribers.string("last_name")
            subscribers.string("locale")
            subscribers.string("handle", length: 255, optional: false, unique: true, default: nil)
            subscribers.string("session_id")
            subscribers.string("auth_hash")
            subscribers.string("current_party_handle")
        }
    }
    
    public static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension LiveVideoUsers: Timestampable { }
