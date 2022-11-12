//
//  NotificationObject.swift
//  projectName
//
//  companyName on 11/04/22.
//

import Foundation

class NotificationObject: NSObject, Codable {
    var _id: String = ""
    var notificationTitle: String = ""
    var notificationText: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    var user: String = ""
    
    init(_ dictionary: [String: Any]) {
        self._id = dictionary["_id"] as? String ?? ""
        self.notificationTitle = dictionary["notificationTitle"] as? String ?? ""
        self.notificationText = dictionary["notificationText"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
        self.user = dictionary["user"] as? String ?? ""
    }
}
