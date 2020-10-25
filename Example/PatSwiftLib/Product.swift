//
//  Product.swift
//  PatSwiftLib_Example
//
//  Created by John Patrick Teruel on 10/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import SwiftyJSON
import ObjectMapper

struct Product: Mappable{
    var id: Int
    var name: String
    
    init?(map: Map) {
        let json = JSON(map.JSON)
        guard
            let id = json["id"].int,
            let name = json["name"].string
        else{
            return nil
        }
        self.id = id
        self.name = name
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
