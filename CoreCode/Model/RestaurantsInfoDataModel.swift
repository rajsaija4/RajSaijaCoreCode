////
////  RestaurantsInfoModel.swift
////  BYT
////
////  Created by RAJ J SAIJA on 10/01/22.
////
//
//import Foundation
//import SwiftyJSON
//import Alamofire
//
//class RestaurantsInfoDataModel.swift: NSObject {
//
//    var restaurants_count = 0
//    var restaurants:HotelInfo!
//
//    init(json:JSON){
//        super.init()
//        restaurants_count = json["restaurants_count"].intValue
//        restaurants = HotelInfo(json: json)
//    }
//}
//
//class HotelInfo: NSObject {
//
//    var page = 0
//    var limit = 0
//    var totalDocs = 0
//    var totalPages = 0
//    var pagingCounter = 0
//    var result:[ResultData] = []
//
//    init(json:JSON){
//        super.init()
//
//        page = json["restaurants"]["page"].intValue
//        limit = json["restaurants"]["limit"].intValue
//        totalDocs = json["restaurants"]["totalDocs"].intValue
//        totalPages = json["restaurants"]["totalPages"].intValue
//        pagingCounter = json["restaurants"]["pagingCounter"].intValue
//        for r in json["restaurants"]["result"].arrayValue {
//            result.append(RestaurantsInfoModel(json: r))
//        }
//    }
//}
//
//class RestaurantsInfoModel: NSObject {
//
//    var id = ""
//    var name = ""
//    var city = ""
//    var isOwner = false
//    var owner:[RestaurantsDetails] = []
//    var std = ""
//    var contact:[String] = []
//    var coords:Location!
//    var status = false
//    var paymentMethod = ""
//    var tags:[String] = []
//    var openDays:[String] = []
//    var openTiming:[String] = []
//    var email = ""
//    var website = ""
//    var desc = ""
//    var image = ""
//    var ratings = 0
//    var discount = 0
//    var createdAt = ""
//    var __V = 0
//    var fullDistance = 0
//    var distance = 0
//    var package:[String] = []
//    var menus:[Menus] = []
//    var menuCount = 0
//    var reviwer:[String] = []
//    var reviews:[String] = []
//    var reviewCount = 0
//
//    init(json:JSON){
//        super.init()
//
//        id = json["_id"].stringValue
//        name = json["name"].stringValue
//        city = json["city"].stringValue
//        isOwner = json["isOwner"].boolValue
//        for o in json["owner"].arrayValue {
//            owner.append(RestaurantsDetails(json: o))
//        }
//        std = json["std"].stringValue
//        for c in json["contact"].arrayValue {
//            contact.append(c.stringValue)
//        }
//        coords = Location(json: json)
//        status = json["status"].boolValue
//        for t in json["tags"].arrayValue {
//            tags.append(t.stringValue)
//        }
//        paymentMethod = json["paymentMethod"].stringValue
//        for days in json["openDays"].arrayValue{
//            openDays.append(days.stringValue)
//        }
//        email = json["email"].stringValue
//        website = json["website"].stringValue
//        desc = json["description"].stringValue
//
//
//        for time in json["openTiming"].arrayValue{
//            openTiming.append(time.stringValue)
//        }
//        image = json["image"].stringValue
//        ratings = json["ratings"].intValue
//        discount = json["discount"].intValue
//        createdAt = json["createdAt"].stringValue
//        __V = json["__v"].intValue
//        fullDistance = json["fullDistance"].intValue
//        distance = json["distance"].intValue
//        for p in json["package"].arrayValue{
//            package.append(p.stringValue)
//        }
//        for menu in json["menus"].arrayValue {
//            menus.append(Menus(json: menu))
//        }
//        for r in json["reviews"].arrayValue{
//            reviews.append(r.stringValue)
//        }
//        reviewCount = json["reviewCount"].intValue
//        menuCount = json["menuCount"].intValue
//        for r in json["reviewer"].arrayValue{
//            reviwer.append(r.stringValue)
//        }
//    }
//}
//
//class RestaurantsDetails: NSObject {
//
//    var id = ""
//    var name = ""
//    var mobile = ""
//    var email = ""
//    var address = ""
//    var profile = ""
//    var restaurantCount = 0
//    var restaurantType = false
//    var role = ""
//    var createdAt = ""
//    var v = 0
//
//    init(json:JSON) {
//        super.init()
//
//        id = json["_id"].stringValue
//        name = json["name"].stringValue
//        mobile = json["mobile"].stringValue
//        email = json["email"].stringValue
//        address = json["address"].stringValue
//        profile = json["profile"].stringValue
//        restaurantCount = json["restaurantCount"].intValue
//        restaurantType = json["restaurantType"].boolValue
//        role = json["role"].stringValue
//        createdAt = json["createdAt"].stringValue
//        v = json["__v"].intValue
//    }
//}
//
//class Location: NSObject {
//    var type = ""
//    var coordinates:[Double] = []
//
//    init(json:JSON) {
//        super.init()
//        type = json["coords"]["type"].stringValue
//        for c in json["coords"]["coordinates"].arrayValue {
//            coordinates.append(c.doubleValue)
//        }
//    }
//}
//
//class Menus: NSObject {
//    var id = ""
//    var name = ""
//    var desc = ""
//    var image:[String] = []
//    var ingredient:[Ingredient] = []
//    var price = 0.0
//    var currency = ""
//    var status = false
//    var discount = false
//    var category = ""
//    var menuTag:[String] = []
//    var restaurant = ""
//    var addon:[String] = []
//    var estimatedTime = 0
//    var createdAt = ""
//    var productId = ""
//
//    init(json:JSON){
//        super.init()
//        id = json["_id"].stringValue
//        name = json["name"].stringValue
//        desc = json["description"].stringValue
//        for i in json["image"].arrayValue{
//            image.append(i.stringValue)
//        }
//        for ingrid in json["ingredient"].arrayValue {
//            ingredient.append(Ingredient(json: ingrid))
//        }
//        price = json["price"].doubleValue
//        currency = json["currency"].stringValue
//        status = json["status"].boolValue
//        discount = json["discount"].boolValue
//        category = json["category"].stringValue
//        for m in json["menuTag"].arrayValue{
//            menuTag.append(m.stringValue)
//        }
//        restaurant = json["restaurant"].stringValue
//        for add in json["addon"].arrayValue{
//            addon.append(add.stringValue)
//        }
//        estimatedTime = json["estimatedTime"].intValue
//        createdAt = json["createdAt"].stringValue
//        productId = json["productId"].stringValue
//    }
//}
//
//class Ingredient: NSObject {
//    var item = ""
//    var quantiy = ""
//    var wastage = 0.0
//
//    init(json:JSON) {
//        super.init()
//
//        item = json["item"].stringValue
//        quantiy = json["quantity"].stringValue
//        wastage = json["wastage"].doubleValue
//    }
//}
