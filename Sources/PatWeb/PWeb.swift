//
//  PatWeb.swift
//  FBSnapshotTestCase
//
//  Created by John Patrick Teruel on 10/24/20.
//

import Foundation
import SwiftyJSON

public typealias AuthHeaderClosure = () -> String?
public typealias StatusN200DecisionHandler = (StatusN200Decision) -> Void
public typealias StatusCode = Int
public typealias ResponseResultJSON = JSON
public typealias StatusN200Handler = (PRoute, ResponseResultJSON?, StatusCode, @escaping StatusN200DecisionHandler) -> Bool
open class PWeb{
    public static var shared = PWeb(defaults: PWebDefaults(),
                                    authHeaderClosure: {""},
                                    statusN200Handler: nil)
    public class func configure(domain: String,
                                scheme: String = "http",
                                timeout: Double? = nil,
                                authHeaderClosure: @escaping AuthHeaderClosure,
                                statusN200Handler: StatusN200Handler?){
        shared = PWeb(defaults: PWebDefaults(domain: domain,
                                             scheme: scheme,
                                             timeout: timeout),
                      authHeaderClosure: authHeaderClosure, statusN200Handler: statusN200Handler)
    }
    
    var defaults: PWebDefaults
    var authHeaderClosure: AuthHeaderClosure
    var statusN200Handler: StatusN200Handler?
    
    init(defaults: PWebDefaults,
         authHeaderClosure: @escaping AuthHeaderClosure,
         statusN200Handler: StatusN200Handler?) {
        self.defaults = defaults
        self.authHeaderClosure = authHeaderClosure
        self.statusN200Handler = statusN200Handler
    }
    
    public var runningRequests = 0{
        didSet{
            NSLog("Running \(runningRequests) requests")
        }
    }
}

public enum StatusN200Decision {
    case proceed
    case complete
    case `repeat`
    case error(error: Error)
}
