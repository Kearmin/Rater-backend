//
//  File.swift
//  
//
//  Created by Kertész Jenő on 2020. 11. 05..
//

import Foundation
import Vapor

struct ProductPageDTO: Content {
    var id: Int
    var name: String
    var imageUrl: String?
    var description: String
    var producer: String
    var uploaderId: Int
    var uploaderName: String
}
