//
//  JSONExt.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 12/23/20.
//

import SwiftyJSON
import ObjectMapper

//SwiftyJSON Extension
public extension JSON{
    func serialized() -> SerializedResponse?{
        return SerializedResponse.serializedJSON(self)
    }
}

public struct SerializedResponse: ImmutableMappable {
    public var message: String?
    public var code: Int?
    private var errors: [Any]?
    private var data: Any?
    private var validation_errors: [Any]?
    
    public init(map: Map) throws {
        let keys = ["message", "code", "data", "application_errors"]
        if !keys.contains(where: { (key) -> Bool in
            map.JSON.keys.contains { (mapKey) -> Bool in
                mapKey == key
            }
        }){
            throw Helpers.makeError(with: "Response is not in serializable format.")
        }
        
        message = map.JSON["message"] as? String
        code = map.JSON["code"] as? Int
        data = map.JSON["data"]
        errors = map.JSON["application_errors"] as? [Any]
        validation_errors = map.JSON["validation_errors"] as? [Any]
    }
    
    mutating public func mapping(map: Map) {
        
    }
    
    static func serializedJSON(_ json: JSON) -> SerializedResponse?{
        guard let json = json.dictionaryObject,
            let response = try? SerializedResponse(JSON: json)
            else{
                return nil
        }
        
        return response
    }
}

public extension SerializedResponse{
    func getErrors() -> [Error]{
        return errors?.compactMap({ (error) -> Error? in
            if let error = error as? String{
                return Helpers.makeError(with: error, code: self.code ?? 0)
            }else if let error = error as? Int{
                return Helpers.makeError(with: "\(error)", code: self.code ?? 0)
            }else{
                print("Could not decode error")
                print(error)
                return nil
            }
        }) ?? []
    }
    
    func getError() -> Error?{
        guard let code = code, code != 200,
              let errorMessage = message else{
            return nil
        }
        return Helpers.makeError(with: errorMessage)
    }
    
    func getData() -> JSON?{
        guard let data = self.data else { return nil }
        return JSON(data)
    }
}
