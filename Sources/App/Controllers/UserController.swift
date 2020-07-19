//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 18..
//

import Foundation
import Vapor
import FluentMySQLDriver
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        
        routes.group("user") { route in
            route.post("signup", use: createUser)
            
            let userProtected = route.grouped(User.authenticator())
            userProtected.post("login", use: login)
            
            let tokenProtected = route.grouped(UserToken.authenticator())
            tokenProtected.get("me", use: me)
            tokenProtected.post("logout", use: logout)
        }

    }
    
    func createUser(_ req: Request) throws -> EventLoopFuture<User> {
        
        try User.Create.validate(req)
        
        let create = try req.content.decode(User.Create.self)
        
        let user = try User(accountName: create.accountName, password: Bcrypt.hash(create.password))
        
        return user.create(on: req.db).map {
            user
        }
    }

    func me(_ req: Request) throws -> EventLoopFuture<User> {
        
        let user = try req.auth.require(User.self)
        
        return req.eventLoop.makeSucceededFuture(user)
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        return token.save(on: req.db)
            .map { token }
            .encodeResponse(for: req)
    }
    
    func logout(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let user = try req.auth.require(User.self)
        
        return UserToken.query(on: req.db)
            .join(User.self, on: \UserToken.$user.$id == \User.$id)
            .filter(User.self, \.$id == user.id!)
            .first()
            .unwrap(or: Abort(.internalServerError))
            .flatMap { token -> EventLoopFuture<Response> in
                
                return token.delete(force: true, on: req.db)
                    .map {
                        HTTPResponseStatus.ok
                }.encodeResponse(for: req)
        }
    }
}
