//
//  HomeSearchModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 25/03/22.
//

import Foundation
import SwiftyJSON

class HomeSearchModel: NSObject {
    
    var menuItems:[SearchResult] = []
    var ComboItems:[SearchResult] = []
    var comboItems_count = 0
    var menuItems_count = 0
    
    
    init(json:JSON){
        super.init()
        for menu in json["menuItems"]["result"].arrayValue {
            menuItems.append(SearchResult(json: menu))
            for i in menuItems {
                i.type = "menu"
            }
        }
        for combo in json["comboItems"]["result"].arrayValue {
            ComboItems.append(SearchResult(json: combo))
            for  c in ComboItems {
                c.type = "combo"
            }
        }
        
    }
}
