//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 12..
//

import Foundation
import Vapor
import Fluent
import FluentMySQLDriver


struct ProductController: RouteCollection {
    
    struct CreateProduct: Content, Codable {
        
        let name: String
        let description: String
        let imageUrl: String?
        let producer: String
        let uploaderId: Int
    }
    
    func boot(routes: RoutesBuilder) throws {
       
        routes.group("product") { router in
         
            router.get(":id", use: getProduct)
            
            let tokenProtected = router.grouped(UserToken.authenticator())
    
            tokenProtected.post(use: createProduct)
            tokenProtected.put(":id", use: updateProduct)
            tokenProtected.delete(":id", use: deleteProduct)
        }
    }
    
    func getProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let idString = req.parameters.get("id")!
        
        guard let id = Int(idString) else {
            throw Abort(.badRequest)
        }
        
        let productFuture = Product.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))

        return productFuture.flatMap { product -> EventLoopFuture<Response> in

            let ratings = product.$ratings.get(on: req.db)
            
            return productFuture.and(ratings).flatMap { (product, ratings) -> EventLoopFuture<Response> in
                return product.encodeResponse(for: req)
            }
        }
    }
    
    func createProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        guard let content = try? req.content.decode(CreateProduct.self) else {
            throw Abort(.badRequest)
        }
        
        let product = Product.init()
        product.name = content.name
        product.description = content.description
        product.imageUrl = content.imageUrl
        product.producer = content.producer
        product.uploaderId = content.uploaderId
        
        return product.create(on: req.db).flatMap { (_) -> EventLoopFuture<Response> in
            return product.encodeResponse(for: req)
        }
    }
    
    func updateProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        guard let content = try? req.content.decode(CreateProduct.self) else {
            throw Abort(.badRequest)
        }
        
        return Product.find(req.parameters.get("id"), on: req.db).unwrap(or: Abort(.notFound)).flatMap { product -> EventLoopFuture<Response> in
            product.name = content.name
            product.description = content.description
            product.imageUrl = content.imageUrl
            product.producer = content.producer
            product.uploaderId = content.uploaderId
            return product.update(on: req.db).flatMap { (_) -> EventLoopFuture<Response> in
                return product.encodeResponse(for: req)
            }
        }
        
    }
    
    func deleteProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        let product = Product.find(req.parameters.get("id"), on: req.db)
        return product.unwrap(or: Abort(.notFound)).flatMap { (product) -> EventLoopFuture<Response> in
            product.delete(force: true, on: req.db).flatMap { () -> EventLoopFuture<Response> in
                return HTTPResponseStatus.accepted.encodeResponse(for: req)
            }
        }
    }
}
