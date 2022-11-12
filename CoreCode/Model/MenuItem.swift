//
//  MenuItem.swift
//  BYT
//
//  Created by RAJ J SAIJA on 13/12/21.
//

import SwiftyJSON
import Alamofire
import SwiftUI

class MenuItem: NSObject {
    
    var menuItems_count = 1
    var menuItems:Menu!
    
    init(json:JSON){
        super.init()
        menuItems_count = json[menuItems_count].intValue
        menuItems = Menu(json: json)
    }
}


class Menu: NSObject {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 1
    var pagingCounter = 1
    var result:[MenuResult] = []
    
    init(json:JSON) {
        super.init()
        
        page = json["menuItems"]["page"].intValue
        limit = json["menuItems"]["limit"].intValue
        totalDocs = json["menuItems"]["totalDocs"].intValue
        totalPages = json["menuItems"]["totalPages"].intValue
        pagingCounter = json["menuItems"]["pagingCounter"].intValue
        for r in json["menuItems"]["result"].arrayValue {
            result.append(MenuResult(json: r))
        }
    }
}

class MenuResult: NSObject {
    
    var __id = ""
    var name = ""
    var desc = ""
    var image:[String] = []
    var ingredient:[Ingredient] = []
    var price = 0.0
    var currency = ""
    var status = false
    var discount = false
    var category = ""
    var menuTag:[String] = []
    var restaurant = ""
    var addon:[String] = []
    var estimatedTime = 0.0
    var createdAt = ""
    var productId = ""
    var __v = 0
    var orders = ""
    
    init(json:JSON){
        super.init()
        
        __id = json["_id"].stringValue
        name = json["name"].stringValue
        desc = json["description"].stringValue
        for i in json["image"].arrayValue {
            image.append(i.stringValue)
        }
        for i in json["ingredient"].arrayValue {
            ingredient.append(Ingredient(json: i))
        }
        price = json["price"].doubleValue
        currency = json["currency"].stringValue
        status = json["status"].boolValue
        discount = json["discount"].boolValue
        category = json["category"].stringValue
        for m in json["menuTag"].arrayValue {
            menuTag.append(m.stringValue)
        }
        restaurant = json["restaurant"].stringValue
        for add in json["addon"].arrayValue {
            addon.append(add.stringValue)
        }
        estimatedTime = json["estimatedTime"].doubleValue
        createdAt = json["createdAt"].stringValue
        productId = json["productId"].stringValue
        __v = json["__v"].intValue
        orders = json["orders"].stringValue
    }
}


