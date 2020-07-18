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
    
    @Field(key: "productId")
    var productId: Int
    
    @Field(key: "rating")
    var rating: Int
    
    @Field(key: "text")
    var text: String
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "uploaderId")
    var uploaderId: Int
    
    @Timestamp(key: "createdAt", on: .create, format: .unix)
    var createdAt: Date?
    
    init() {
        
    }
    
}
