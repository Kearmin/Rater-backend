//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 11. 18..
//

import Foundation
import Fluent
import FluentMySQLDriver
import Vapor

final class Favourite: Model, Content {

    static let schema = "favourite"

    @ID(custom: "id", generatedBy: .database)
    var id: Int?
    
    @Parent(key: "userId")
    var user: User
    
    @Parent(key: "productId")
    var product: Product
    
    init() {}
    
    init(userId: Int, productId: Int) {
        self.$user.id = userId
        self.$product.id = productId
    }
}

extension Favourite {
    struct AddFavouriteMigration: Fluent.Migration {
        var name: String { "AddFavouriteTable" }
        
        func prepare(on database: Database) -> EventLoopFuture<Void> {
            database.schema("favourite")
                .field("id", .int, .identifier(auto: true))
                .field("userId", .int, .required, .references("user", "id", onDelete: .cascade, onUpdate: .cascade))
                .field("productId", .int, .required, .references("product", "id", onDelete: .cascade, onUpdate: .cascade))
                .create()
        }
        
        func revert(on database: Database) -> EventLoopFuture<Void> {
            database.schema("favourite")
                .delete()
        }
    }
}
