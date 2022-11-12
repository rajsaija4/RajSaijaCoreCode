//
//  ThemeObject.swift
//  projectName
//
//  companyName on 11/02/22.
//

import Foundation

class ThemeObject: NSObject, Codable {
    var _id: String = ""
    var categoryName: String = ""
    var categoryImage: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dictionary: [String: Any]) {
        self._id = dictionary["_id"] as? String ?? ""
        self.categoryName = dictionary["categoryName"] as? String ?? ""
        self.categoryImage = dictionary["categoryImage"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
    }
}
