//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 08. 15..
//

import Foundation
import Vapor

struct ProductDetailDTO: Content {
    var id: Int?
    var name: String
    var imageUrl: String?
    var description: String
    var producer: String
    var uploaderId: Int
    var barcode: String
    var createdAt: Date?
    var ratings: [RatingDTO]
    var average: Double
}
