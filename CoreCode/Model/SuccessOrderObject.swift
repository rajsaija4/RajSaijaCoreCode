//
//  SucessOrderObject.swift
//  BYT
//
//  Created by RAJ J SAIJA on 15/02/22.
//

import Foundation
import SwiftyJSON
import UIKit

class SuccessOrderObject:NSObject {
    
    var _id = ""
    var customer:[OrderCustomer] = []
    var restaurant:[OrderRestaurant] = []
    var category = ""
    var orderStatus = ""
    var orderType = ""
    var paymentType = ""
    var paymentMethod = ""
    var paymentStatus = false
    var table:[TableConfirm] = []
    var guests:[OrderGuests] = []
    var items:[OrderItems] = []
    var visitors:OrderVisitors!
    var status = false
    var instructions = ""
    var waitingList = 0
    var deliveryTime = ""
    var estimatedTime = 0
    var price:OrderPrice!
    var reOrder:ReOrder!
    var orderNo = ""
    var createdAt = ""
    var updatedAt = ""
    var __v = 0
    
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        for c in json["customer"].arrayValue {
            customer.append(OrderCustomer(json: c))
        }
        for r in json["restaurant"].arrayValue {
            restaurant.append(OrderRestaurant(json: r))
        }
        category = json["category"].stringValue
        orderStatus = json["orderStatus"].stringValue
        orderType = json["orderType"].stringValue
        paymentType = json["paymentType"].stringValue
        paymentMethod = json["paymentMethod"].stringValue
        paymentStatus = json["paymentStatus"].boolValue
        for t in json["table"].arrayValue {
            table.append(TableConfirm(json: t))
            
        }
        for g in json["guests"].arrayValue {
            guests.append(OrderGuests(json: g))
        }
        for item in json["items"].arrayValue {
            items.append(OrderItems(json: item))
        }
        visitors = OrderVisitors(json: json)
        status = json["status"].boolValue
        instructions = json["instructions"].stringValue
        waitingList = json["waitingList"].intValue
        deliveryTime = json["deliveryTime"].stringValue
        estimatedTime = json["estimatedTime"].intValue
        price = OrderPrice(json: json)
        reOrder = ReOrder(json: json)
        orderNo = json["orderNo"].stringValue
        createdAt = json["createdAt"].stringValue
        updatedAt = json["updatedAt"].stringValue
        __v = json["__v"].intValue
    }
}

class TableConfirm:NSObject {
    var restaurant  = ""
    var costPerson = 0.0
    var floorType = ""
    var position:TablePosition!
    var tableNo = 0
    var updatedAt = ""
    var createdAt = ""
    var bookingStatus = false
    var capacity = 0
    var __v = 0
    var _id = ""
    
    init(json:JSON){
        super.init()
        
        restaurant = json["restaurant"].stringValue
        costPerson = json["costPerson"].doubleValue
        floorType = json["floorType"].stringValue
        position = TablePosition(json: json)
        tableNo = json["tableNo"].intValue
        updatedAt = json["updatedAt"].stringValue
        createdAt = json["createdAt"].stringValue
        bookingStatus = json["bookingStatus"].boolValue
        capacity = json["capacity"].intValue
        __v = json["__v"].intValue
        _id = json["_id"].stringValue
    }
    
}

class OrderPrice:NSObject {
    var addon = 0.0
    var points = 0.0
    var tip = 0.0
    var subtotal = 0.0
    var tax = 0.0
    var total = 0.0
    
    init(json:JSON){
        super.init()
        
        addon = json["price"]["addon"].doubleValue
        points = json["price"]["points"].doubleValue
        tip = json["price"]["tip"].doubleValue
        subtotal = json["price"]["subtotal"].doubleValue
        tax = json["price"]["tax"].doubleValue
        total = json["price"]["total"].doubleValue
    }
    
}

class ReOrder:NSObject {
    var count = 0
    
    init(json:JSON){
        super.init()
        
        count = json["reOrder"]["count"].intValue
    }
}

class OrderVisitors:NSObject {
    var adult = 0
    var children = 0
    
