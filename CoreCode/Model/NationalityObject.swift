//
//  NationalityObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 10/01/22.
//

import UIKit

class NationalityObject: NSObject, Codable {
    var num_code: String = ""
    var alpha_2_code: String = ""
    var alpha_3_code: String = ""
    var en_short_name: String = ""
    var nationality: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.num_code = dictionary["num_code"] as? String ?? ""
        self.alpha_2_code = dictionary["alpha_2_code"] as? String ?? ""
        self.alpha_3_code = dictionary["alpha_3_code"] as? String ?? ""
        self.en_short_name = dictionary["en_short_name"] as? String ?? ""
        self.nationality = dictionary["nationality"] as? String ?? ""
    }
}
