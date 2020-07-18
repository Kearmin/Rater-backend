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
            router.post(use: createProduct)
            router.put(":id", use: updateProduct)
            router.delete(":id", use: deleteProduct)
        }
    }
    
    func getProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let idString = req.parameters.get("id")!
        
        guard let id = Int(idString) else {
            throw Abort(.badRequest)
        }
        
        return Product.query(on: req.db)
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
            .encodeResponse(for: req)
    }
    
    func createProduct(_ req: Request) throws -> EventLoopFuture<Response> {
        
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
        
        let product = Product.find(req.parameters.get("id"), on: req.db)
        return product.unwrap(or: Abort(.notFound)).flatMap { (product) -> EventLoopFuture<Response> in
            product.delete(force: true, on: req.db).flatMap { () -> EventLoopFuture<Response> in
                return HTTPResponseStatus.accepted.encodeResponse(for: req)
            }
        }
    }
}
