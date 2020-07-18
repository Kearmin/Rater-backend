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
    
    init() {
        
    }
    
}
