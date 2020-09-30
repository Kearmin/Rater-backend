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
            
            route.get("users", use: getUserPage)
            route.get("ratings", use: getRatingPage)
            route.get("products", use: getProductPage)
            route.get("ratingsForProduct", use: getRatingPageForProduct)
            route.get("ratingsForUser", use: getRatingPageForUser)
            
        }
    }
    
    func getUserPage(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Product.GetProductPage.self)
        
        let query = User.query(on: req.db)
            .limit(content.pageSize)
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }

        if let userId = content.userId {
            query.filter(\.$id == userId)
        }
        
        if let searchText = content.searchText {
            query.group(.or) { group in
                group.filter(\.$accountName ~~ searchText)
                     .filter(\.$id == Int(searchText) ?? -1)
            }
        }
        
        return query.all().encodeResponse(for: req)
    }
    
    func getRatingPageForUser(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Rating.GetRatingPage.self)
        
        let query = Rating.query(on: req.db)
            .with(\.$product)
            .with(\.$user)
            .filter(\.$user.$id == content.id)
            .limit(content.pageSize)
            
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }
        
        return query.all().flatMapThrowing { ratings in
            
            try ratings.map { rating in
                try UserRatingsDTO(id: rating.requireID(), productImageUrl: rating.product.imageUrl, productName: rating.product.name, text: rating.text, rating: rating.rating)
            }
        }
        .encodeResponse(for: req)
    }
    
    func getRatingPage(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let content = try req.query.decode(Product.GetProductPage.self)
        
        let query = Rating.query(on: req.db)
            .with(\.$product)
            .with(\.$user)
        
        if let afterId = content.afterId {
            query.filter(\.$id > afterId)
        }
        
        if let userId = content.userId {
            query.filter(\.$user.$id == userId)
        }
        
        if let searchText = content.searchText {
            query.group(.or) { group in
                    group.filter(Product.self, \.$name ~~ searchText)
                         .filter(Product.self, \.$producer ~~ searchText)
                         .filter(Product.self, \.$barcode ~~ searchText)
                         .filter(Product.self, \.$id == Int(searchText) ?? -1)
            }
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
