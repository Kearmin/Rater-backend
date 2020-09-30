//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 08. 16..
//

import Foundation
import Vapor

struct TokenDTO: Content {
    let id: String
    let userId: Int
    let value: String
}
