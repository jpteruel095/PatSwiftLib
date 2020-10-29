//
//  PEndpoint+RequestHandling.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Alamofire
import SwiftyJSON
import ObjectMapper

public extension PEndpoint{
    func request(){
        requestArrayWithProgress()
    }
    
    func requestSingle(completion: @escaping RequestCompletionSingleClosure){
        requestArrayWithProgress(completion: { models, error in
            if let error = error{
                completion(nil, error)
                return
            }
            
            guard let model = models.first else{
                completion(nil, Helpers.makeError(with: "Could not retrieve \(ResultModel.self) record"))
                return
            }
            
            completion(model, nil)
        })
    }
    
    func requestMultiple(completion: @escaping RequestCompletionMultipleClosure){
        self.requestArrayWithProgress(completion: completion)
    }
    
    func requestSingleWithProgress(_ progressCallback:@escaping ((Progress) -> Void),
                                   completion: @escaping RequestCompletionSingleClosure){
        requestArrayWithProgress(progressCallback, completion: { models, error in
            if let error = error{
                completion(nil, error)
                return
            }
            
            guard let model = models.first else{
                completion(nil, Helpers.makeError(with: "Could not retrieve \(ResultModel.self) record"))
                return
            }
            
            completion(model, nil)
        })
    }
    
    func requestMultipleWithProgress(_ progressCallback:@escaping ((Progress) -> Void),
                                   completion: @escaping RequestCompletionMultipleClosure){
        self.requestArrayWithProgress(progressCallback, completion: completion)
    }
    /**
     Calls the request for the specified Endpoint
     - parameters:
        - progressCallback: Callback that returns the progress of the current request.
        - completion: Callback for the response of the request.
     */
    private func requestArrayWithProgress(_ progressCallback:((Progress) -> Void)? = nil,
                 completion:RequestCompletionMultipleClosure? = nil)
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
            if let parameters = parameters?.parameters,
               parameters.count > 0{
                print("Parameters: \(parameters.toJSONString())")
            }
        }
        
        //Starts executing the request in here
        PWeb.shared.runningRequests += 1
        AF.request(url,
                method: method,
                parameters: parameters?.parameters,
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
            self.handleResponse(parameters: parameters?.parameters,
                                    response: response,
                                    progressCallback: progressCallback,
                                    completion: completion)
        })
    }
    
    fileprivate func handleResponse(parameters: Parameters? = nil,
                                        response: DataResponse<Any, AFError>,
                                        progressCallback:((Progress) -> Void)? = nil,
                                        completion:RequestCompletionMultipleClosure? = nil)
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
                if statusCode != 200{
                    if statusCode == 404{
                        // handle 404
                        PWeb.shared.runningRequests -= 1
                        return
                    }
                    else if statusCode == 401{
                        // handle 401
                        PWeb.shared.runningRequests -= 1
                        return
                    }
                    else if statusCode == 403{
                        // handle 403
                    }
                    else if statusCode == 500{
                        // handle 500
                    }
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
            PWeb.shared.runningRequests -= 1
        }
    }
    
    func serializeResponse(with object: Any, completion:RequestCompletionMultipleClosure? = nil){
        print("Serialized regular")
        var json: JSON? = JSON(object)
        
        dictionarySearchNestedKeys.forEach { (key) in
            json = json?.dictionary?[key]
        }
        
        if let arrayObject = json?.arrayObject{
            let array = arrayObject.compactMap({$0 as? ResultModel})
            completion?(array, nil)
        }else if let object = json?.object as? ResultModel{
            completion?([object], nil)
        }else{
            completion?([], Helpers.makeError(with: "Could not parse JSON!"))
        }
        completion?([object as? ResultModel].compactMap({$0}), nil)
    }
}

public extension PEndpoint where ResultModel == JSON{
    func serializeResponse(with object: Any, completion: RequestCompletionMultipleClosure? = nil){
        print("Serialized JSON")
        var json: JSON? = JSON(object)
        
        dictionarySearchNestedKeys.forEach { (key) in
            json = json?.dictionary?[key]
        }
        
        if let array = json?.array{
           completion?(array, nil)
       }else if let json = json{
            completion?([json], nil)
        }else{
            completion?([], Helpers.makeError(with: "Could not parse JSON!"))
        }
    }
}

public extension PEndpoint where ResultModel: Any & Mappable{
    func serializeResponse(with object: Any, completion: RequestCompletionMultipleClosure? = nil){
        print("Serialized mappable")
        var json: JSON? = JSON(object)
        
        dictionarySearchNestedKeys.forEach { (key) in
            json = json?.dictionary?[key]
        }
        
        if let dictionaryObject = json?.dictionaryObject{
            guard let object = ResultModel(JSON: dictionaryObject) else{
                completion?([], Helpers.makeError(with: "Could not parse object to \(ResultModel.self)"))
                return
            }
            completion?([object], nil)
        }else if let objectArray = json?.array{
            let objects = objectArray.compactMap({ json -> ResultModel? in
                guard let rawObject = json.dictionaryObject else{
                    return nil
                }
                return ResultModel(JSON: rawObject)
            })
            completion?(objects, nil)
        }else{
            completion?([], Helpers.makeError(with: "Could not parse JSON!"))
        }
    }
}
