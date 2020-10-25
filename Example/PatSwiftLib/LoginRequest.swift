//
//  LoginRequest.swift
//  PatSwiftLib_Example
//
//  Created by John Patrick Teruel on 10/25/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import PatSwiftLib
import Alamofire
import SwiftyJSON

struct LoginRequest: PRequest {
    typealias ResultingModel = JSON
    
    let path: String = "api/login"
    let method: HTTPMethod = .post
}
