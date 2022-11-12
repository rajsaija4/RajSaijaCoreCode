//
//  WaitingListModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 22/09/22.
//

import Foundation
import SwiftyJSON

class WaitingListModel:NSObject {
    var status = 0
    var waitingListCount = 0
    var message = ""
    
    init(json:JSON){
        super.init()
        
        status = json["status"].intValue
        waitingListCount = json["waitingListCount"].intValue
        message = json["message"].stringValue
    }
}
    
