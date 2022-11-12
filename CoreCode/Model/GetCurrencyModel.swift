//
//  GETCURRENCYMODEL.swift
//  BYT
//
//  Created by RAJ J SAIJA on 01/04/22.
//

import Foundation
import SwiftyJSON
class GetCurrencyModel: NSObject {
    var status = 0
    var currencies_count = 0
    var currencies:Currencies!
    
    init(json:JSON){
        super.init()
        
        status = json["status"].intValue
        currencies_count = json["currencies_count"].intValue
        currencies = Currencies(json: json)
    }
}

class Currencies:NSObject {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[CurrenciesResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["currencies"]["page"].intValue
        limit = json["currencies"]["limit"].intValue
        totalDocs = json["currencies"]["totalDocs"].intValue
        totalPages = json["currencies"]["totalPages"].intValue
        pagingCounter = json["currencies"]["pagingCounter"].intValue
        for r in json["currencies"]["result"].arrayValue {
            result.append(CurrenciesResult(json: r))
        }
    }
}

class CurrenciesResult:NSObject {
    var id = ""
    var name = ""
    var code = ""
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        
        id = json["_id"].stringValue
        name = json["name"].stringValue
        code = json["code"].stringValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
}
