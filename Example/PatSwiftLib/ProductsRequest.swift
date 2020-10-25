//
//  ProductRequest.swift
//  PatSwiftLib_Example
//
//  Created by John Patrick Teruel on 10/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import PatSwiftLib
import Alamofire

struct ProductsRequest: PRequest {
    typealias ResultingModel = Product
    
    let path: String = "api/products"
}
