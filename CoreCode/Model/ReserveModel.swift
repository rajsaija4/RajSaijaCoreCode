//
//  ReserveModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 28/02/22.
//

import Foundation
import SwiftyJSON

class ReserveModel:NSObject {
    
    var message = ""
    var orders:ReserveOrder?
    var status = 0
    
    init(json:JSON){
        super.init()
        
        message = json["message"].stringValue
        orders = ReserveOrder(json: json)
        status = json["status"].intValue
    }
}




class ReserveOrder:NSObject {
    
    var totalDocs = 0
    var result:[ReserveResult] = []
    var totalPages = 0
    var page = 0
    var pagingCounter = 0
    var nextPage = 0
    var limit = 0
    
    
    init(json:JSON){
        super.init()
        
        totalDocs = json["orders"]["totalDocs"].intValue
        for r in json["orders"]["result"].arrayValue {
            result.append(ReserveResult(json: r))
        }
        totalPages = json["orders"]["totalPages"].intValue
        page = json["orders"]["page"].intValue
        pagingCounter = json["orders"]["pagingCounter"].intValue
        nextPage = json["orders"]["nextPage"].intValue
        limit = json["orders"]["limit"].intValue
        
    }
    
    
}


class ReserveResult:NSObject {
    var waitingList = 0
    var deliveryTime = ""
    var restaurant:[ReserveRestaurant] = []
    var _id = ""
    var estimatedWaitTime = 0
    var orderStatus = ""
    var orderType = ""
    var item:[OrderItems] = []
    
    init(json:JSON){
        super.init()
        waitingList = json["waitingList"].intValue
        deliveryTime = json["deliveryTime"].stringValue
        orderStatus = json["orderStatus"].stringValue
        orderType = json["orderType"].stringValue
        estimatedWaitTime = json["estimatedWaitTime"].intValue
        _id = json["_id"].stringValue
        for r in json["restaurant"].arrayValue {
            restaurant.append(ReserveRestaurant(json: r))
        }
        for i in json["items"].arrayValue {
            item.append(OrderItems(json: i))
        }
    }
}


class ReserveRestaurant:NSObject {
    
    var _id = ""
    var name = ""
    var image = ""
    var location = ""
    
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        image = json["image"].stringValue
        location = json["location"].stringValue
    }
    
    
    
}
