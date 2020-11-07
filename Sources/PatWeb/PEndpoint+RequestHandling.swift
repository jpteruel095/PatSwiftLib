//
//  PEndpoint+RequestHandling.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import Alamofire
import SwiftyJSON
import ObjectMapper
import CoreData

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
            if let parameters = parameters?.getParameters(),
               parameters.count > 0{
                print("Parameters: \(parameters.toJSONString())")
            }
        }
        
        //Starts executing the request in here
        PWeb.shared.runningRequests += 1
        AF.request(url,
                method: method,
                parameters: parameters?.getParameters(),
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
            self.handleResponse(parameters: parameters?.getParameters(),
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
                
                var responseResultJSON: JSON?
                do{
                    responseResultJSON = JSON(try response.result.get())
                }catch{
                    completion?([], error)
                }
                
                if statusCode != 200{
                    let decisionHandler: StatusN200DecisionHandler = { decision in
                        switch decision {
                        case .proceed:
                            break
                        case .complete:
                            PWeb.shared.runningRequests -= 1
                            completion?([], nil)
                            break
                        case .repeat:
                            self.requestArrayWithProgress(progressCallback,
                                                          completion: completion)
                            break
                        case .error(let err):
                            PWeb.shared.runningRequests -= 1
                            completion?([], err)
                            break
                        }
                    }
                    
                    if let handler = PWeb.shared.statusN200Handler,
                       handler(self, responseResultJSON, statusCode, decisionHandler){
                        return
                    }
                }
            }
            
            PWeb.shared.runningRequests -= 1
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

public extension PEndpoint where ResultModel == DefaultModel{
    var managedObjectContext: NSManagedObjectContext?{
        get{
            return nil
        }
        set{
            
        }
    }
    
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
    var managedObjectContext: NSManagedObjectContext?{
        get{
            return nil
        }
        set{
            
        }
    }
    
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

public extension PEndpoint where ResultModel: PJSONEntityProtocol{
    func serializeResponse(with object: Any, completion: RequestCompletionMultipleClosure? = nil){
        print("Serialized mappable")
        guard let context = managedObjectContext else{
            completion?([], Helpers.makeError(with: "Context must not be nil"))
            return
        }
        
        var json: JSON? = JSON(object)
        
        dictionarySearchNestedKeys.forEach { (key) in
            json = json?.dictionary?[key]
        }
        
        if let array = json?.array{
            do{
                let objects = try array.compactMap({ json -> ResultModel? in
                    return try ResultModel.fromSwiftyJSON(json, in: context, strict: true)
                })
                completion?(objects, nil)
            }catch{
                completion?([], error)
            }
        }else if let json = json{
            do{
                guard let object = try ResultModel.fromSwiftyJSON(json, in: context, strict: true) else{
                    completion?([], Helpers.makeError(with: "Could not parse object to \(ResultModel.self)"))
                    return
                }
                completion?([object], nil)
            }catch{
                completion?([], error)
            }
        }else{
            completion?([], Helpers.makeError(with: "Could not parse JSON!"))
        }
    }
}
