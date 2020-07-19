//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 07. 18..
//

import Foundation
import Vapor

struct UserAuthenticator: BasicAuthenticator {
    
    typealias User = App.User
    
    func authenticate(basic: BasicAuthorization, for request: Request) -> EventLoopFuture<Void> {
        
        if basic.username == "test@vapor.codes" && basic.password == "secret" {
            
            let user = User()
            user.accountName = "testName"
            user.password = "testPass"
            
            request.auth.login(user)
        }
        return request.eventLoop.makeSucceededFuture(())
    }
}

struct BearerUserAuthenticator: BearerAuthenticator {
        
    typealias User = App.User
    
    func authenticate(bearer: BearerAuthorization, for request: Request) -> EventLoopFuture<Void> {
        if bearer.token == "test" {
            let user = User()
            user.accountName = "testName"
            user.password = "testPass"
            
            request.auth.login(user)
        }
        return request.eventLoop.makeSucceededFuture(())
    }
    
}
