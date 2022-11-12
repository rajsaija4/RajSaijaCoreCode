//
//  AssetsObject.swift
//  projectName
//
//  companyName on 22/03/22.
//

import Foundation

class AssetsObject: NSObject, Codable {
    var id: String = ""
    var class_type: String = ""
    var exchange: String = ""
    var symbol: String = ""
    var name: String = ""
    var status: String = ""
    var tradable: Bool = false
    var marginable: Bool = false
    var shortable: Bool = false
    var easy_to_borrow: Bool = false
    var fractionable: Bool = false
    var companyName:String = ""
    var symbole_description:String = ""
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
        self.id = dictionary["id"] as? String ?? ""
        self.class_type = dictionary["class"] as? String ?? ""
        self.exchange = dictionary["exchange"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.tradable = dictionary["tradable"] as? Bool ?? false
        self.marginable = dictionary["marginable"] as? Bool ?? false
        self.shortable = dictionary["shortable"] as? Bool ?? false
        self.easy_to_borrow = dictionary["easy_to_borrow"] as? Bool ?? false
        self.fractionable = dictionary["fractionable"] as? Bool ?? false
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
