//
//  RestaurantsInfoModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 10/01/22.
//

import Foundation
import SwiftyJSON
import Alamofire
import SwiftUI

class RestaurantsInfoModel: NSObject {
    
    var id = ""
    var name = ""
    var city = ""
    var isOwner = false
    var owner:[Restaurant] = []
    var std = ""
    var contact:[String] = []
    var tax:Tax!
    var location = ""
    var coords:Location!
    var services = ""
    var seating = ""
    var status = false
    var paymentMethod = ""
    var cuisines = ""
    var openStatus = ""
    var tags:[String] = []
    var openDays:[String] = []
    var openTiming:[String] = []
    var email = ""
    var facebook = ""
    var instagram = ""
    var twitter = ""
    var website = ""
    var desc = ""
    var image = ""
    var ratings = 0.0
    var discount = 0
    var createdAt = ""
    var __V = 0
    var fullDistance = 0
    var distance = 0
    var package:[Package] = []
    var reviews:[Reviews] = []
    var seatingPreference:[String] = []
    var tableCount = 0
    var reviewCount = 0
    var menu:[Menus] = []
    var isFavourite:Favourite!
    var menuCount = 0
    var reviewer:[Reviewer] = []
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        city = json["city"].stringValue
        isOwner = json["isOwner"].boolValue
        for r in json["owner"].arrayValue {
            owner.append(Restaurant(json: r))
        }
        tax = Tax(json: json)
        std = json["std"].stringValue
        for c in json["contact"].arrayValue {
            contact.append(c.stringValue)
        }
        location = json["location"].stringValue
        coords = Location(json: json)
        status = json["status"].boolValue
        for t in json["tags"].arrayValue {
            tags.append(t.stringValue)
        }
        paymentMethod = json["paymentMethod"].stringValue
        for days in json["openDays"].arrayValue{
            openDays.append(days.stringValue)
        }
        email = json["email"].stringValue
        services = json["services"].stringValue
        seating = json["seating"].stringValue
        website = json["website"].stringValue
        cuisines = json["cuisines"].stringValue
        openStatus = json["openStatus"].stringValue
        desc = json["description"].stringValue
        facebook = json["facebook"].stringValue
        instagram = json["instagram"].stringValue
        twitter = json["twitter"].stringValue
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
            package.append(Package(json: p))
        }
        for r in json["reviews"].arrayValue{
            reviews.append(Reviews(json: r))
        }
        for review in json["reviewer"].arrayValue{
            reviewer.append(Reviewer(json: review))
        }
        tableCount = json["tableCount"].intValue
        reviewCount = json["reviewCount"].intValue
        
        for m in json["menus"].arrayValue {
            menu.append(Menus(json: m))
        }
        isFavourite = Favourite(json: json)
        menuCount = json["menuCount"].intValue
        for i in json["seatingPreference"].arrayValue {
            seatingPreference.append(i.stringValue)
        }
    }
}

class Tax: NSObject {
    var rate = 0.0
    var createdAt = ""
    var restaurant = ""
    var taxType = ""
    var __v = 0
    var __id = ""
    var addedBy = ""
    
    init(json:JSON){
        super.init()
        rate = json["tax"]["rate"].doubleValue
        createdAt = json["tax"]["createdAt"].stringValue
        restaurant = json["tax"]["restaurant"].stringValue
        taxType = json["tax"]["taxType"].stringValue
        __v = json["tax"]["__v"].intValue
        __id = json["tax"]["_id"].stringValue
        addedBy = json["tax"]["addedBy"].stringValue
        
    }
    
}

class Package: NSObject {
    
    var _id = ""
    var name = ""
    var price = 0
    var validity = 0
    var expiry = ""
    var status = false
    var restaurantCount = 0
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        price = json["price"].intValue
        validity = json["validity"].intValue
        expiry = json["expiry"].stringValue
        status = json["status"].boolValue
        restaurantCount = json["restaurantCount"].intValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}

class Reviews:NSObject {
    var _id = ""
    var reviewerId = ""
    var item = ""
    var restaurant = ""
    var desc = ""
    var rating = 0.0
    var upVote = 0
    var downVote = 0
    var createdAt = ""
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        reviewerId = json["reviewerId"].stringValue
        item = json["item"].stringValue
        restaurant = json["restaurant"].stringValue
        desc = json["description"].stringValue
        rating = json["rating"].doubleValue
        upVote = json["upVote"].intValue
        downVote = json["downVote"].intValue
        createdAt = json["createdAt"].stringValue
    }
}

class Reviewer:NSObject {
    
    var _id = ""
    var name = ""
    var email = ""
    var diet:[String] = []
    var profile = ""
    var role = ""
    var blacklist = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0
    var createdAt = ""
    var salt = ""
    var hashString = ""
    var __v = 0
    
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
        blacklist = json["blacklist"].boolValue
        language = json["language"].stringValue
        bytPoints = json["bytPoints"].intValue
        avgSpend = json["avgSpend"].intValue
        createdAt = json["createdAt"].stringValue
        salt = json["salt"].stringValue
        hashString = json["hash"].stringValue
        __v = json["__v"].intValue
    }
}

class Restaurant: NSObject {
    
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
        v = json["__v"].intValue
    }
}

class Location: NSObject {
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

class Menus: NSObject {
    var id = ""
    var name = ""
    var desc = ""
    var img:[String] = []
    var ingredient:[Ingredient] = []
    var price = 0.0
    var currency = ""
    var status = false
    var discount = false
    var category = ""
    var menuTag:[String] = []
    var restaurant = ""
    var addons:[String] = []
    var estimatedTime = 0.0
    var createdAt = ""
    var productId = ""
    
    init(json:JSON) {
        super.init()
        id = json["_id"].stringValue
        id = json["name"].stringValue
        desc = json["description"].stringValue
        for i in json["image"].arrayValue{
            img.append(i.stringValue)
        }
        for i in json["ingredient"].arrayValue{
            ingredient.append(Ingredient(json: i))
        }
        price = json["price"].doubleValue
        currency = json["currency"].stringValue
        status = json["status"].boolValue
        discount = json["discount"].boolValue
        category = json["category"].stringValue
        for tag in json["menuTag"].arrayValue{
            menuTag.append(tag.stringValue)
        }
        restaurant = json["restaurant"].stringValue
        for add in json["addon"].arrayValue {
            addons.append(add.stringValue)
        }
        estimatedTime = json["estimatedTime"].doubleValue
        createdAt = json["createdAt"].stringValue
        productId = json["productId"].stringValue
    }
}
class Ingredient: NSObject {
    var item = ""
    var quantity = ""
    var wastage = 0.0
    
    init(json:JSON) {
        super.init()
        item = json["item"].stringValue
        quantity = json["quantity"].stringValue
        wastage = json["wastage"].doubleValue
    }
}
