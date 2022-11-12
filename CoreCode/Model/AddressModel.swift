//
//  AddressModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 23/11/21.
//

import Foundation
import UIKit

class AddressModel {
    var addressType: String
    var Address: String
    var userInteraction:Bool
    var buttonEditStatus:Bool
    var index:IndexPath = IndexPath(row: 0, section: 0)

    
    init(addressType:String, Address: String, index:IndexPath, userInteraction: Bool, buttonEditStatus: Bool) {
        self.addressType = addressType
        self.Address = Address
        self.index = index
        self.userInteraction = userInteraction
        self.buttonEditStatus = buttonEditStatus
    }
}
