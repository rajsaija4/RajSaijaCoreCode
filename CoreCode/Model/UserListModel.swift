//
//  UserListModel.swift
//  BYT
//
//  Created by RAJ J SAIJA on 02/02/22.
//

import Foundation
import SwiftyJSON

class UserListModel:NSObject {
    var users_count = 0
    var users:Users!
    
    init(json:JSON){
        super.init()
        
        users_count = json["users_count"].intValue
        users = Users(json: json)
    }
    
}

class Users:NSObject {
    var page = 0
    var limit = 0
    var totalDocs = 0
    var totalPages = 0
    var pagingCounter = 0
    var result:[UsersResult] = []
    
    init(json:JSON){
        super.init()
        
        page = json["users"]["page"].intValue
        limit = json["users"]["limit"].intValue
        totalDocs = json["users"]["totalDocs"].intValue
        totalPages = json["users"]["totalPages"].intValue
        pagingCounter = json["users"]["pagingCounter"].intValue
        for r in json["users"]["result"].arrayValue {
            result.append(UsersResult(json: r))
        }
    }
    
}


class UsersResult:NSObject,NSCoding {
    var _id = ""
    var name = ""
    var email = ""
    var mobile = ""
    var dob = ""
    var diet:[String] = []
    var profile = ""
    var coverPhoto = ""
    var role = ""
    var blackList = false
    var language = ""
    var bytPoints = 0
    var avgSpend = 0.0
    var createdAt = ""
    var __v = 0
    
    init(json:JSON){
        super.init()
        
        _id = json["_id"].stringValue
        name = json["name"].stringValue
        email = json["email"].stringValue
        mobile = json["mobile"].stringValue
        dob = json["dob"].stringValue
        for d in json["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        profile = json["profile"].stringValue
        coverPhoto = json["coverPhoto"].stringValue
        role = json["role"].stringValue
        blackList = json["blacklist"].boolValue
        language = json["language"].stringValue
        bytPoints = json["bytPoints"].intValue
        avgSpend = json["avgSpend"].doubleValue
        createdAt = json["createdAt"].stringValue
        __v = json["__v"].intValue
    }
    
    init(_id:String, name:String, email:String, mobile:String, dob:String, diet:[String], profile:String, coverPhoto:String, role:String, blackList:Bool,language:String,bytPoints:Int,avgSpend:Double,createdAt:String,__v:Int){
        
        self._id = _id
        self.name = name
        self.email = email
        self.mobile = mobile
        self.dob = dob
        self.diet = diet
        self.profile = profile
        self.coverPhoto = coverPhoto
        self.role = role
        self.blackList = blackList
        self.language = language
        self.bytPoints = bytPoints
        self.avgSpend = avgSpend
        self.createdAt = createdAt
        self.__v = __v
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(_id,forKey: "_id")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(diet, forKey: "diet")
        aCoder.encode(profile, forKey: "profile")
        aCoder.encode(coverPhoto, forKey: "coverPhoto")
        aCoder.encode(role, forKey: "role")
        aCoder.encode(blackList, forKey: "blackList")
        aCoder.encode(language, forKey: "language")
        aCoder.encode(bytPoints, forKey: "bytPoints")
        aCoder.encode(avgSpend, forKey: "avgSpend")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(__v, forKey: "__v")
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        _id = aDecoder.decodeObject(forKey: "_id") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        mobile = aDecoder.decodeObject(forKey: "mobile") as! String
        dob = aDecoder.decodeObject(forKey: "dob") as! String
        diet = aDecoder.decodeObject(forKey: "diet") as! [String]
        profile = aDecoder.decodeObject(forKey: "profile") as! String
        coverPhoto = aDecoder.decodeObject(forKey: "coverPhoto") as! String
        role = aDecoder.decodeObject(forKey: "role") as! String
        blackList = aDecoder.decodeBool(forKey: "blackList")
        language = aDecoder.decodeObject(forKey: "language") as! String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as! String
        bytPoints = aDecoder.decodeInteger(forKey: "bytPoints")
        avgSpend = aDecoder.decodeDouble(forKey: "avgSpend")
        __v = aDecoder.decodeInteger(forKey: "__v")
        
        
    }
    
    static var arrSelectedPeople:[UsersResult] = []
    static var arrDummySelectedPeople:[UsersResult] = []
    
}

extension UsersResult {
    
    static func savePeopleDetails() {
        
        let cartData = NSKeyedArchiver.archivedData(withRootObject: UsersResult.arrSelectedPeople)
        UserDefaults.standard.set(cartData, forKey: "saveUserPeopleData")
    }
    
    static func loadPlaces() {
        guard let peopleData = UserDefaults.standard.object(forKey: "saveUserPeopleData") as? NSData else {
            debugPrint("Cart is Empty")
            return
        }
        
        guard let peopleArray = NSKeyedUnarchiver.unarchiveObject(with: peopleData as Data) as? [UsersResult] else {
            debugPrint("Could not unarchive from people Data")
            return
        }
        
        UsersResult.arrSelectedPeople.removeAll()
        UsersResult.arrSelectedPeople = peopleArray
    }
    
    static func delete() {
        UserDefaults.standard.removeObject(forKey: "saveUserPeopleData")
        UserDefaults.standard.synchronize()
    }
}
