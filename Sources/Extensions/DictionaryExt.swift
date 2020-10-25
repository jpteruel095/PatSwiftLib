//
//  DictionaryExt.Swift
//  PatSwiftLib
//
//  Created by John Patrick Teruel on 10/25/20.
//

import SwiftyJSON

extension Dictionary{
    func toJSONString() -> String{
        if let jsonString = JSON(self).rawString(){
            return jsonString
        }else{
            return "{}"
        }
    }
}
