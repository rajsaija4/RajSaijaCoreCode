//
//  AddOnsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 28/01/22.
//

import Foundation
import SwiftyJSON

class AddOnsModel: NSObject{
    
    var addons_count = 0
    var addons:AddonsRawDetails!
    
    init(json:JSON){
        super.init()
        addons_count = json["addons_count"].intValue
        addons = AddonsRawDetails(json: json)
    }
}

class AddonsRawDetails: NSObject{
    
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[AddonsResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["addons"]["page"].intValue
        limit = json["addons"]["limit"].intValue
        totalDocs = json["addons"]["totalDocs"].intValue
        totalPages = json["addons"]["totalPages"].intValue
        pagingCounter = json["addons"]["pagingCounter"].intValue
        for r in json["addons"]["result"].arrayValue {
            result.append(AddonsResult(json: r))
        }
    }
}

class AddonsResult:NSObject {
    var _id = ""
    var name = ""
    var restaurant = ""
    var price = 0.0
    var quantity = 0
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        restaurant = json["restaurant"].stringValue
        price = json["price"].doubleValue
        quantity = json["quantity"].intValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}
