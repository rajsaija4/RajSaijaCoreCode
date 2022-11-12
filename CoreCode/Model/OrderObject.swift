//
//  OrderObject.swift
//  projectName
//
//  companyName on 11/02/22.
//

import Foundation

class OrderObject: NSObject, Codable {
    var id: String = ""
    var client_order_id: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var submitted_at: String = ""
    var filled_at: String = ""
    var expired_at: String = ""
    var canceled_at: String = ""
    var failed_at: String = ""
    var replaced_at: String = ""
    var replaced_by: String = ""
    var replaces: String = ""
    var asset_id: String = ""
    var symbol: String = ""
    var asset_class: String = ""
    var notional: String = ""
    var qty: String = ""
    var filled_qty: String = ""
    var filled_avg_price: String = ""
    var order_class: String = ""
    var order_type: String = ""
    var type: String = ""
    var side: String = ""
    var time_in_force: String = ""
    var limit_price: String = ""
    var stop_price: String = ""
    var status: String = ""
    var extended_hours: Bool = false
    var legs: String = ""
    var trail_percent: String = ""
    var trail_price: String = ""
    var hwm: String = ""
    var commission: String = ""
    var image: String = ""
    var fractional: String = ""
    
    var openPrice: Double = 0.0
    var closePrice: Double = 0.0
    var highPrice: Double = 0.0
    var lowPrice: Double = 0.0
    var plVariationValue: Double = 0.0
    var plVariationPer: Double = 0.0
    var volume: Int = 0
    var tradeCount: Int = 0
    var current_price: Double = 0.0
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.client_order_id = dictionary["client_order_id"] as? String ?? ""
        self.created_at = dictionary["created_at"] as? String ?? ""
        self.updated_at = dictionary["updated_at"] as? String ?? ""
        self.submitted_at = dictionary["submitted_at"] as? String ?? ""
        self.filled_at = dictionary["filled_at"] as? String ?? ""
        self.expired_at = dictionary["expired_at"] as? String ?? ""
        self.canceled_at = dictionary["canceled_at"] as? String ?? ""
        self.failed_at = dictionary["failed_at"] as? String ?? ""
        self.replaced_at = dictionary["replaced_at"] as? String ?? ""
        self.replaced_by = dictionary["replaced_by"] as? String ?? ""
        self.replaces = dictionary["replaces"] as? String ?? ""
        self.asset_id = dictionary["asset_id"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.asset_class = dictionary["asset_class"] as? String ?? ""
        self.notional = dictionary["notional"] as? String ?? ""
        self.qty = dictionary["qty"] as? String ?? ""
        self.filled_qty = dictionary["filled_qty"] as? String ?? ""
        self.filled_avg_price = dictionary["filled_avg_price"] as? String ?? ""
        self.order_class = dictionary["order_class"] as? String ?? ""
        self.order_type = dictionary["order_type"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.side = dictionary["side"] as? String ?? ""
        self.time_in_force = dictionary["time_in_force"] as? String ?? ""
        self.limit_price = dictionary["limit_price"] as? String ?? ""
        self.stop_price = dictionary["stop_price"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.extended_hours = dictionary["extended_hours"] as? Bool ?? false
        self.legs = dictionary["legs"] as? String ?? ""
        self.trail_percent = dictionary["trail_percent"] as? String ?? ""
        self.trail_price = dictionary["trail_price"] as? String ?? ""
        self.hwm = dictionary["hwm"] as? String ?? ""
        self.commission = dictionary["commission"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
        self.fractional = dictionary["fractional"] as? String ?? ""
        
        self.openPrice = dictionary["openPrice"] as? Double ?? 0.0
        self.closePrice = dictionary["closePrice"] as? Double ?? 0.0
        self.highPrice = dictionary["highPrice"] as? Double ?? 0.0
        self.lowPrice = dictionary["lowPrice"] as? Double ?? 0.0
        self.plVariationValue = dictionary["plVariationValue"] as? Double ?? 0.0
        self.plVariationPer = dictionary["plVariationPer"] as? Double ?? 0.0
        self.volume = dictionary["volume"] as? Int ?? 0
        self.tradeCount = dictionary["tradeCount"] as? Int ?? 0
        self.current_price = dictionary["current_price"] as? Double ?? 0.0
    }
}