    init(json:JSON){
        super.init()
        
        adult = json["visitors"]["adult"].intValue
        children = json["visitors"]["children"].intValue
    }
}

class OrderCustomer:NSObject {
    var _id = ""
    var name = ""
    var email = ""
    var mobile = ""
    var dob = ""
    var diet:[String] = []
    var profile = ""
    var coverPhoto = ""
    var role = ""
    var blacklist = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0
    var createdAt = ""
    
    init(json:JSON){
        super.init()
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        mobile = json["mobile"].stringValue
        dob = json["dob"].stringValue
        for d in json["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        profile = json["profile"].stringValue
        coverPhoto = json["coverPhoto"].stringValue
        role = json["role"].stringValue
        blacklist = json["blacklist"].boolValue
        language = json["language"].stringValue
        bytPoints = json["bytPoints"].intValue
        avgSpend = json["avgSpend"].intValue
        createdAt = json["createdAt"].stringValue
        
    }
}


class OrderRestaurant:NSObject {
    
    var id = ""
    var name = ""
    var city = ""
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
    var cuisines = ""
    var tags:[String] = []
    var openDays:[String] = []
    var openTiming:[String] = []
    var email = ""
    var website = ""
    var image = ""
    var package = ""
    var ratings = 0.0
    var facebook = ""
    var instagram = ""
    var twitter = ""
    var desc = ""
    var discount = 0
    var createdAt = ""
    var updatedAt = ""
    var alcoholserve = false
    
    
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
        location = json["location"].stringValue
        coords = Coords(json: json)
        status = json["status"].boolValue
        services = json["services"].stringValue
        seating = json["seating"].stringValue
        for s in json["seatingPreference"].arrayValue {
            seatingPreference.append(s.stringValue)
        }
        paymentMethod = json["paymentMethod"].stringValue
        cuisines = json["cuisines"].stringValue
        
        for t in json["tags"].arrayValue {
            tags.append(t.stringValue)
        }
        for days in json["openDays"].arrayValue{
            openDays.append(days.stringValue)
        }
        for time in json["openTiming"].arrayValue{
            openTiming.append(time.stringValue)
        }
        email = json["email"].stringValue
        website = json["website"].stringValue
        image = json["image"].stringValue
        package = json["package"].stringValue
        ratings = json["ratings"].doubleValue
        facebook = json["facebook"].stringValue
        instagram = json["instagram"].stringValue
        twitter = json["twitter"].stringValue
        desc = json["description"].stringValue
        discount = json["discount"].intValue
        createdAt = json["createdAt"].stringValue
        updatedAt = json["updatedAt"].stringValue
        alcoholserve = json["alcoholServe"].boolValue
    }
}


class OrderGuests:NSObject {
    var language = ""
    var role = ""
    var name = ""
    var email = ""
    var diet:[String] = []
    var createdAt = ""
    var dob = ""
    var coverPhoto = ""
    var mobile = ""
    var _id = ""
    var avgSpend = 0.0
    var __v = 0
    var profile = ""
    var bytPoints = 0
    var blackList = false
    
    init(json:JSON){
        super.init()
        language = json["language"].stringValue
        role = json["role"].stringValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        for d in json["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        createdAt = json["createdAt"].stringValue
        dob = json["dob"].stringValue
        coverPhoto = json["coverPhoto"].stringValue
        mobile = json["mobile"].stringValue
        _id = json["_id"].stringValue
        avgSpend = json["avgSpend"].doubleValue
        __v = json["__v"].intValue
        profile = json["profile"].stringValue
        bytPoints = json["bytPoints"].intValue
        blackList = json["blacklist"].boolValue
    }
}

class OrderItems:NSObject {
    var combo:Combo!
    var item:OrderItem!
    var quantity = 0
    var customer:[OrderCustomerDetails] = []
    var estimatedTime = 0
    var addons:[OrderAddons] = []
    var totalPrice:OrderTotalPrice!
    var price = 0.0
    var review:OrderReview!
    
