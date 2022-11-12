//
//  CardObject.swift
//  projectName
//
//  companyName on 30/03/22.
//

import Foundation

class CardObject: NSObject, Codable {
    var _id: String = ""
    var user: String = ""
    var cardNumber: String = ""
    var cardType: String = ""
    var cardExpiry: String = ""
    var cardHolderName: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dictionary: [String: Any]) {
        self._id = dictionary["_id"] as? String ?? ""
        self.user = dictionary["user"] as? String ?? ""
        self.cardNumber = dictionary["cardNumber"] as? String ?? ""
        self.cardType = dictionary["cardType"] as? String ?? ""
        self.cardExpiry = dictionary["cardExpiry"] as? String ?? ""
        self.cardHolderName = dictionary["cardHolderName"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
    }
}
