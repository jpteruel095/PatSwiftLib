//
//  PatWeb.swift
//  FBSnapshotTestCase
//
//  Created by John Patrick Teruel on 10/24/20.
//

import Foundation

open class PWeb{
    public static var shared = PWeb(defaults: PWebDefaults())
    public class func configure(with domain: String, scheme: String = "http"){
        shared = PWeb(defaults: PWebDefaults(domain: domain,
                                             scheme: scheme))
    }
    
    var defaults: PWebDefaults
    
    init(defaults: PWebDefaults) {
        self.defaults = defaults
    }
}
