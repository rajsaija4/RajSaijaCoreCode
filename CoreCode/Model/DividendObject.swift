//
//  DividendObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 08/02/22.
//

import Foundation

class DividendObject: NSObject, Codable {
    var id: String = ""
    var corporate_action_id: String = ""
    var ca_type: String = ""
    var ca_sub_type: String = ""
    var initiating_symbol: String = ""
    var initiating_original_cusip: String = ""
    var target_symbol: String = ""
    var target_original_cusip: String = ""
    var declaration_date: String = ""
    var ex_date: String = ""
    var record_date: String = ""
    var payable_date: String = ""
    var cash: String = ""
    var old_rate: String = ""
    var new_rate: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.corporate_action_id = dictionary["corporate_action_id"] as? String ?? ""
        self.ca_type = dictionary["ca_type"] as? String ?? ""
        self.ca_sub_type = dictionary["ca_sub_type"] as? String ?? ""
        self.initiating_symbol = dictionary["initiating_symbol"] as? String ?? ""
        self.initiating_original_cusip = dictionary["initiating_original_cusip"] as? String ?? ""
        self.target_symbol = dictionary["target_symbol"] as? String ?? ""
        self.target_original_cusip = dictionary["target_original_cusip"] as? String ?? ""
        self.declaration_date = dictionary["declaration_date"] as? String ?? ""
        self.ex_date = dictionary["ex_date"] as? String ?? ""
        self.record_date = dictionary["record_date"] as? String ?? ""
        self.payable_date = dictionary["payable_date"] as? String ?? ""
        self.cash = dictionary["cash"] as? String ?? ""
        self.old_rate = dictionary["old_rate"] as? String ?? ""
        self.new_rate = dictionary["new_rate"] as? String ?? ""
    }
}