    init(json:JSON){
        super.init()
        
        combo = Combo(json: json)
        item = OrderItem(json: json)
        quantity = json["quantity"].intValue
        for c in json["customer"].arrayValue {
            customer.append(OrderCustomerDetails(json: c))
        }
        estimatedTime = json["estimatedTime"].intValue
        for add in json["addons"].arrayValue {
            addons.append(OrderAddons(json: add))
        }
        totalPrice = OrderTotalPrice(json: json)
        price = json["price"].doubleValue
        review = OrderReview(json: json)
    }
    
    
}

class Combo: NSObject {
    var estimatedTime = 0
    var name = ""
    var discount = false
    var _id = ""
    var currency = ""
    var restaurant = ""
    var createdAt = ""
    var category = ""
    var status = false
    var updatedAt = ""
    var price = 0.0
    var items:[SuccessOrderCombo] = []
    var desc = ""
    var menuTag:[String] = []
    var addon:[String] = []
    var image:[String] = []
    
    init(json:JSON) {
        super.init()
        
        estimatedTime = json["combo"]["estimatedTime"].intValue
        name = json["combo"]["name"].stringValue
        discount = json["combo"]["discount"].boolValue
        _id = json["combo"]["_id"].stringValue
        currency = json["combo"]["currency"].stringValue
        restaurant = json["combo"]["restaurant"].stringValue
        createdAt = json["combo"]["createdAt"].stringValue
        category = json["combo"]["category"].stringValue
        status = json["combo"]["status"].boolValue
        updatedAt = json["combo"]["updatedAt"].stringValue
        price = json["combo"]["price"].doubleValue
        desc = json["combo"]["description"].stringValue
        for i in json["combo"]["items"].arrayValue {
            items.append(SuccessOrderCombo(json: i))
        }
        for tag in json["combo"]["menuTag"].arrayValue {
            menuTag.append(tag.stringValue)
        }
        for ad in json["combo"]["addon"].arrayValue {
            addon.append(ad.stringValue)
        }
        for photo in json["combo"]["image"].arrayValue {
            image.append(photo.stringValue)
        }
    }
}

class SuccessOrderCombo: NSObject {
    var quantity = 0
    var item = ""
    
    init(json:JSON){
        super.init()
        
        quantity = json[""].intValue
        item = json[""].stringValue
    }
}

class OrderItem:NSObject {
    var _id = ""
    var name = ""
    var desc = ""
    var image:[String] = []
    var ingredient:[OrderIngredient] = []
    var price = 0.0
    var currency = ""
    var status = false
    var discount = false
    var category = ""
    var menuTag:[String] = []
    var restaurant = ""
    var addon:[String] = []
    var estimatedTime = 0
    var createdAt = ""
    var productId = ""
    var __V = 0
    
    
    init(json:JSON){
        super.init()
        
        _id = json["item"]["_id"].stringValue
        name = json["item"]["name"].stringValue
        desc = json["item"]["description"].stringValue
        for i in json["item"]["image"].arrayValue {
            image.append(i.stringValue)
        }
        for i in json["item"]["ingredient"].arrayValue {
            ingredient.append(OrderIngredient(json: i))
        }
        price = json["item"]["price"].doubleValue
        currency = json["item"]["currency"].stringValue
        status = json["item"]["status"].boolValue
        discount = json ["item"]["discount"].boolValue
        category = json["item"]["category"].stringValue
        for m in json["item"]["menuTag"].arrayValue {
            menuTag.append(m.stringValue)
        }
        restaurant = json["item"]["restaurant"].stringValue
        for a in json["item"]["addon"].arrayValue {
            addon.append(a.stringValue)
        }
        estimatedTime = json["item"]["estimatedTime"].intValue
        createdAt = json["item"]["createdAt"].stringValue
        productId = json["item"]["productId"].stringValue
        __V = json["item"]["__v"].intValue
    }
}

class OrderIngredient:NSObject {
    var item = ""
    var quantity = ""
    var wastage = 0.0
    
