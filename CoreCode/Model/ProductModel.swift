//
//  ProductModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 31/01/22.
//

import Foundation

class ProductModel: NSCoder, NSCoding {
    var id = ""
    var name = ""
    var quantity = 0
    var estimatedTime = 0.0
    var price = 0.0
    var note = ""
    var image = ""
    var category = ""
    var type = ""
    var customer:[ProductCustomer]
    
    init(id:String,name:String,quantity:Int,estimatedTime:Double,price:Double,note:String, image:String, category:String, type:String, customer:[ProductCustomer]) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.estimatedTime = estimatedTime
        self.price = price
        self.note = note
        self.image = image
        self.category = category
        self.customer = customer
        self.type = type
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id,forKey: "id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(estimatedTime, forKey: "estimatedTime")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(image, forKey: "image")
        aCoder.encode(type, forKey: "type")
        aCoder.encode(customer, forKey: "customer")
        aCoder.encode(category, forKey: "category")
    }
    
    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        quantity = aDecoder.decodeInteger(forKey: "quantity")
        estimatedTime = aDecoder.decodeDouble(forKey: "estimatedTime")
        price = aDecoder.decodeDouble(forKey: "price")
        note = aDecoder.decodeObject(forKey: "note") as! String
        image = aDecoder.decodeObject(forKey: "image") as! String
        category = aDecoder.decodeObject(forKey: "category") as! String
        type = aDecoder.decodeObject(forKey: "type") as! String
        customer = aDecoder.decodeObject(of: [ProductCustomer.self], forKey: "customer") as! [ProductCustomer]
    }
    
    static var arrSelectedProduct:[ProductModel] = []
    static var arrCustomerAddedProduct:[ProductModel] = []
    static var arrdummyCustomerAddedProduct:[ProductModel] = []
    static var arrDummyProduct:[ProductModel] = []
    
    static func customerEditProduct() {
        ProductModel.arrCustomerAddedProduct.removeAll()
        for i in ProductModel.arrSelectedProduct {
            for customer in i.customer {
                if customer.customerId == Registered.details.registeredUser?._id {
                    ProductModel.arrCustomerAddedProduct.append(i)
                }
            }
        }
    }
    
    static func dummyEditProduct() {
        ProductModel.arrDummyProduct.removeAll()
        for i in ProductModel.arrdummyCustomerAddedProduct {
            for customer in i.customer {
                if customer.customerId == Registered.details.registeredUser?._id {
                    ProductModel.arrDummyProduct.append(i)
                }
            }
        }
    }
}

//extension ProductModel {
//
//    static var isExist: Bool {
//        let decodedData  = UserDefaults.standard.object(forKey: "saveUserCartDetails") as? Data
//        return decodedData != nil
//    }
//
//    static var details: ProductModel {
//        get {
//            let decodedData  = UserDefaults.standard.object(forKey: "saveUserCartDetails") as! Data
//            let userCartDetails = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedData) as! ProductModel
//            return userCartDetails
//        }
//    }
//}

extension ProductModel {
    
    static func saveCartDetails() {
        
        let cartData = NSKeyedArchiver.archivedData(withRootObject: ProductModel.arrSelectedProduct)
        UserDefaults.standard.set(cartData, forKey: "saveUserCartDetails")
    }
    
    //    static func saveCartDetails() {
    //
    //        let cartData = NSKeyedArchiver.archivedData(withRootObject: ProductModel.arrSelectedProduct)
    //         UserDefaults.standard.set(cartData, forKey: "saveUserCartDetails")
    //     }
    
    static func loadPlaces() {
        guard let cartData = UserDefaults.standard.object(forKey: "saveUserCartDetails") as? NSData else {
            debugPrint("Cart is Empty")
            return
        }
        
        guard let cartArray = NSKeyedUnarchiver.unarchiveObject(with: cartData as Data) as? [ProductModel] else {
            debugPrint("Could not unarchive from placesData")
            return
        }
        
        ProductModel.arrSelectedProduct.removeAll()
        ProductModel.arrSelectedProduct = cartArray
    }
    
    static func delete() {
        UserDefaults.standard.removeObject(forKey: "saveUserCartDetails")
        UserDefaults.standard.synchronize()
    }
}

class ProductAddons:NSCoder,NSCoding {
    var _id = ""
    var name = ""
    var restaurant = ""
    var price = 0.0
    var quantity = 0
    var createdAt = ""
    var __v = 0
    
    init(_id:String, name:String, restaurant:String, price:Double, quantity:Int, createdAt:String, __v:Int) {
        
        self._id = _id
        self.name = name
        self.restaurant = restaurant
        self.price = price
        self.quantity = quantity
        self.createdAt = createdAt
        self.__v = __v
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_id,forKey: "_id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(restaurant, forKey: "restaurant")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(__v, forKey: "__v")
    }
    
    required init?(coder aDecoder: NSCoder) {
        _id = aDecoder.decodeObject(forKey: "_id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        restaurant = aDecoder.decodeObject(forKey: "restaurant") as! String
        price = aDecoder.decodeDouble(forKey: "price")
        quantity = aDecoder.decodeInteger(forKey: "quantity")
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as! String
        __v = aDecoder.decodeInteger(forKey: "__v")
    }
}

class ProductCustomer: NSObject, NSCoding {
    var customerId = ""
    var customerImage = ""
    var quantity = 0
    var addon:[ProductAddons]?
    var totalPrice = 0.0
    
    init(customerId:String, quantity:Int,addon:[ProductAddons]?, totalPrice:Double, customerImage:String) {
        self.customerId = customerId
        self.quantity = quantity
        self.addon = addon
        self.totalPrice = totalPrice
        self.customerImage = customerImage
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(customerId,forKey: "customerId")
        aCoder.encode(quantity, forKey: "quantity")
        aCoder.encode(addon, forKey: "addon")
        aCoder.encode(totalPrice, forKey: "totalPrice")
        aCoder.encode(customerImage, forKey: "customerImage")
    }
    
    required init?(coder aDecoder: NSCoder) {
        customerId = aDecoder.decodeObject(forKey: "customerId") as! String
        quantity = aDecoder.decodeInteger(forKey: "quantity")
        addon = aDecoder.decodeObject(of: [ProductAddons.self], forKey: "addon") as? [ProductAddons]
        totalPrice = aDecoder.decodeDouble(forKey: "totalPrice")
        customerImage = aDecoder.decodeObject(forKey: "customerImage") as! String
    }
}
