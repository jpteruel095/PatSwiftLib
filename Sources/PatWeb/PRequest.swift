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
    typealias RequestCompletionClosure = ([ResultingModel], Error?) -> Void
    
    associatedtype ResultingModel
    
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
    func serializeResponse(with object: Any, completion:RequestCompletionClosure?)
    
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
    
    /**
     Calls the request for the specified Endpoint
     - parameters:
        - parameters: The parameters for the request.
        - progressCallback: Callback that returns the progress of the current request.
        - completion: Callback for the response of the request.
        - shouldLog: Specified to allow the current requet log before request and response.
        - shouldLogResult: If request is allowed to log, user can choose to not log the result.
     */
    func request(progressCallback:((Progress) -> Void)? = nil,
                 completion:RequestCompletionClosure? = nil)
    {
        //Check for headers available for the route
        //If the current request is a guest,
        // the header is not null
        guard let headers = headers else {
            if let completion = completion{
                completion([], Helpers.makeError(with: "Unauthorized access. Token may have expired."))
                //must implement a force logout functionality here
            }
            return
        }
        
        //The developer can choose to log the request
        // or not.
        if shouldLog && shouldLogRequest{
            print("Request URL: \(url.absoluteString)")
            if headers.count > 0{
                print("Header: \(headers.dictionary.toJSONString())")
            }
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
            self.handleResponse(parameters: parameters,
                                    response: response,
                                    progressCallback: progressCallback,
                                    completion: completion)
        })
    }
    
    fileprivate func handleResponse(parameters: Parameters? = nil,
                                        response: DataResponse<Any, AFError>,
                                        progressCallback:((Progress) -> Void)? = nil,
                                        completion:RequestCompletionClosure? = nil)
    {
        //The developer can choose to log the result specifically.
        // If the logging of request was disabled by default,
        // The result will not be logged either.
        if shouldLog && shouldLogResponse{
            print("Response for URL: \(url.absoluteString)")
            do{
                let raw = try response.result.get()
                let json = JSON(raw)
                if let rawString = json.rawString(){
                    print(rawString)
                }else{
                    print(json)
                }
            }catch{
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            //error is not being thrown if the token is not expired from the backend
            //so better handle it in this block
            if let statusCode = response.response?.statusCode{
                print("Status \(statusCode)")
                if statusCode == 404{
                    // handle 404
                    return
                }
                else if statusCode == 401{
                    // handle 401
                    return
                }
                else if statusCode == 403{
                    // handle 403
                }
                else if statusCode == 500{
                    // handle 500
                }
            }
            
            switch response.result{
            case .success(let json):
                self.serializeResponse(with: json, completion: completion)
                break
            case .failure(let error):
                print("An error occured while attempting to process the request")
                print(error)
                if error.localizedDescription.lowercased().contains("offline"){
                    completion?([], Helpers.makeOfflineError())
                }else{
                    completion?([], error)
                }
            }
        }
    }
    
    func serializeResponse(with object: Any, completion:RequestCompletionClosure? = nil){
        print("Serialized regular")
        completion?([object as? ResultingModel].compactMap({$0}), nil)
    }
}

public extension PRequest where ResultingModel == JSON{
    func serializeResponse(with object: Any, completion: RequestCompletionClosure? = nil){
        print("Serialized JSON")
        completion?([ResultingModel(object)], nil)
    }
}

public extension PRequest where ResultingModel: Any & Mappable{
    func serializeResponse(with object: Any, completion: RequestCompletionClosure? = nil){
        print("Serialized mappable")
        let json = JSON(object)
        if let dictionaryObject = json.dictionaryObject,
           let object = ResultingModel(JSON: dictionaryObject){
            completion?([object], nil)
        }else if let objectArray = json.array{
            let objects = objectArray.compactMap({ json -> ResultingModel? in
                guard let rawObject = json.dictionaryObject else{
                    return nil
                }
                return ResultingModel(JSON: rawObject)
            })
            completion?(objects, nil)
        }
    }
}
