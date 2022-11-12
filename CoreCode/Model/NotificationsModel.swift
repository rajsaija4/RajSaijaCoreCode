//
//  NotificationsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 30/03/22.
//

import Foundation
import SwiftyJSON

class NotificationsModel:NSObject {
    
    var notification:Notifications!
    var message = ""
    var status = 0
    
    init(json:JSON){
        super.init()
        
        notification = Notifications(json: json)
        message = json["message"].stringValue
        status = json["status"].intValue
    }
}

class Notifications:NSObject {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[NotificationsResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["notification"]["page"].intValue
        limit =  json["notification"]["limit"].intValue
        totalDocs =  json["notification"]["totalDocs"].intValue
        totalPages = json["notification"]["totalPages"].intValue
        pagingCounter =  json["notification"]["pagingCounter"].intValue
        for i in json["notification"]["result"].arrayValue {
            result.append(NotificationsResult(json: i))
        }
    }
}

class NotificationsResult:NSObject {
    var body = ""
    var title = ""
    var user = ""
    var _id = ""
    var __v = 0
    var data:NotificationsData!
    var action = ""
    var createdAt = ""
    var isArchived = false
    
    init(json:JSON){
        super.init()
        
        body = json["body"].stringValue
        title = json["title"].stringValue
        user = json["user"].stringValue
        _id = json["_id"].stringValue
        __v = json["__v"].intValue
        data = NotificationsData(json: json)
        action = json["action"].stringValue
        createdAt = json["createdAt"].stringValue
        isArchived = json["isArchived"].boolValue
    }
}


class NotificationsData:NSObject {
    var action = ""
    var type = ""
    var orderId = ""
    
    init(json:JSON){
        super.init()
        
        action = json["data"]["action"].stringValue
        type = json["data"]["type"].stringValue
        orderId = json["data"]["orderId"].stringValue
    }
    
}
