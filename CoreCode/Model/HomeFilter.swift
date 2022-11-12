//
//  HomeFilter.swift
//  BYT
//
//  Created by RAJ J SAIJA on 14/04/22.
//

import Foundation
import SwiftyJSON

class HomeFilter:NSObject {
    var message = ""
    var status = 0
    var filters_count = 0
    var filters:Filters!
    
    init(json:JSON){
        super.init()
        
        message = json["message"].stringValue
        status = json["status"].intValue
        filters_count = json["filters_count"].intValue
        filters = Filters(json: json)
    }
}

class Filters:NSObject {
    var totalPages = 0
    var page = 0
    var pagingCounter = 0
    var limit = 0
    var totalDocs = 0
    var result:[FilterResult] = []
    
    init(json:JSON){
        super.init()
        
        totalPages = json["filters"]["totalPages"].intValue
        page = json["filters"]["page"].intValue
        pagingCounter = json["filters"]["pagingCounter"].intValue
        limit = json["filters"]["limit"].intValue
        totalDocs = json["filters"]["totalDocs"].intValue
        for r in json["filters"]["result"].arrayValue {
            result.append(FilterResult(json: r))
        }
    }
}

class FilterResult:NSObject {
    var filters:[FilterResultDetails] = []
    var slider = false
    var __v = 0
    var filterTitle = ""
    var _id  = ""
    var createdAt = ""
    var multipleSelection = false
    var max = 0
    var min = 0
    
    init(json:JSON){
        super.init()
        
        for i in json["filters"].arrayValue {
            filters.append(FilterResultDetails(json: i))
        }
        slider = json["slider"].boolValue
        multipleSelection = json["multipleSelection"].boolValue
        __v = json["__v"].intValue
        filterTitle = json["filterTitle"].stringValue
        _id = json["_id"].stringValue
        createdAt = json["createdAt"].stringValue
        max = json["max"].intValue
        min = json["min"].intValue
        
    }
}


class FilterResultDetails: NSObject {
    var query = ""
    var name = ""
    var _id = ""
    var isselected = false
    
    init(json:JSON) {
        super.init()
        
        query = json["query"].stringValue
        name = json["name"].stringValue
        _id = json["_id"].stringValue
    }
}

