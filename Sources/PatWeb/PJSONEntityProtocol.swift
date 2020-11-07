//
//  PJSONEntityProtocol.swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 11/8/20.
//

import Foundation
import SwiftyJSON
import CoreData

public struct PJSONEntityKeymap{
    public var fromKey: String
    public var toKey: String
    
    public init(fromKey: String, toKey: String) {
        self.fromKey = fromKey
        self.toKey = toKey
    }
}

public protocol PJSONEntityProtocol: NSManagedObject{
    static var serveridkey: String { get }
    static var customKeymaps: [PJSONEntityKeymap] { get }
}

public extension PJSONEntityProtocol{
    static var customKeymaps: [PJSONEntityKeymap]{
        return []
    }
    
    static func fromSwiftyJSON(_ json: JSON, in context: NSManagedObjectContext, strict: Bool = false) throws -> Self?{
        //check if identical
        guard let json = json.dictionaryObject else{
            return nil
        }
        let filteredKeys = json.keys.filter({
            Self.entity().attributesByName.keys.contains($0)
        })
        
        if strict,
           json.keys.count != Self.entity().attributesByName.keys.count{
            return nil
        }
        var model: Self?
        if let id = json[serveridkey] as? Int{
            let request: NSFetchRequest = Self.fetchRequest()
            request.predicate = NSPredicate(format: "\(serveridkey) = %d", id)
            let result = try context.fetch(request)
            model = result.first as? Self
        }
        
        if model == nil{
            model = self.init(entity: Self.entity(), insertInto: context)
        }
        
        filteredKeys.forEach { (key) in
            model?.setValue(json[key], forKey: key)
        }
        
        customKeymaps.forEach { (keymap) in
            model?.setValue(json[keymap.fromKey], forKey: keymap.toKey)
        }
        
        return model
    }
    
    func getJSON() -> [String: Any]{
        let keys = Self.entity().attributesByName.keys.compactMap({$0})
        return self.dictionaryWithValues(forKeys: keys)
    }
    
    func toSwiftyJSON() -> JSON{
        let keys = Self.entity().attributesByName.keys.compactMap({$0})
        let dict = self.dictionaryWithValues(forKeys: keys)
        return JSON(dict)
    }
}
