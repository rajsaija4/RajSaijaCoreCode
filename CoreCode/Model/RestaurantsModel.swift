//
//  RestaurantsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 04/01/22.
//

import Foundation
import SwiftyJSON

class RestaurantsModel: NSObject {
    
    var restaurants_count = 0
    var restaurants:Restaurants!
    
    init(json:JSON){
        super.init()
        restaurants_count = json["restaurants_count"].intValue
        restaurants = Restaurants(json: json)
    }
}

class Restaurants: NSObject {
    
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[ResultData] = []
    
    init(json:JSON){
        super.init()
        
        page = json["restaurants"]["page"].intValue
        limit = json["restaurants"]["limit"].intValue
        totalDocs = json["restaurants"]["totalDocs"].intValue
        totalPages = json["restaurants"]["totalPages"].intValue
        pagingCounter = json["restaurants"]["pagingCounter"].intValue
        for r in json["restaurants"]["result"].arrayValue {
            result.append(ResultData(json: r))
        }
    }
}

class ResultData: NSObject {
    
    var id = ""
    var name = ""
    var city = ""
    var isOwner = false
    var owner:[Owner] = []
    var std = ""
    var contact:[String] = []
    var coords:Coords!
    var status = false
    var openStatus = ""
    var paymentMethod = ""
    var tags:[String] = []
    var openDays:[String] = []
    var openTiming:[String] = []
    var email = ""
    var website = ""
    var desc = ""
    var image = ""
    var ratings = 0.0
    var discount = 0
    var createdAt = ""
    var __V = 0
    var fullDistance = 0
    var distance = 0
    var package:[String] = []
    var review:[String] = []
    var isFavourite:Favourite!
    var tableCount = 0
    var reviewCount = 0
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        city = json["city"].stringValue
        isOwner = json["isOwner"].boolValue
        for o in json["owner"].arrayValue {
            owner.append(Owner(json: o))
        }
        std = json["std"].stringValue
        for c in json["contact"].arrayValue {
            contact.append(c.stringValue)
        }
        coords = Coords(json: json)
        status = json["status"].boolValue
        openStatus = json["openStatus"].stringValue
        for t in json["tags"].arrayValue {
            tags.append(t.stringValue)
        }
        paymentMethod = json["paymentMethod"].stringValue
        for days in json["openDays"].arrayValue{
            openDays.append(days.stringValue)
        }
        email = json["email"].stringValue
        website = json["website"].stringValue
        desc = json["description"].stringValue
        
        
        for time in json["openTiming"].arrayValue{
            openTiming.append(time.stringValue)
        }
        image = json["image"].stringValue
        ratings = json["ratings"].doubleValue
        discount = json["discount"].intValue
        createdAt = json["createdAt"].stringValue
        __V = json["__v"].intValue
        fullDistance = json["fullDistance"].intValue
        distance = json["distance"].intValue
        for p in json["package"].arrayValue{
            package.append(p.stringValue)
        }
        for r in json["review"].arrayValue{
            review.append(r.stringValue)
        }
        tableCount = json["tableCount"].intValue
        isFavourite = Favourite(json: json)
        reviewCount = json["reviewCount"].intValue
    }
}

class Favourite: NSObject {
    var status = false
    var id = ""
    
    init(json:JSON) {
        status = json["restaurant"]["isFavourite"]["status"].boolValue
        id = json["restaurant"]["isFavourite"]["id"].stringValue
    }
}

class Owner: NSObject {
    
    var id = ""
    var name = ""
    var mobile = ""
    var email = ""
    var address = ""
    var profile = ""
    var restaurantCount = 0
    var restaurantType = false
    var role = ""
    var createdAt = ""
    var salt = ""
    var hasKey = ""
    var v = 0
    
    init(json:JSON) {
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        mobile = json["mobile"].stringValue
        email = json["email"].stringValue
        address = json["address"].stringValue
        profile = json["profile"].stringValue
        restaurantCount = json["restaurantCount"].intValue
        restaurantType = json["restaurantType"].boolValue
        role = json["role"].stringValue
        createdAt = json["createdAt"].stringValue
        salt = json["salt"].stringValue
        hasKey = json["hash"].stringValue
        v = json["__v"].intValue
    }
}

class Coords: NSObject {
    var type = ""
    var coordinates:[Double] = []
    
    init(json:JSON) {
        super.init()
        type = json["coords"]["type"].stringValue
        for c in json["coords"]["coordinates"].arrayValue {
            coordinates.append(c.doubleValue)
        }
    }
}
