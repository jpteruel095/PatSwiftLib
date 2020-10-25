//
//  PatRequest.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Alamofire
import SwiftyJSON

public protocol PRequest{
    var path: String { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding? { get }
    
    var shouldLog: Bool { get }
    var shouldLogRequest: Bool { get }
    var shouldLogResponse: Bool { get }
}

public extension PRequest{
    var method: HTTPMethod { .get }
    var encoding: ParameterEncoding? { nil }
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
        var headers = HTTPHeaders([
//            HTTPHeader(name: "Accept", value: "application/json")
        ])
        
//        if !self.isGuest{
//            if let current = User.current,
//                let accessToken = current.accessToken{
//                headers["Authorization"] = "Bearer \(accessToken)"
//            }else{
//                return nil
//            }
//        }
//
//        if self.requiresWalletSession{
//            guard let session = WalletSession.current else{
//                return nil
//            }
//
//            headers["Wallet-Session-Id"] = session.session_id
//            headers["Wallet-Token-Id"] = session.tokenId
//        }
        
        return headers
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
    
    /**
     Calls the request for the specified Endpoint
     - parameters:
        - parameters: The parameters for the request.
        - progressCallback: Callback that returns the progress of the current request.
        - completion: Callback for the response of the request.
        - shouldLog: Specified to allow the current requet log before request and response.
        - shouldLogResult: If request is allowed to log, user can choose to not log the result.
     */
    func request(parameters: Parameters? = nil,
                 progressCallback:((Progress) -> Void)? = nil,
                 completion:((JSON?, Error?) -> Void)? = nil)
    {
        //Check for headers available for the route
        //If the current request is a guest,
        // the header is not null
        guard let headers = headers else {
            if let completion = completion{
                completion(nil, Helpers.makeError(with: "Unauthorized access. Token may have expired."))
                //must implement a force logout functionality here
            }
            return
        }
        
        //The developer can choose to log the request
        // or not.
        if shouldLog && shouldLogRequest{
            print("Request URL: \(url.absoluteString)")
            print("Header: \(headers.dictionary.toJSONString())")
            print("Method: \(method.rawValue)")
            if let parameters = parameters{
                print("Parameters: \(parameters.toJSONString())")
            }
        }
        
        //Starts executing the request in hear
        AF.request(url,
                method: method,
                parameters: parameters,
                encoding: parameterEncoding,
                headers: headers).downloadProgress(closure: { (progress) in
                //If the developer provided a callback for progress,
                // the callback will be called through here
                if let progressCallback = progressCallback{
                    print("progress: \(progress.fractionCompleted)")
                    DispatchQueue.main.async {
                        progressCallback(progress)
                    }
                }
        }).responseJSON(completionHandler: { (response) in
//            self.handleResponseJSON(parameters: parameters,
//                                    progressCallback: progressCallback,
//                                    completion: completion,
//                                    shouldLog: shouldLog,
//                                    shouldLogRequest: shouldLogRequest,
//                                    shouldLogResult: shouldLogResult,
//                                    response: response)
        })
    }
}
