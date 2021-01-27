//
//  WebDefaults.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Foundation

public struct PWebDefaults {
    var domain = "www.example.com"
    var scheme = "http"
    var timeout: Double?
    public var host: String{
        "\(scheme)://\(domain)/"
    }
}
