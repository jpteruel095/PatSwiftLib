//
//  PParameters.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/29/20.
//

import Alamofire

public protocol PParameters {
    // MARK: Parameters customization
    var excludedKeys: [String] { get }
    var includedKeys: [String] { get }
    var additionalParameters: OptionalParameters { get }
    var defaultExcludedKeys: [String]{ get }
}

public extension PParameters{
    // MARK: Request Parameters Extension
    var excludedKeys: [String] {
        get{
            return []
        }
    }
    
    var includedKeys: [String] {
        get{
            return []
        }
    }
    
    var additionalParameters: OptionalParameters {
        get{
            return [:]
        }
    }
    
    var defaultExcludedKeys: [String]{
        var keys = [String]()
        keys.append(contentsOf: excludedKeys)
        return keys
    }
    
    ///Returns the default Parameters with keys based from the variable names
    func getParameters() -> Parameters?{
        var parameters: Parameters = [:]
        
        var listPropertiesWithValues: ((Mirror?) -> Void)!
        listPropertiesWithValues = { reflect in
            let mirror = reflect ?? Mirror(reflecting: self)
            if mirror.superclassMirror != nil {
                listPropertiesWithValues(mirror.superclassMirror)
            }

            for (_, attr) in mirror.children.enumerated() {
                if let property_name = attr.label,
                   property_name != "excludedKeys",
                   property_name != "includedKeys",
                   property_name != "additionalParameters",
                    !self.defaultExcludedKeys.contains(property_name),
                    self.includedKeys.count == 0 || self.includedKeys.contains(property_name){
                    parameters[property_name] = attr.value
                }
            }
        }
        listPropertiesWithValues(nil)
        
        let additional = additionalParameters.compactMapValues({$0})
        return parameters.merging(additional){ _, new in new }
    }
}

public extension PParameters where Self: PEndpoint{
    var defaultExcludedKeys: [String]{
        var keys = [
            "method",
            "path",
            "dictionarySearchNestedKeys",
        ]
        keys.append(contentsOf: excludedKeys)
        return keys
    }
}

public struct DefaultPParameter: PParameters{
    
}
