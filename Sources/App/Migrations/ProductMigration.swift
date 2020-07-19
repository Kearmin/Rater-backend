//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 12..
//

import Foundation
import Fluent
import FluentMySQLDriver

//struct CreateProduct: Migration {
//    
//    func prepare(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("product")
//            .id()
//            .field("name", .string)
//            .field("imageUrl", .string)
//            .field("description", .string)
//            .field("producer", .string)
//            .field("uploaderId", .int)
//            .field("createdAt", .date)
//            .create()
//    }
//    
//    func revert(on database: Database) -> EventLoopFuture<Void> {
//        database.schema("product").delete()
//    }
//}
