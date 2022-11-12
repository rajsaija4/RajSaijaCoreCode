//
//  TransferObject.swift
//  projectName
//
//  companyName on 27/01/22.
//

import Foundation

class TransferObject: NSObject, Codable {
    var id: String = ""
    var relationship_id: String = ""
    var account_id: String = ""
    var type: String = ""
    var status: String = ""
    var amount: String = ""
    var instant_amount: String = ""
    var direction: String = ""
    var created_at: String = ""
    var updated_at: String = ""
    var expires_at: String = ""
    var reason: String = ""
    var hold_until: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String ?? ""
        self.relationship_id = dictionary["relationship_id"] as? String ?? ""
        self.account_id = dictionary["account_id"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.amount = dictionary["amount"] as? String ?? ""
        self.instant_amount = dictionary["instant_amount"] as? String ?? ""
        self.direction = dictionary["direction"] as? String ?? ""
        self.created_at = dictionary["created_at"] as? String ?? ""
        self.updated_at = dictionary["updated_at"] as? String ?? ""
        self.expires_at = dictionary["expires_at"] as? String ?? ""
        self.reason = dictionary["reason"] as? String ?? ""
        self.hold_until = dictionary["hold_until"] as? String ?? ""
    }
}
