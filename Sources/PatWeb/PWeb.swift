//
//  PatWeb.swift
//  FBSnapshotTestCase
//
//  Created by John Patrick Teruel on 10/24/20.
//

import Foundation

public typealias AuthHeaderClosure = () -> String?
open class PWeb{
    public static var shared = PWeb(defaults: PWebDefaults(),
                                    authHeaderClosure: {""})
    public class func configure(domain: String,
                                scheme: String = "http",
                                authHeaderClosure: @escaping AuthHeaderClosure){
        shared = PWeb(defaults: PWebDefaults(domain: domain,
                                             scheme: scheme),
                      authHeaderClosure: authHeaderClosure)
    }
    
    var defaults: PWebDefaults
    var authHeaderClosure: AuthHeaderClosure
    init(defaults: PWebDefaults, authHeaderClosure: @escaping AuthHeaderClosure) {
        self.defaults = defaults
        self.authHeaderClosure = authHeaderClosure
    }
    
    public var runningRequests = 0{
        didSet{
            NSLog("Running \(runningRequests) requests")
        }
    }
}
