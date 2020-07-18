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

final class User: Model, Content {
    
    static let schema = "user"
    
    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Field(key: "accountName")
    var accountName: String
    
    @Field(key: "password")
    var password: String
    
    init() {
        
    }
    
}