    init(json:JSON){
        super.init()
        
        item = json["item"].stringValue
        quantity = json["quantity"].stringValue
        wastage = json["wastage"].doubleValue
    }
}


class OrderCustomerDetails:NSObject {
    var customerId:orderCustomerId!
    var quantity = 0
    var totalPrice = 0.0
    var addon:[AddonObject] = []
    
    
    init(json:JSON){
        super.init()
        
        customerId = orderCustomerId(json: json)
        quantity = json["quantity"].intValue
        totalPrice = json["totalPrice"].doubleValue
        
        for add in json["addon"].arrayValue {
            addon.append(AddonObject(json: add))
        }
    }
}

class orderCustomerId:NSObject {
    
    var _id = ""
    var name = ""
    var email = ""
    var mobile = ""
    var dob = ""
    var diet:[String] = []
    var profile = ""
    var coverPhoto = ""
    var role = ""
    var blacklist = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0
    var createdAt = ""
    
    init(json:JSON){
        super.init()
        _id = json["customerId"]["_id"].stringValue
        name = json["customerId"]["name"].stringValue
        email = json["customerId"]["email"].stringValue
        mobile = json["customerId"]["mobile"].stringValue
        dob = json["customerId"]["dob"].stringValue
        for d in json["customerId"]["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        profile = json["customerId"]["profile"].stringValue
        coverPhoto = json["customerId"]["coverPhoto"].stringValue
        role = json["customerId"]["role"].stringValue
        blacklist = json["customerId"]["blacklist"].boolValue
        language = json["customerId"]["language"].stringValue
        bytPoints = json["customerId"]["bytPoints"].intValue
        avgSpend = json["customerId"]["avgSpend"].intValue
        createdAt = json["customerId"]["createdAt"].stringValue
        
    }
}

class AddonObject:NSObject {
    var id:OrderAddonId!
    var quantity = 0
    var price = 0.0
    
    init(json:JSON){
        super.init()
        
        id = OrderAddonId(json: json)
        quantity = json["quantity"].intValue
        price = json["price"].doubleValue
    }
    
}

class OrderAddonId:NSObject {
    var _id = ""
    var name = ""
    var restaurant = ""
    var price = 0.0
    var quantity = 0
    var createdAt = ""
    var __v = 0
    
    
    init(json:JSON){
        super.init()
        
        _id = json["id"]["_id"].stringValue
        name = json["id"]["name"].stringValue
        restaurant = json["id"]["restaurant"].stringValue
        price = json["id"]["price"].doubleValue
        quantity = json["id"]["quantity"].intValue
        createdAt = json["id"]["createdAt"].stringValue
        __v = json["id"]["__v"].intValue
        
    }
}

class AddonsId:NSObject {
    var _id = ""
    var name = ""
    var restaurant = ""
    var price = 0.0
    var quantity = 0
    var createdAt = ""
    var __v = 0
    
    
    init(json:JSON){
        super.init()
        
        _id = json["id"]["_id"].stringValue
        name = json["id"]["name"].stringValue
        restaurant = json["id"]["restaurant"].stringValue
        price = json["id"]["price"].doubleValue
        quantity = json["id"]["quantity"].intValue
        createdAt = json["id"]["createdAt"].stringValue
        __v = json["id"]["__v"].intValue
        
    }
}

class OrderAddons:NSObject {
    
    var id:AddonsId!
    var quantity = 0
    
    init(json:JSON){
        super.init()
        
        id = AddonsId(json: json)
        quantity = json["quantity"].intValue
    }
}


class OrderTotalPrice:NSObject {
    var itemPrice = 0.0
    var addonPrice = 0.0
    var total = 0.0
    
    init(json:JSON){
        super.init()
        
        itemPrice = json["totalPrice"]["itemPrice"].doubleValue
        addonPrice = json["totalPrice"]["addonPrice"].doubleValue
        total = json["totalPrice"]["total"].doubleValue
    }
}


class OrderReview:NSObject {
    var count = 0
    var avgRating = 0.0
    
    init(json:JSON){
        super.init()
        
        count = json["review"]["count"].intValue
        avgRating = json["review"]["avgRating"].doubleValue
    }
}

