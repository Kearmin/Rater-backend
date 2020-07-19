//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 19..
//

import Foundation
import Vapor
import Fluent
import FluentMySQLDriver

struct PagesController: RouteCollection {

    func boot(routes: RoutesBuilder) throws {
        
        routes.group("pages") { route in
            
            route.get("products", use: getProductPage)
            route.get("ratingsForProduct", use: getRatingPageForProduct)
            route.get("ratingsForUser", use: getRatingPageForUser)
            
        }
    }
    
    func getRatingPageForUser(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Rating.GetRatingPage.self)
        
        let query = Rating.query(on: req.db)
            .join(User.self, on: \Rating.$user.$id == \User.$id)
            .filter(User.self, \.$id == content.id)
            
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }
        
        return query.limit(content.pageSize).all().encodeResponse(for: req)
    }
    
    func getRatingPageForProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Rating.GetRatingPage.self)
        
        let query = Rating.query(on: req.db)
            .join(Product.self, on: \Rating.$product.$id == \Product.$id)
            .filter(Product.self, \.$id == content.id)
            
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }
        
        return query.limit(content.pageSize).all().encodeResponse(for: req)
    }
    
    func getProductPage(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Product.GetProductPage.self)
        
        let query = Product.query(on: req.db)
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }
        
        if let userId = content.userId {
            query.filter(\.$uploaderId == userId)
        }
        
        if let searchText = content.searchText {
            query.group(.or) { group in
                group.filter(\.$name ~~ searchText)
                     .filter(\.$producer ~~ searchText)
                     .filter(\.$barcode ~~ searchText)
            }
        }
        
        return query.limit(content.pageSize).all().encodeResponse(for: req)
    }
}
