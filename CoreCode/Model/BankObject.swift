//
//  BankObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 05/04/22.
//

import Foundation

class BankObject: NSObject, Codable {
    var id: String = ""
    var account_id: String = ""
    var name: String = ""
    var status: String = ""
    var country: String = ""
    var state_province: String = ""
    var postal_code: String = ""
    var city: String = ""
    var street_address: String = ""
    var account_number: String = ""
    var bank_code: String = ""
    var bank_code_type: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.account_id = dictionary["account_id"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.country = dictionary["country"] as? String ?? ""
        self.state_province = dictionary["state_province"] as? String ?? ""
        self.postal_code = dictionary["postal_code"] as? String ?? ""
        self.city = dictionary["city"] as? String ?? ""
        self.street_address = dictionary["street_address"] as? String ?? ""
        self.account_number = dictionary["account_number"] as? String ?? ""
        self.bank_code = dictionary["bank_code"] as? String ?? ""
        self.bank_code_type = dictionary["bank_code_type"] as? String ?? ""
        self.created_at = dictionary["created_at"] as? String ?? ""
        self.updated_at = dictionary["updated_at"] as? String ?? ""
    }
}
