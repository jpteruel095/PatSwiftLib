//
//  StringExt.swift
//  Alamofire
//
//  Created by John Patrick Teruel on 10/29/20.
//

import Foundation

extension String{
    var trimmed: String{
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var nullableTrimmed: String?{
        return self.trimmed != "" ? self.trimmed : nil
    }
    
   func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date?{
       let formatter = DateFormatter()
       formatter.dateFormat = format
       return formatter.date(from: self)
   }
}
