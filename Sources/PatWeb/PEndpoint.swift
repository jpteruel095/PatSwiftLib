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
public typealias DefaultModel = JSON
public typealias WebMethod = HTTPMethod

public protocol PRoute{
    // MARK: Route properties
    var path: String { get }
    var method: WebMethod { get }
    var encoding: ParameterEncoding? { get }
    var requiresAuth: Bool { get }
    var additionalHeadersClosure: (() -> [HTTPHeader])? { get }
}

public protocol PEndpoint: PRoute{
    typealias RequestCompletionSingleClosure = (ResultModel?, Error?) -> Void
    typealias RequestCompletionMultipleClosure = ([ResultModel], Error?) -> Void
    
    associatedtype ResultModel
    associatedtype ParameterType: PParameters
    
    
    // MARK: Parameters
    var parameters: ParameterType? { get }
    
    // MARK: Request Handlers
    var dictionarySearchNestedKeys: [String] { get }
    func serializeResponse(with object: Any, completion:RequestCompletionMultipleClosure?)
    
    // MARK: Request Logging
    var shouldLog: Bool { get }
    var shouldLogRequest: Bool { get }
    var shouldLogResponse: Bool { get }
}

public extension PEndpoint where Self: PParameters, ParameterType == Self{
    var parameters: ParameterType? {
        return self
    }
}

public protocol PSEndpoint: PEndpoint where ParameterType == DefaultPParameter{
    
}

public extension PSEndpoint{
    var parameters: DefaultPParameter?{
        return nil
    }
}

public extension PEndpoint{
    // MARK: Route Extension
    var method: HTTPMethod { .get }
    var encoding: ParameterEncoding? { nil }
    var requiresAuth: Bool { true }
    var additionalHeadersClosure: (() -> [HTTPHeader])? { nil }
    
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
            
            if let closure = additionalHeadersClosure{
                let additionalHeaders = closure()
                if additionalHeaders.count > 0{
                    headers.append(contentsOf: additionalHeaders)
                }else{
                    return nil
                }
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
