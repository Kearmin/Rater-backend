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
            userProtected.post("adminLogin", use: adminLogin)
            
            let tokenProtected = route.grouped(UserToken.authenticator())
            tokenProtected.get("me", use: me)
            tokenProtected.get(":id", use: getUser)
            tokenProtected.post("logout", use: logout)
            tokenProtected.delete(":id", use: deleteUser)
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
    
    func getUser(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        return User.find(req.parameters.get("id"), on: req.db)
                .unwrap(or: Abort(.notFound))
                .encodeResponse(for: req)
    }
    
    func deleteUser(_ req: Request) throws -> EventLoopFuture<Response> {
        
        _ = try req.auth.require(User.self)
        
        let user = User.find(req.parameters.get("id"), on: req.db)
        return user.unwrap(or: Abort(.notFound)).flatMap { (user) -> EventLoopFuture<Response> in
            user.delete(force: true, on: req.db).flatMap { () -> EventLoopFuture<Response> in
                return HTTPResponseStatus.accepted.encodeResponse(for: req)
            }
        }
    }
    
    func me(_ req: Request) throws -> EventLoopFuture<User> {
        
        let user = try req.auth.require(User.self)
        
        return req.eventLoop.makeSucceededFuture(user)
    }
    
    private func handleLogin(_ req: Request, checkAdmin: Bool) throws -> EventLoopFuture<Response> {
        
        var user: User!
        do {
            user = try req.auth.require(User.self)
        } catch {
            throw Abort(.unauthorized, reason: "Username or password is invalid")
        }
                
        let token = try user.generateToken()
        
        if checkAdmin {
            guard user.isAdmin == true else {
                throw Abort(.unauthorized, reason: "Not admin account")
            }
        }

        return token
            .save(on: req.db)
            .flatMapThrowing { () -> TokenDTO in
                return try TokenDTO(id: token.requireID().uuidString, userId: token.$user.id, value: token.value)
            }
            .encodeResponse(for: req)
    }
    
    func login(_ req: Request) throws -> EventLoopFuture<Response> {
        
        return try handleLogin(req, checkAdmin: false)
    }
    
    func adminLogin(_ req: Request) throws -> EventLoopFuture<Response> {
        
        return try handleLogin(req, checkAdmin: true)
    }
    
    func logout(_ req: Request) throws -> EventLoopFuture<Response> {
        
        let user = try req.auth.require(User.self)

        return UserToken.query(on: req.db) //6c04uaFbcZ3r5kDEZGhymA==  //QthN3ltn7GmjbRA/NPnlLA==
            .with(\.$user)
            .filter(\.$user.$id == user.id!)
            .all()
            .flatMap { tokens in
                tokens.delete(force: true, on: req.db)
                    .map { _ in
                        HTTPResponseStatus.ok
                }
            }
            .encodeResponse(for: req)
    }
}
