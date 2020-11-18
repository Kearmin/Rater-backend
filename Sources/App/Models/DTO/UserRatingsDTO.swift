//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 08. 16..
//

import Foundation
import Vapor

struct UserRatingsDTO: Content {
    let id: Int
    let productImageUrl: String?
    let productName: String
    let title: String
    let text: String
    let rating: Int
}
