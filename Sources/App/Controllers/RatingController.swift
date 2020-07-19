//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 18..
//

import Foundation
import Vapor
import Fluent
import FluentMySQLDriver

struct RatingController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.group("rating") { router in
            router.get(":id", use: getRating)
            
            let tokenProtected = router.grouped(UserToken.authenticator())
            tokenProtected.post(use: createRating)
            tokenProtected.put(":id", use: updateRating)
            tokenProtected.delete(":id", use: deleteRating)
        }
    }
    
    func getRating(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let idString = req.parameters.get("id")!
        
        guard let id = Int(idString) else {
            throw Abort(.badRequest)
        }
        
        return Rating.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
            .encodeResponse(for: req)
    }
    
    struct CreateRating: Content, Codable {
        
        let rating: Int
        let productId: Int
        let text: String
        let title: String
        let uploaderId: Int
    }
    
    func createRating(_ req: Request) throws -> EventLoopFuture<Response> {
    
        _ = try req.auth.require(User.self)
        
        let content = try req.content.decode(CreateRating.self)

        let rating = Rating.init()
        rating.rating = content.rating
        rating.title = content.title
        rating.text = content.text
        //rating.productId = content.productId
        //rating.uploaderId = content.uploaderId
        
        let productFuture =  Product.query(on: req.db).filter(\.$id == content.productId).first().unwrap(or: Abort(.badRequest))
        let userFuture = User.query(on: req.db).filter(\.$id == content.uploaderId).first().unwrap(or: Abort(.badRequest))
        
        return productFuture.and(userFuture).flatMap { product, user -> EventLoopFuture<Response> in
            
            rating.$user.id = user.id!
            return product.$ratings.create(rating, on: req.db).map{
                rating
            }.encodeResponse(for: req)
        }
    }
    
    func updateRating(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        let content = try req.content.decode(CreateRating.self)
        
        return Rating.find(req.parameters.get("id"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { rating -> EventLoopFuture<Response> in
            rating.rating = content.rating
            rating.title = content.title
            rating.text = content.text
            
            return rating.update(on: req.db).flatMap { (_) -> EventLoopFuture<Response> in
                return rating.encodeResponse(for: req)
            }
        }
    }
    
    func deleteRating(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        let rating = Rating.find(req.parameters.get("id"), on: req.db)
        
        return rating.unwrap(or: Abort(.notFound)).flatMap { rating -> EventLoopFuture<Response> in
            rating.delete(force: true, on: req.db).flatMap { (_) -> EventLoopFuture<Response> in
                return HTTPResponseStatus.accepted.encodeResponse(for: req)
            }
        }
    }
}
