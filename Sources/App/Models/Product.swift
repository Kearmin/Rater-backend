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

final class Product: Model, Content {
    
    static let schema = "product"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "imageUrl")
    var imageUrl: String?
    
    @Field(key: "description")
    var description: String
    
    @Field(key: "producer")
    var producer: String
    
    @Field(key: "uploaderId")
    var uploaderId: Int
    
    @Timestamp(key: "createdAt", on: .create, format: .unix)
    var createdAt: Date?
    
    @Children(for: \.$product)
    var ratings: [Rating]
    
    init() {
        
    }
}

extension Product {
    struct Migration: Fluent.Migration {
        var name: String { "CreateProduct" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("product")
                .field("id", .int, .identifier(auto: true))
                .field("name", .string, .required)
                .field("imageUrl", .string)
                .field("description", .string, .required)
                .field("producer", .string, .required)
                .field("uploaderId", .int, .required)
                .field("createdAt", .int, .required)
                .create()
        }
    
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("product").delete()
        }
    }
}
