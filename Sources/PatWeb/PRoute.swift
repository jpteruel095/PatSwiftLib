//
//  Route.swift
//  FBSnapshotTestCase
//
//  Created by John Patrick Teruel on 10/24/20.
//

import Alamofire

public struct PRoute{
    public let path: String
    public var method: HTTPMethod? = nil
    public var parameterEncoding: ParameterEncoding? = nil
    
    public var url: URL{
        return URL(string: "\(PWeb.shared.defaults.host)\(self.path)")!
    }
}
