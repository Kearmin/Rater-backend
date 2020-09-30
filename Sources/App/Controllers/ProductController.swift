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
        let barcode: String
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
        
        return Product.query(on: req.db)
            .with(\.$ratings, { ratings in
                ratings.with(\.$user)
            })
            .filter(\.$id == id)
            .first()
            .unwrap(or: Abort(.notFound))
            .flatMapThrowing { product throws in

                return try ProductDetailDTO(id: product.requireID(), name: product.name, imageUrl: product.imageUrl, description: product.description, producer: product.description, uploaderId: product.uploaderId, barcode: product.barcode, createdAt: product.createdAt, ratings:
                    product.ratings.map { rating in
                        try RatingDTO(id: rating.requireID(), rating: rating.rating, text: rating.text, title: rating.title, userName: rating.user.accountName, userId: rating.user.requireID())
                    }
                , average: product.ratings.map{ $0.rating }.average)
            }
            .encodeResponse(for: req)
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
        product.barcode = content.barcode
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
            product.barcode = content.barcode
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


extension Array where Element: BinaryInteger {

    /// The average value of all the items in the array
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }
}
