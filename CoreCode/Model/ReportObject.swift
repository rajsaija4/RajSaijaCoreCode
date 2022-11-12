//
//  ReportObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 09/02/22.
//

import Foundation

class ReportObject: NSObject, Codable {
    var id: String = ""
    var account_id: String = ""
    var activity_type: String = ""
    var transaction_time: String = ""
    var type: String = ""
    var price: String = ""
    var qty: String = ""
    var side: String = ""
    var symbol: String = ""
    var leaves_qty: String = ""
    var order_id: String = ""
    var cum_qty: String = ""
    var order_status: String = ""
    var image: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.account_id = dictionary["account_id"] as? String ?? ""
        self.activity_type = dictionary["activity_type"] as? String ?? ""
        self.transaction_time = dictionary["transaction_time"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.price = dictionary["price"] as? String ?? ""
        self.qty = dictionary["qty"] as? String ?? ""
        self.side = dictionary["side"] as? String ?? ""
        self.symbol = dictionary["symbol"] as? String ?? ""
        self.leaves_qty = dictionary["leaves_qty"] as? String ?? ""
        self.order_id = dictionary["order_id"] as? String ?? ""
        self.cum_qty = dictionary["cum_qty"] as? String ?? ""
        self.order_status = dictionary["order_status"] as? String ?? ""
        self.image = dictionary["image"] as? String ?? ""
    }
}
