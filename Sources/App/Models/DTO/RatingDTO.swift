//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 08. 16..
//

import Foundation
import Vapor

struct RatingDTO: Content {
    
    let id: Int?
    let rating: Int
    let text: String
    let title: String
    let userName: String
    let userId: Int
}
