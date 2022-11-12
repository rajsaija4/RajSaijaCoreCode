//
//  ThemeStockObject.swift
//  projectName
//
//  companyName on 03/02/22.
//

import Foundation

class ThemeStockObject: NSObject, Codable {
    var _id: String = ""
    var category: String = ""
    var categoryName: String = ""
    var assetId: String = ""
    var class_category: String = ""
    var exchange: String = ""
    var symbol: String = ""
    var name: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    var image: String = ""
    var companyName: String = ""
    var symbole_description: String = ""
    
    //SNAPSHOT OBJECT
    var objSnapshot: SnapshotObject = SnapshotObject.init([:])
    
    var openPrice: Double = 0.0
    var closePrice: Double = 0.0
    var highPrice: Double = 0.0
    var lowPrice: Double = 0.0
    var volume: Int = 0
    var tradeCount: Int = 0
    var current_price: Double = 0.0
    var prev_close_price: Double = 0.0
    var plVariationValue: Double = 0.0
    var plVariationPer: Double = 0.0
    
    init(_ dictionary: [String: Any]) {
        self._id = dictionary["_id"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        self.categoryName = dictionary["categoryName"] as? String ?? ""
        self.assetId = dictionary["assetId"] as? String ?? ""
        self.class_category = dictionary["class"] as? String ?? ""
        self.exchange = dictionary["exchange"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
        self.companyName = dictionary["companyName"] as? String ?? ""
        self.symbole_description = dictionary["symbole_description"] as? String ?? ""
        
        if let snapshot = dictionary["snapshot"] as? Dictionary<String, Any> {
            self.objSnapshot = SnapshotObject.init(snapshot)
            
            self.openPrice = self.objSnapshot.objDailyBar.o
            self.closePrice = self.objSnapshot.objDailyBar.c
            self.highPrice = self.objSnapshot.objDailyBar.h
            self.lowPrice = self.objSnapshot.objDailyBar.l
            self.volume = self.objSnapshot.objDailyBar.v
            self.tradeCount = dictionary["tradeCount"] as? Int ?? 0
            
            self.current_price = self.objSnapshot.objDailyBar.c
            self.prev_close_price = self.objSnapshot.objPrevDailyBar.c
            self.plVariationValue = self.current_price - self.prev_close_price
            self.plVariationPer = (self.plVariationValue * 100) / self.prev_close_price
        }
    }
}
