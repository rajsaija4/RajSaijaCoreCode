//
//  TableViewModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 11/02/22.
//

import Foundation
import SwiftyJSON
import AVFoundation


class MainTableViewModel: NSObject {
    var tables_count = 0
    var status = 0
    var table_keys:TableKeys!
    var table_details:TableViewModel!
    
    init(json:JSON) {
        super.init()
        tables_count = json["tables_count"].intValue
        status = json["status"].intValue
        table_keys = TableKeys(json:json)
        table_details = TableViewModel(json: json)
    }
}

class TableKeys: NSObject {
    var avgWaitTime = 0
    var availableCount = 0
    var occupiedCount = 0
    var seatingPreference:[String] = []
    
    init(json:JSON) {
        super.init()
        avgWaitTime = json["table_keys"]["avgWaitTime"].intValue
        availableCount = json["table_keys"]["availableCount"].intValue
        occupiedCount = json["table_keys"]["occupiedCount"].intValue
        for seat in json["table_keys"]["seatingPreference"].arrayValue {
            seatingPreference.append(seat.stringValue)
        }
    }
}


class TableViewModel:NSObject {
    var page = 0
    var limit = 0
    var totalPages = 0
    var pagingCounter = 0
    var totalDocs = 0
    var nextPage = 0
    var result:[TableViewResult] = []
    
    init(json:JSON) {
        super.init()
        pagingCounter = json["table_details"]["pagingCounter"].intValue
        totalPages = json["table_details"]["totalPages"].intValue
        nextPage = json["table_details"]["nextPage"].intValue
        page = json["table_details"]["page"].intValue
        limit = json["table_details"]["limit"].intValue
        totalDocs = json["table_details"]["totalDocs"].intValue
        for r in json["table_details"]["result"].arrayValue {
            result.append(TableViewResult(json: r))
        }
    }
}

class TableViewResult:NSObject,NSCoding {
    var position:TablePosition!
    var tableStatus = ""
    var bookingStatus = false
    var capacity = 0
    var tableNo = 0
    var _id = ""
    var costPerson = 0.0
    var updatedAt = ""
    var createdAt = ""
    var restaurant = ""
    var __v = 0
    
    init(json:JSON) {
        super.init()
        
        position = TablePosition(json: json)
        tableStatus = json["tableStatus"].stringValue
        bookingStatus = json["bookingStatus"].boolValue
        capacity = json["capacity"].intValue
        tableNo = json["tableNo"].intValue
        _id = json["_id"].stringValue
        costPerson = json["costPerson"].doubleValue
        updatedAt = json["updatedAt"].stringValue
        createdAt = json["createdAt"].stringValue
        restaurant = json["restaurant"].stringValue
        __v = json["__v"].intValue
    }
    
    init(position:TablePosition,bookingStatus:Bool,capacity:Int,tableNo:Int,_id:String,costPerson:Double,updatedAt:String,createdAt:String,restaurant:String,__v:Int) {
        
        self.position = position
        self.bookingStatus = bookingStatus
        self.capacity = capacity
        self.tableNo = tableNo
        self._id = _id
        self.costPerson = costPerson
        self.updatedAt = updatedAt
        self.createdAt = createdAt
        self.restaurant = restaurant
        self.__v = __v
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(position, forKey: "position")
        aCoder.encode(bookingStatus,forKey: "bookingStatus")
        aCoder.encode(capacity, forKey: "capacity")
        aCoder.encode(tableNo, forKey: "tableNo")
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(costPerson, forKey: "costPerson")
        aCoder.encode(updatedAt,forKey: "updatedAt")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(restaurant, forKey: "restaurant")
        aCoder.encode(__v, forKey: "__v")
    }
    
    required init?(coder aDecoder: NSCoder) {
        position = aDecoder.decodeObject(of: TablePosition.self, forKey: "position")
        bookingStatus = aDecoder.decodeBool(forKey: "bookingStatus")
        capacity = aDecoder.decodeInteger(forKey: "capacity")
        tableNo = aDecoder.decodeInteger(forKey: "tableNo")
        _id = aDecoder.decodeObject(forKey: "_id") as! String
        costPerson = aDecoder.decodeDouble(forKey: "costPerson")
        updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as! String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as! String
        restaurant = aDecoder.decodeObject(forKey: "restaurant") as! String
        __v = aDecoder.decodeInteger(forKey: "__v")
    }
    
    static var arrSelectedTable:[TableViewResult] = []
    static var arrDummySelectedTable:[TableViewResult] = []
}

extension TableViewResult {
    
    static func saveTableDetails() {
        
        let cartData = NSKeyedArchiver.archivedData(withRootObject: TableViewResult.arrSelectedTable)
        UserDefaults.standard.set(cartData, forKey: "saveUserTableData")
    }
    
    static func loadPlaces() {
        guard let tableData = UserDefaults.standard.object(forKey: "saveUserTableData") as? NSData else {
            debugPrint("Cart is Empty")
            return
        }
        
        guard let tableArray = NSKeyedUnarchiver.unarchiveObject(with: tableData as Data) as? [TableViewResult] else {
            debugPrint("Could not unarchive from people Data")
            return
        }
        
        TableViewResult.arrSelectedTable.removeAll()
        TableViewResult.arrSelectedTable = tableArray
    }
    
    static func delete() {
        UserDefaults.standard.removeObject(forKey: "saveUserTableData")
        UserDefaults.standard.synchronize()
    }
}

class TablePosition:NSObject,NSCoding {
    var col = 0
    var align = ""
    
    init(json:JSON) {
        super.init()
        col = json["position"]["col"].intValue
        align = json["position"]["align"].stringValue
    }
    
    init(col:Int,align:String) {
        self.col = col
        self.align = align
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(col, forKey: "col")
        aCoder.encode(align,forKey: "align")
    }
    
    required init?(coder aDecoder: NSCoder) {
        col = aDecoder.decodeInteger(forKey: "col")
        align = aDecoder.decodeObject(forKey: "id") as? String ?? ""
    }
}
