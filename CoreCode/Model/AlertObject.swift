//
//  AlertObject.swift
//  projectName
//
//  companyName on 09/02/22.
//

import Foundation

class AlertObject: NSObject, Codable {
    var _id: String = ""
    var user: String = ""
    var alertName: String = ""
    var alertPrice: String = ""
    var alertFlag: String = ""
    var alertSide: String = ""
    var alertShareName: String = ""
    var alertSharesymbol: String = ""
    var exchange: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    var image: String = ""
    
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
        self.user = dictionary["user"] as? String ?? ""
        self.alertName = dictionary["alertName"] as? String ?? ""
        self.alertPrice = dictionary["alertPrice"] as? String ?? ""
        self.alertFlag = dictionary["alertFlag"] as? String ?? ""
        self.alertSide = dictionary["alertSide"] as? String ?? ""
        self.alertShareName = dictionary["alertShareName"] as? String ?? ""
        self.alertSharesymbol = dictionary["alertSharesymbol"] as? String ?? ""
        self.exchange = dictionary["exchange"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
        
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
