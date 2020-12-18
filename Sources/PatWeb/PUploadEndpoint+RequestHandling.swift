//
//  PUploadEndpoint+RequestHandling.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 12/18/20.
//

import Alamofire
import SwiftyJSON
import ObjectMapper
import CoreData

public extension PUploadEndpoint{
    func requestWithFiles(_ files: [UploadFileRequest]){
        requestArrayWithFiles(files)
    }
    
    func requestSingleWithFiles(_ files: [UploadFileRequest], completion: @escaping RequestCompletionSingleClosure){
        requestArrayWithFiles(files, completion: { models, error in
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
    
    func requestMultipleWithFiles(_ files: [UploadFileRequest], completion: @escaping RequestCompletionMultipleClosure){
        self.requestArrayWithFiles(files, completion: completion)
    }
    
    func requestSingleWithFiles(_ files: [UploadFileRequest],
                                progress progressCallback:@escaping ((Progress) -> Void),
                                completion: @escaping RequestCompletionSingleClosure){
        requestArrayWithFiles(files, progress: progressCallback, completion: { models, error in
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
    
    func requestMultipleWithFiles(_ files: [UploadFileRequest],
                                  progress progressCallback:@escaping ((Progress) -> Void),
                                  completion: @escaping RequestCompletionMultipleClosure){
        self.requestArrayWithFiles(files, progress: progressCallback, completion: completion)
    }
    
    private func addDictToFormData(_ formData: MultipartFormData, key: String, dictionary: [String: Any], shouldLog: Bool){
        for (dictKey, dictValue) in dictionary{
            let newKey = "\(key)[\(dictKey)]"
            if let itemArray = dictValue as? [Any] {
                addArrayToFormData(formData, key: newKey, array: itemArray, shouldLog: shouldLog)
            }else if let itemDict = dictValue as? [String: Any]{
                addDictToFormData(formData, key: newKey, dictionary: itemDict, shouldLog: shouldLog)
            }else{
                if let string = JSON(dictValue).rawString(),
                    let data = string.data(using: .utf8){
                    formData.append(data,
                                    withName: newKey)
                    if shouldLog {
                        print("\(newKey): \(string)")
                    }
                }
            }
        }
    }
    
    private func addArrayToFormData(_ formData: MultipartFormData, key: String, array: [Any], shouldLog: Bool){
        for item in array {
            let newKey = "\(key)[]"
            if let itemArray = item as? [Any] {
                addArrayToFormData(formData, key: newKey, array: itemArray, shouldLog: shouldLog)
            }else if let itemDict = item as? [String: Any]{
                addDictToFormData(formData, key: newKey, dictionary: itemDict, shouldLog: shouldLog)
            }else{
                if let string = JSON(item).rawString(),
                    let data = string.data(using: .utf8){
                    formData.append(data,
                                    withName: newKey)
                    if shouldLog {
                        print("\(newKey): \(string)")
                    }
                }
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
    func requestArrayWithFiles(_ fileRequests: [UploadFileRequest],
                               progress progressCallback:((Progress) -> Void)? = nil,
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
            print("File Requests:")
            fileRequests.forEach { (request) in
                print("    \"\(request.parameterkey)\": \(request.filename), \(request.data.count)")
            }
            if let parameters = parameters?.getParameters(),
               parameters.count > 0{
                print("Parameters: \(parameters.toJSONString())")
            }
        }
        
        //Starts executing the request in hear
        let _ = AF.upload(multipartFormData: { (formData) in
            fileRequests.forEach { (request) in
                formData.append(request.data,
                                withName: request.parameterkey,
                                fileName: request.filename,
                                mimeType: "image/jpeg")
            }
            // import parameters
            if let parameters = parameters?.getParameters(){
                print("Added to form data:")
                for (key, value) in parameters {
                    if let array = value as? [Any]{
                        self.addArrayToFormData(formData,
                                                key: key,
                                                array: array,
                                                shouldLog: shouldLog)
                    }else if let dict = value as? [String: Any]{
                        self.addDictToFormData(formData,
                                               key: key,
                                               dictionary: dict,
                                               shouldLog: shouldLog)
                    }else{
                        if let value = JSON(value).rawString(),
                            let data = value.data(using: .utf8){
                            formData.append(data, withName: key)
                            if shouldLog && shouldLogRequest {
                                print("\(key): \(value)")
                            }
                        }
                    }
                }
            }
        }, to: url,
           method: method,
           headers: headers).uploadProgress(closure: { (progress) in
            print("progress: \(progress.fractionCompleted)")
            if let progressCallback = progressCallback{
                DispatchQueue.main.async {
                    progressCallback(progress)
                }
            }
           }).responseJSON { (response) in
            self.handleResponse(parameters: parameters?.getParameters(),
                                    response: response,
                                    progressCallback: progressCallback,
                                    completion: completion)
        }
    }
}
