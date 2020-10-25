//
//  PatRequest.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Alamofire
import SwiftyJSON
import ObjectMapper

public typealias OptionalParameters = [String: Any?]

public protocol PRequest{
    typealias RequestCompletionSingleClosure = (ResultingModel?, Error?) -> Void
    typealias RequestCompletionMultipleClosure = ([ResultingModel], Error?) -> Void
    
    associatedtype ResultingModel = JSON
    
    // MARK: Route properties
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding? { get }
    var requiresAuth: Bool { get }
    
    // MARK: Parameters customization
    var excludedKeys: [String] { get }
    var includedKeys: [String] { get }
    var additionalParameters: OptionalParameters { get }
    
    // MARK: Request Handlers
    var dictionarySearchNestedKeys: [String] { get }
    func serializeResponse(with object: Any, completion:RequestCompletionMultipleClosure?)
    
    // MARK: Request Logging
    var shouldLog: Bool { get }
    var shouldLogRequest: Bool { get }
    var shouldLogResponse: Bool { get }
}

public extension PRequest{
    // MARK: Route Extension
    var method: HTTPMethod { .get }
    var encoding: ParameterEncoding? { nil }
    var requiresAuth: Bool { true }
    
    // MARK: Request Handlers
    var dictionarySearchNestedKeys: [String] { [] }
    
    // MARK: Request Logging
    var shouldLog: Bool { true }
    var shouldLogRequest: Bool { true }
    var shouldLogResponse: Bool { true }
    
    var url: URL{
        return URL(string: "\(PWeb.shared.defaults.host)\(self.path)")!
    }
    
    /**
     Returns the headers for specific endpoints. If the endpoint is a guest endpoint and no token is saved,
     the header is null.
     */
    var headers: HTTPHeaders?{
        var headers = [HTTPHeader]()
        
        if requiresAuth{
            if let accessToken = PWeb.shared.authHeaderClosure(){
                headers.append(HTTPHeader(name: "Authorization",
                                          value: "Bearer \(accessToken)"))
            }else{
                return nil
            }
        }
        
        return HTTPHeaders(headers)
    }
    
    var parameterEncoding: ParameterEncoding{
        if let encoding = self.encoding{
            return encoding
        }else{
            if self.method == .post{
                return JSONEncoding.default
            }else{
                return URLEncoding.default
            }
        }
    }
}
