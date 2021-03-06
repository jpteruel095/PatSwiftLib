//
//  StringExt.swift
//  Alamofire
//
//  Created by John Patrick Teruel on 10/29/20.
//

import Foundation

extension String{
   func toDate(withFormat format: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'") -> Date?{
       let formatter = DateFormatter()
       formatter.dateFormat = format
       return formatter.date(from: self)
   }
}
