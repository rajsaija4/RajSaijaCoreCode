//
//  StockObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 21/01/22.
//

import Foundation

class StockObject: NSObject, Codable {
    var id: String = ""
    var account_id: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var name: String = ""
    
    var arrAssets: [AssetsObject] = []
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.account_id = dictionary["account_id"] as? String ?? ""
        self.created_at = dictionary["created_at"] as? String ?? ""
        self.updated_at = dictionary["updated_at"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        
        if let assets = dictionary["assets"] as? [Dictionary<String, Any>] {
            for i in 0..<assets.count  {
                let objData = AssetsObject.init(assets[i])
                self.arrAssets.append(objData)
            }
        }
    }
}
