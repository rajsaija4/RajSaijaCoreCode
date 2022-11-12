//
//  PortfolioObject.swift
//  projectName
//
//  companyName on 07/02/22.
//

import Foundation

class PortfolioObject: NSObject, Codable {
    var asset_id: String = ""
    var symbol: String = ""
    var exchange: String = ""
    var asset_class: String = ""
    var asset_marginable: Bool = false
    var qty: String = ""
    var avg_entry_price: String = ""
    var side: String = ""
    var market_value: String = ""
    var cost_basis: String = ""
    var unrealized_pl: String = ""
    var unrealized_plpc: String = ""
    var unrealized_intraday_pl: String = ""
    var unrealized_intraday_plpc: String = ""
    var current_price: String = ""
    var lastday_price: String = ""
    var change_today: String = ""
    var image: String = ""
    
    var stock_investment: Double = 0.0
    var stock_current: Double = 0.0
    
    var openPrice: Double = 0.0
    var closePrice: Double = 0.0
    var highPrice: Double = 0.0
    var lowPrice: Double = 0.0
    var plVariationValue: Double = 0.0
    var plVariationPer: Double = 0.0
    var volume: Int = 0
    var tradeCount: Int = 0
    
    init(_ dictionary: [String: Any]) {
        self.asset_id = dictionary["asset_id"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.exchange = dictionary["exchange"] as? String ?? ""
        self.asset_class = dictionary["asset_class"] as? String ?? ""
        self.asset_marginable = dictionary["asset_marginable"] as? Bool ?? false
        self.qty = dictionary["qty"] as? String ?? ""
        self.avg_entry_price = dictionary["avg_entry_price"] as? String ?? ""
        self.side = dictionary["side"] as? String ?? ""
        self.market_value = dictionary["market_value"] as? String ?? ""
        self.cost_basis = dictionary["cost_basis"] as? String ?? ""
        self.unrealized_pl = dictionary["unrealized_pl"] as? String ?? ""
        self.unrealized_plpc = dictionary["unrealized_plpc"] as? String ?? ""
        self.unrealized_intraday_pl = dictionary["unrealized_intraday_pl"] as? String ?? ""
        self.unrealized_intraday_plpc = dictionary["unrealized_intraday_plpc"] as? String ?? ""
        self.current_price = dictionary["current_price"] as? String ?? ""
        self.lastday_price = dictionary["lastday_price"] as? String ?? ""
        self.change_today = dictionary["change_today"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
        
        self.stock_investment = (self.cost_basis as NSString).doubleValue
        self.stock_current = (self.lastday_price as NSString).doubleValue
        
        self.openPrice = dictionary["openPrice"] as? Double ?? 0.0
        self.closePrice = dictionary["closePrice"] as? Double ?? 0.0
        self.highPrice = dictionary["highPrice"] as? Double ?? 0.0
        self.lowPrice = dictionary["lowPrice"] as? Double ?? 0.0
        self.plVariationValue = dictionary["plVariationValue"] as? Double ?? 0.0
        self.plVariationPer = dictionary["plVariationPer"] as? Double ?? 0.0
        self.volume = dictionary["volume"] as? Int ?? 0
        self.tradeCount = dictionary["tradeCount"] as? Int ?? 0
    }
}
