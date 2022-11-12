//
//  MenuComboItems.swift
//  BYT
//
//  Created by RAJ J SAIJA on 21/03/22.
//

import Foundation
import SwiftyJSON
import SwiftUI

class MenuComboItems: NSObject {
    var status = 0
    var menuComboItems:ComboItems!
    
    init(json:JSON){
        super.init()
        status = json["status"].intValue
        menuComboItems = ComboItems(json: json)
    }
}

class ComboItems: NSObject {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[ComboItemsResult] = []
    
    init(json:JSON){
        super.init()
        page = json["menuComboItems"]["page"].intValue
        limit = json["menuComboItems"]["limit"].intValue
        totalDocs = json["menuComboItems"]["totalDocs"].intValue
        totalPages = json["menuComboItems"]["totalPages"].intValue
        pagingCounter = json["menuComboItems"]["pagingCounter"].intValue
        for r in json["menuComboItems"]["result"].arrayValue {
            result.append(ComboItemsResult(json: r))
        }
    }
}

class ComboItemsResult: NSObject {
    var __id = ""
    var name = ""
    var desc = ""
    var category = ""
    var image:[String] = []
    var restaurant = ""
    var items:[ComboResultItems] = []
    var price = 0.0
    var currency = ""
    var status = false
    var discount = false
    var menuTag:[ComboResultMenuTag] = []
    var addon:[ComboResultAddon] = []
    var estimatedTime = 0.0
    var createdAt = ""
    var updatedAt = ""
    var __v = 0
    var type = ""
    
    init(__id: String, name: String, desc: String, category: String, image:[String], restaurant:String, items:[ComboResultItems], price:Double, currency:String, status:Bool, discount:Bool, menuTag:[ComboResultMenuTag], addon:[ComboResultAddon], estimatedTime:Double, createdAt:String, updateAt:String,__v:Int,type:String) {
        
        self.__id = __id
        self.name = name
        self.desc = desc
        self.category = category
        self.image = image
        self.restaurant = restaurant
        self.items = items
        self.price = price
        self.currency = currency
        self.status = status
        self.discount = discount
        self.menuTag = menuTag
        self.addon = addon
        self.estimatedTime = estimatedTime
        self.createdAt = createdAt
        self.updatedAt = updateAt
        self.__v = __v
        self.type = type
        
    }
    
    init(json:JSON){
        super.init()
        __id = json["_id"].stringValue
        name = json["name"].stringValue
        desc = json["description"].stringValue
        category = json["category"].stringValue
        for i in json["image"].arrayValue {
            image.append(i.stringValue)
        }
        restaurant = json["restaurant"].stringValue
        for i in json["items"].arrayValue {
            items.append(ComboResultItems(json: i))
        }
        price = json["price"].doubleValue
        currency = json["currency"].stringValue
        status = json["status"].boolValue
        discount = json["discount"].boolValue
        for m in json["menuTag"].arrayValue {
            menuTag.append(ComboResultMenuTag(json: m))
        }
        for add in json["addon"].arrayValue {
            addon.append(ComboResultAddon(json: add))
        }
        estimatedTime = json["estimatedTime"].doubleValue
        createdAt = json["createdAt"].stringValue
        updatedAt = json["updatedAt"].stringValue
        __v = json["__v"].intValue
        type = json["type"].stringValue
    }
}

class ComboResultItems: NSObject {
    var item:ComboItem!
    var quantity = 0.0
    
    init(item:ComboItem, quantity:Double) {
        self.item = item
        self.quantity = quantity
        
    }
    
    init(json:JSON){
        super.init()
        
        item = ComboItem(json: json)
        quantity = json["quantity"].doubleValue
    }
}


class ComboItem: NSObject {
    var _id = ""
    var name = ""
    var desc = ""
    var image:[String] = []
    var ingredient:[ComboItemIngredient] = []
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
    
    init(_id: String, name: String, desc: String, image:[String], ingredient:[ComboItemIngredient], price:Double, currency:String, status:Bool, discount:Bool, category:String, menuTag:[String], restaurant:String, addon:[String], estimatedTime:Double, createdAt: String, productId:String) {
        
        self._id = _id
        self.name = name
        self.desc = desc
        self.image = image
        self.ingredient = ingredient
        self.price = price
        self.currency = currency
        self.status = status
        self.discount = discount
        self.category = category
        self.menuTag = menuTag
        self.restaurant = restaurant
        self.addon = addon
        self.estimatedTime = estimatedTime
        self.createdAt = createdAt
        self.productId = productId
    }
    
    init(json:JSON) {
        super.init()
        _id = json["item"]["_id"].stringValue
        name = json["item"]["name"].stringValue
        desc = json["item"]["description"].stringValue
        for i in json["item"]["image"].arrayValue{
            image.append(i.stringValue)
        }
        for ingred in json["item"]["ingredient"].arrayValue {
            ingredient.append(ComboItemIngredient(json: ingred))
        }
        price = json["item"]["price"].doubleValue
        currency = json["item"]["currency"].stringValue
        status = json["item"]["status"].boolValue
        discount = json["item"]["discount"].boolValue
        category = json["item"]["category"].stringValue
        for m in json["item"]["menuTag"].arrayValue {
            menuTag.append(m.stringValue)
        }
        restaurant = json["item"]["restaurant"].stringValue
        for add in json["item"]["addon"].arrayValue {
            addon.append(add.stringValue)
        }
        estimatedTime = json["item"]["estimatedTime"].doubleValue
        createdAt = json["item"]["createdAt"].stringValue
        productId = json["item"]["productId"].stringValue
        
    }
}

class ComboItemIngredient: NSObject {
    var item = ""
    var quantity = ""
    var wastage = 0
    
    init(item: String, quantity: String, wastage: Int) {
        self.item = item
        self.quantity = quantity
        self.wastage = wastage
        
    }
    
    init(json:JSON){
        super.init()
        item = json["item"].stringValue
        quantity = json["quantity"].stringValue
        wastage = json["wastage"].intValue
    }
}

class ComboResultMenuTag: NSObject {
    
    var _id = ""
    var name = ""
    var restaurant = ""
    var createdAt = ""
    var __v = 0
    
    init(_id: String, name: String, restaurant: String, createdAt: String, __v:Int) {
        self._id = _id
        self.name = name
        self.restaurant = restaurant
        self.createdAt = createdAt
        self.__v = __v
    }
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        restaurant = json["restaurant"].stringValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}

class ComboResultAddon: NSObject {
    
    var _id = ""
    var name = ""
    var restaurant = ""
    var price = 0.0
    var quantity = 0.0
    var createdAt = ""
    var __v = 0
    
    init(_id: String, name: String, restaurant: String, price: Double, quantity:Double, createdAt:String, __v:Int) {
        self._id = _id
        self.name = name
        self.restaurant = restaurant
        self.price = price
        self.quantity = quantity
        self.createdAt = createdAt
        self.__v = __v
    }
    
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        restaurant = json["restaurant"].stringValue
        price = json["price"].doubleValue
        quantity = json["quantity"].doubleValue
        createdAt = json["createdAt"].stringValue
        __v = json[].intValue
    }
}
