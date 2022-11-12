//
//  SearchRestaurentsModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 23/03/22.
//

import Foundation
import SwiftyJSON

class SearchRestaurentsModel: NSObject {
    
    var searchData_count = 0
    var searchData:SearchRestaurants!
    
    init(json:JSON){
        super.init()
        searchData_count = json["searchData_count"].intValue
        searchData = SearchRestaurants(json: json)
    }
}

class SearchRestaurants: NSObject {
    
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[SearchResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["searchData"]["page"].intValue
        limit = json["searchData"]["limit"].intValue
        totalDocs = json["searchData"]["totalDocs"].intValue
        totalPages = json["searchData"]["totalPages"].intValue
        pagingCounter = json["searchData"]["pagingCounter"].intValue
        for r in json["searchData"]["result"].arrayValue {
            result.append(SearchResult(json: r))
        }
    }
}

class SearchResult: NSObject {
    var id = ""
    var category = ""
    var currency = ""
    var productId = ""
    var menuTag:[SearchMenuTag] = []
    var name = ""
    var images:[String] = []
    var ingredient:[SearchIngredient] = []
    var city = ""
    var price = 0.0
    var isOwner = false
    var owner = ""
    var std = ""
    var contact:[String] = []
    var location = ""
    var coords:Coords!
    var status = false
    var services = ""
    var seating = ""
    var seatingPreference:[String] = []
    var paymentMethod = ""
    var tags:[String] = []
    var openDays:[String] = []
    var openTiming:[String] = []
    var addon:[SearchAddons] = []
    var email = ""
    var website = ""
    var desc = ""
    var image = ""
    var ratings = 0.0
    var discount = 0
    var createdAt = ""
    var updatedAt = ""
    var facebook = ""
    var instagram = ""
    var twitter = ""
    var __V = 0
    var fullDistance = 0
    var distance = 0
    var package = ""
    //    var review:[String] = []
    //    var isFavourite:Favourite!
    var tableCount = 0
    var reviewCount = 0
    var alcoholServe = false
    var type = ""
    var estimatedTime = 0.0
    var restaurant:[SearchResResult] = []
    var items:[SearchItems] = []
    var menuItems:[SearchMenuItems] = []
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        category = json["category"].stringValue
        currency = json["currency"].stringValue
        productId = json["productId"].stringValue
        for m in json["menuTag"].arrayValue {
            menuTag.append(SearchMenuTag(json: m))
        }
        for i in json["image"].arrayValue {
            images.append(i.stringValue)
        }
        name = json["name"].stringValue
        city = json["city"].stringValue
        for ingred in json["ingredient"].arrayValue {
            ingredient.append(SearchIngredient(json: ingred))
        }
        isOwner = json["isOwner"].boolValue
        owner = json["owner"].stringValue
        price = json["price"].doubleValue
        std = json["std"].stringValue
        for c in json["contact"].arrayValue {
            contact.append(c.stringValue)
        }
        location = json["location"].stringValue
        coords = Coords(json: json)
        status = json["status"].boolValue
        services = json["services"].stringValue
        seating = json["seating"].stringValue
        for s in json["seatingPreference"].arrayValue {
            seatingPreference.append(s.stringValue)
        }
        for t in json["tags"].arrayValue {
            tags.append(t.stringValue)
        }
        for add in json["addon"].arrayValue {
            addon.append(SearchAddons(json: add))
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
        updatedAt = json["updatedAt"].stringValue
        __V = json["__v"].intValue
        fullDistance = json["fullDistance"].intValue
        distance = json["distance"].intValue
        package = json["package"].stringValue
        facebook = json["facebook"].stringValue
        twitter = json["instagram"].stringValue
        instagram = json["twitter"].stringValue
        //        for r in json["review"].arrayValue{
        //            review.append(r.stringValue)
        //        }
        tableCount = json["tableCount"].intValue
        //        isFavourite = Favourite(json: json)
        reviewCount = json["reviewCount"].intValue
        alcoholServe = json["alcoholServe"].boolValue
        type = json["type"].stringValue
        for rest in json["restaurant"].arrayValue{
            restaurant.append(SearchResResult(json: rest))
        }
        for product in json["items"].arrayValue{
            items.append(SearchItems(json: product))
        }
        for menu in json["menuItems"].arrayValue{
            menuItems.append(SearchMenuItems(json: menu))
        }
        estimatedTime = json["estimatedTime"].doubleValue
    }
}


class SearchMenuTag:NSObject {
    var _id = ""
    var createdAt = ""
    var __v = 0
    var restaurant = ""
    var name = ""
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
        restaurant = json["restaurant"].stringValue
        name = json["name"].stringValue
    }
}

