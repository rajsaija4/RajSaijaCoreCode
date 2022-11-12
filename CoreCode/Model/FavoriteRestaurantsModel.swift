//
//  FavoriteRestaurantsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 12/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire

class FavoriteRestaurantsModel:NSCoder {
    var message = ""
    var favoriteRestaurant:FavoriteRestaurant!
    
    init(json:JSON){
        super.init()
        
        message = json["message"].stringValue
        favoriteRestaurant = FavoriteRestaurant(json: json)
    }
}

class FavoriteRestaurant:NSCoder {
    
    var _id = ""
    var customer = ""
    var __v = 0
    var createdAt = ""
    var restaurant = ""
    
    init(json:JSON){
        super.init()
        
        _id = json["favoriteRestaurant"]["_id"].stringValue
        customer = json["favoriteRestaurant"]["customer"].stringValue
        __v = json["favoriteRestaurant"]["__v"].intValue
        createdAt = json["favoriteRestaurant"]["createdAt"].stringValue
        restaurant = json["favoriteRestaurant"]["restaurant"].stringValue
    }
}
