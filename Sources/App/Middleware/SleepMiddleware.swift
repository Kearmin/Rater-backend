//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 11. 05..
//

import Vapor
import Foundation

// For testing purposes
struct SleepMiddleware: Middleware {
    
    let sleepDuration: UInt32
    
    init(sleepDuration: UInt32) {
        self.sleepDuration = sleepDuration
    }
    
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).always { _ in sleep(self.sleepDuration) }
    }
}
