//
//  MenuTagModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 10/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire

class MenuTagModel: NSObject {
    var menuTags_count = 0
    var menuTag:MenuTag!
    
    init(json:JSON){
        super.init()
        
        menuTags_count = json["menuTags_count"].intValue
        menuTag = MenuTag(json: json)
    }
}

class MenuTag: NSObject {
    var pageNo = 0
    var limit =  0
    var totalDocs =  0
    var totalPages =  1
    var pagingCounter = 1
    var result:[TagResult] = []
    
    init(json:JSON){
        super.init()
        
        pageNo = json["menuTags"]["page"].intValue
        limit = json["menuTags"]["limit"].intValue
        totalDocs = json["menuTags"]["totalDocs"].intValue
        totalPages = json["menuTags"]["totalPages"].intValue
        pagingCounter = json["menuTags"]["pagingCounter"].intValue
        for r in json["menuTags"]["result"].arrayValue {
            result.append(TagResult(json: r))
        }
    }
}

class TagResult: NSObject {
    
    var id = ""
    var name = ""
    var restaurant = ""
    var createdAt = ""
    var __v =  0
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        restaurant = json["restaurant"].stringValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}
