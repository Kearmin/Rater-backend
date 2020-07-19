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

final class Rating: Model, Content {
    
    static let schema = "rating"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "rating")
    var rating: Int
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "title")
    var title: String
        
    @Timestamp(key: "createdAt", on: .create, format: .unix)
    var createdAt: Date?
    
    @Parent(key: "uploaderId")
    var user: User
    
    @Parent(key: "productId")
    var product: Product
    
    init() {
        
    }
    
}

extension Rating {
    struct Migration: Fluent.Migration {
        var name: String { "CreateRating" }

        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("rating")
                .field("id", .int, .identifier(auto: true))
                .field("productId", .int, .required, .references("product", "id"))
                .field("uploaderId", .int, .required, .references("user", "id"))
                .field("rating", .int, .required)
                .field("text", .string, .required)
                .field("title", .string, .required)
                .field("createdAt", .date, .required)
                .create()
        }

        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("rating").delete()
        }
    }
}
