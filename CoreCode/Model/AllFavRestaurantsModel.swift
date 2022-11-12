//
//  AllFavRestaurantsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 12/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire



class AllFavRestaurantsModel:NSCoder {
    
    var favoriteRestaurants_count = 0
    var favoriteRestaurants:FavoriteRestaurants!
    
    init(json:JSON){
        super.init()
        
        favoriteRestaurants_count = json["favoriteRestaurants_count"].intValue
        favoriteRestaurants = FavoriteRestaurants(json: json)
    }
}

class FavoriteRestaurants:NSCoder {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[FavoriteResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["favoriteRestaurants"]["page"].intValue
        limit = json["favoriteRestaurants"]["limit"].intValue
        totalDocs = json["favoriteRestaurants"]["totalDocs"].intValue
        totalPages = json["favoriteRestaurants"]["totalPages"].intValue
        pagingCounter = json["favoriteRestaurants"]["pagingCounter"].intValue
        for r in json["favoriteRestaurants"]["result"].arrayValue {
            result.append(FavoriteResult(json: r))
        }
    }
    
}

class FavoriteResult: NSCoder {
    var _id = ""
    var customer:[FavoriteCustomer] = []
    var restaurant:[AllFavoriteRestaurant] = []
    var createdAt = ""
    var __v = 0
    var reviewCount = 0
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        for c in json["customer"].arrayValue {
            customer.append(FavoriteCustomer(json: c))
        }
        for r in json["restaurant"].arrayValue {
            restaurant.append(AllFavoriteRestaurant(json: r))
            
        }
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
        reviewCount = json["reviewCount"].intValue
    }
    
}

class FavoriteCustomer:NSCoder {
    var _id = ""
    var name = ""
    var email = ""
    var diet:[String] = []
    var profile = ""
    var role = ""
    var blackList = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0
    var createdAt = ""
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        for d in json["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        profile = json["profile"].stringValue
        role = json["role"].stringValue
        blackList = json["blacklist"].boolValue
        language = json["language"].stringValue
        bytPoints = json["bytPoints"].intValue
        avgSpend = json["avgSpend"].intValue
        createdAt = json["createdAt"].stringValue
    }
    
}


class AllFavoriteRestaurant:NSCoder {
    
    var id = ""
    var name = ""
    var city = ""
    var isOwner = false
    var owner = ""
    var std = ""
    var contact:[String] = []
    var coords:Location!
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
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        city = json["city"].stringValue
        isOwner = json["isOwner"].boolValue
        owner = json["owner"].stringValue
        std = json["std"].stringValue
        for c in json["contact"].arrayValue {
            contact.append(c.stringValue)
        }
        coords = Location(json: json)
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
    }
}