class SearchIngredient:NSObject {
    var item = ""
    var wastage = 0
    var quantity = ""
    
    init(json:JSON){
        super.init()
        
        item = json["item"].stringValue
        wastage = json["wastage"].intValue
        quantity = json["quantity"].stringValue
    }
}


class SearchAddons:NSObject {
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


class SearchResResult:NSObject {
    var id = ""
    var name = ""
    var city = ""
    var isOwner = false
    var std = ""
    var contact:[String] = []
    var location = ""
    var coords:Location!
    var services = ""
    var seating = ""
    var status = false
    var paymentMethod = ""
    var cuisines = ""
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
    var discount = 0
    var createdAt = ""
    var __V = 0
    var fullDistance = 0
    var distance = 0
    var package = ""
    var seatingPreference:[String] = []
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        city = json["city"].stringValue
        isOwner = json["isOwner"].boolValue
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
        desc = json["description"].stringValue
        facebook = json["facebook"].stringValue
        instagram = json["instagram"].stringValue
        twitter = json["twitter"].stringValue
        for time in json["openTiming"].arrayValue{
            openTiming.append(time.stringValue)
        }
        image = json["image"].stringValue
        discount = json["discount"].intValue
        package = json["package"].stringValue
        createdAt = json["createdAt"].stringValue
        __V = json["__v"].intValue
        fullDistance = json["fullDistance"].intValue
        distance = json["distance"].intValue
        for i in json["seatingPreference"].arrayValue {
            seatingPreference.append(i.stringValue)
        }
    }
}


class SearchItems: NSObject {
    var quantity = 0
    var item:SearchItem!
    
    init(json:JSON){
        super.init()
        
        quantity = json[""].intValue
        item = SearchItem(json: json)
    }
    
}


class SearchItem:NSObject {
    var productId = ""
    var restaurant = ""
    var menuTag:[String] = []
    var discount = false
    var estimatedTime = 0
    var price = 0.0
    var _id = ""
    var currency = ""
    var name = ""
    var createdAt = ""
    var ingredient:[SearchIngredient] = []
    var image:[String] = []
    var desc = ""
    var __v = 0
    var addon:[String] = []
    var status = false
    var category = ""
    
    init(json:JSON){
        super.init()
        
        productId = json["item"]["productId"].stringValue
        restaurant = json["item"]["restaurant"].stringValue
        for m in json["item"]["menuTag"].arrayValue {
            menuTag.append(m.stringValue)
        }
        discount = json["item"]["discount"].boolValue
        estimatedTime = json["item"]["estimatedTime"].intValue
        price = json["item"]["price"].doubleValue
        _id = json["item"]["_id"].stringValue
        currency = json["item"]["currency"].stringValue
        name = json["item"]["name"].stringValue
        createdAt = json["item"]["createdAt"].stringValue
        for ingred in json["item"]["ingredient"].arrayValue{
            ingredient.append(SearchIngredient(json: ingred))
        }
        for i in json["item"]["image"].arrayValue{
            image.append(i.stringValue)
        }
        desc = json["item"]["description"].stringValue
        __v =  json["item"]["__v"].intValue
        for ad in json["item"]["addon"].arrayValue {
            addon.append(ad.stringValue)
        }
        status = json["item"]["status"].boolValue
        category = json["item"]["category"].stringValue
        
    }
}

class SearchMenuItems:NSObject {
    var __v = 0
    var status = false
    var desc = ""
    var price = 0.0
    var menuTag:[String] = []
    var estimatedTime = 0
    var image:[String] = []
    var addon:[String] = []
    var restaurant = ""
    var discount = false
    var createdAt = ""
    var ingredient:[SearchIngredient] = []
    var _id = ""
    var category = ""
    var productId = ""
    var name = ""
    var currency = ""
    
    
    init(json:JSON){
        super.init()
        
        __v = json["__v"].intValue
        status = json["status"].boolValue
        desc = json["description"].stringValue
        price = json["price"].doubleValue
        for m in json["menuTag"].arrayValue {
            menuTag.append(m.stringValue)
        }
        estimatedTime = json["estimatedTime"].intValue
        for i in json["image"].arrayValue{
            image.append(i.stringValue)
        }
        for ad in json["addon"].arrayValue{
            addon.append(ad.stringValue)
        }
        restaurant = json["restaurant"].stringValue
        discount = json["discount"].boolValue
        createdAt = json["createdAt"].stringValue
        for i in json["ingredient"].arrayValue{
            ingredient.append(SearchIngredient(json: i))
        }
        _id = json["_id"].stringValue
        category = json["category"].stringValue
        productId = json["productId"].stringValue
        name = json["name"].stringValue
        currency = json["currency"].stringValue
        
    }
}
