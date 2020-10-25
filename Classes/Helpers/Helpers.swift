//
//  Helpers.swift
//  Alamofire
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Foundation

public struct Helpers{
    static func makeError(with description: String, code: Int = 0) -> Error{
        NSError(domain: PWeb.shared.defaults.domain,
                       code: code,
                       userInfo: [NSLocalizedDescriptionKey: description])
    }
    
    static func makeOfflineError(code: Int = 0) -> Error{
        makeError(with: "You are currently offline.", code: code)
    }
    
    static func makeUserIDError(code: Int = 0) -> Error{
        makeError(with: "ID is not available on current user!", code: code)
    }
    
    static func makeEmployeeCDdError(code: Int = 0) -> Error{
        makeError(with: "Employee Code is not available on current user!", code: code)
    }
}
