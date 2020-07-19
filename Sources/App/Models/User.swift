//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 12..
//

import Foundation
import Fluent
import FluentMySQLDriver
import Vapor

final class User: Model, Content, Authenticatable {
    
    static let schema = "user"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "accountName")
    var accountName: String
    
    @Field(key: "password")
    var password: String
    
    init() {
        
    }
    
    init(accountName: String, password: String) {
        self.accountName = accountName
        self.password = password
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }    
}

extension User {
    struct Create: Content, Validatable {
        var accountName: String
        var password: String
        
        static func validations(_ validations: inout Validations) {
            validations.add("accountName", as: String.self, is: !.empty)
            validations.add("password", as: String.self, is: .count(6...))
        }
    }
    
    struct Migration: Fluent.Migration {
        var name: String { "CreateUser" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user")
                .field("id", .int, .identifier(auto: true))
                .field("accountName", .string, .required)
                .field("password", .string, .required)
                .unique(on: "accountName")
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("user").delete()
        }
    }
}


extension User: ModelAuthenticatable {
    static let usernameKey = \User.$accountName
    static let passwordHashKey = \User.$password
    
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.password)
    }
}
