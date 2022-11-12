//
//  RecentSearchHistoryModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 28/03/22.
//

import Foundation
import SwiftyJSON

class SearchHistories:NSObject {
    var message = ""
    var searchHistories_count = 0
    var status = 0
    var searchHistories:SearchHistoriesResult!
    
    init(json:JSON){
        super.init()
        message = json["message"].stringValue
        searchHistories_count = json["searchHistories_count"].intValue
        status = json["status"].intValue
        searchHistories = SearchHistoriesResult(json: json)
        
    }
}

class SearchHistoriesResult:NSObject {
    var result:[RecentSearchHistoryModel] = []
    
    init(json:JSON){
        super.init()
        for r in json["searchHistories"]["result"].arrayValue {
            result.append(RecentSearchHistoryModel(json: r))
        }
    }
}

class RecentSearchHistoryModel: NSObject {
    var _id = ""
    var __v = 0
    var createdAt = ""
    var user = ""
    var text = ""
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        __v = json["__v"].intValue
        createdAt = json["createdAt"].stringValue
        user = json["user"].stringValue
        text = json["text"].stringValue
        
    }
}
