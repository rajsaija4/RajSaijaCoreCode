//
//  Registered.swift
//  BYT
//
//  Created by RAJ J SAIJA on 21/01/22.
//

import Foundation
import SwiftyJSON

class Registered: NSCoder,NSCoding {
    var registeredUser:RegisteredUser?
    var token = ""
    var message = ""
    var id = ""
    var invalidation = ""
    
    init(json:JSON){
        super.init()
        
        registeredUser = RegisteredUser(json: json)
        token = json["token"].stringValue
        message = json["message"].stringValue
        id = json["id"].stringValue
        invalidation = json["error"].stringValue
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id,forKey: "id")
        aCoder.encode(message, forKey: "message")
        aCoder.encode(token, forKey: "token")
        aCoder.encode(invalidation, forKey: "error")
        aCoder.encode(registeredUser, forKey: "registeredData")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        id = aDecoder.decodeObject(forKey: "id") as! String
        message = aDecoder.decodeObject(forKey: "message") as! String
        token = aDecoder.decodeObject(forKey: "token") as! String
        invalidation = aDecoder.decodeObject(forKey: "error") as! String
        registeredUser = aDecoder.decodeObject(of: RegisteredUser.self, forKey: "registeredData")
        
    }
}

extension Registered {
    
    static var isExist: Bool {
        let decodedData  = UserDefaults.standard.object(forKey: "saveUserCredentials") as? Data
        return decodedData != nil
    }
    
    //    static var token: [String:String] {
    //        get {
    //            return ["Authorization": "Bearer \(User.details.barearToken)", "X-Requested-With": "XMLHttpRequest"]
    //        }
    //    }
    
    //    static var token: [String:String] {
    //        get {
    //            return ["Authorization": "Bearer \(User.token)"]
    //        }
    //        }
    
    static var details: Registered {
        get {
            let decodedData  = UserDefaults.standard.object(forKey: "saveUserCredentials") as! Data
            let userDetails = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decodedData) as! Registered
            return userDetails
        }
    }
}


extension Registered {
    
    func save() {
        let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
        UserDefaults.standard.set(encodedData, forKey: "saveUserCredentials")
        UserDefaults.standard.synchronize()
    }
    
    func delete() {
        UserDefaults.standard.removeObject(forKey: "saveUserCredentials")
        UserDefaults.standard.synchronize()
    }
}


class RegisteredUser:NSCoder,NSCoding {
    var language = ""
    var role = ""
    var currency = ""
    var firebasetoken = ""
    var name = ""
    var email = ""
    var diet:[String] = []
    var createdAt = ""
    var dob = ""
    var coverPhoto = ""
    var mobile = ""
    var _id = ""
    var avgSpend = 0.0
    var __v = 0
    var profile = ""
    var bytPoints = 0
    var blackList = false
    var salt = ""
    var hashing = ""
    
    init(json:JSON){
        super.init()
        
        language = json["user"]["language"].stringValue
        role = json["user"]["role"].stringValue
        name = json["user"]["name"].stringValue
        email = json["user"]["email"].stringValue
        for d in json["user"]["diet"].arrayValue {
            diet.append(d.stringValue)
        }
        currency = json["user"]["currency"].stringValue
        firebasetoken = json["user"]["firebaseToken"].stringValue
        createdAt = json["user"]["createdAt"].stringValue
        dob = json["user"]["dob"].stringValue
        coverPhoto = json["user"]["coverPhoto"].stringValue
        mobile = json["user"]["mobile"].stringValue
        _id = json["user"]["_id"].stringValue
        avgSpend = json["user"]["avgSpend"].doubleValue
        __v = json["user"]["__v"].intValue
        profile = json["user"]["profile"].stringValue
        bytPoints = json["user"]["bytPoints"].intValue
        blackList = json["user"]["blacklist"].boolValue
        salt = json["user"]["salt"].stringValue
        hashing = json["user"]["hash"].stringValue
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(language,forKey: "language")
        aCoder.encode(role, forKey: "role")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(currency, forKey: "currency")
        aCoder.encode(firebasetoken, forKey: "firebasetoken")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(diet, forKey: "diet")
        aCoder.encode(createdAt, forKey: "createdAt")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(coverPhoto, forKey: "coverPhoto")
        aCoder.encode(mobile, forKey: "mobile")
        aCoder.encode(_id, forKey: "_id")
        aCoder.encode(avgSpend, forKey: "avgSpend")
        aCoder.encode(__v, forKey: "__v")
        aCoder.encode(profile, forKey: "profile")
        aCoder.encode(bytPoints, forKey: "bytPoints")
        aCoder.encode(blackList, forKey: "blackList")
        aCoder.encode(salt, forKey: "salt")
        aCoder.encode(hashing, forKey: "hashing")
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        language = aDecoder.decodeObject(forKey: "language") as! String
        role = aDecoder.decodeObject(forKey: "role") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        currency = aDecoder.decodeObject(forKey: "currency") as! String
        firebasetoken = aDecoder.decodeObject(forKey: "firebasetoken") as! String
        diet = aDecoder.decodeObject(forKey: "diet") as! [String]
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as! String
        dob = aDecoder.decodeObject(forKey: "dob") as! String
        coverPhoto = aDecoder.decodeObject(forKey: "coverPhoto") as! String
        mobile = aDecoder.decodeObject(forKey: "mobile") as! String
        _id = aDecoder.decodeObject(forKey: "_id") as! String
        avgSpend = aDecoder.decodeDouble(forKey: "avgSpend")
        __v = aDecoder.decodeInteger(forKey: "__v")
        profile = aDecoder.decodeObject(forKey: "profile") as! String
        bytPoints = aDecoder.decodeInteger(forKey: "bytPoints")
        blackList = aDecoder.decodeBool(forKey: "blackList")
        salt = aDecoder.decodeObject(forKey: "salt") as! String
        hashing = aDecoder.decodeObject(forKey: "hashing") as! String
    }
}


class ErrorDescription: NSObject {
    var type = ""
    var errors:[Errors] = []
    
    init(json:JSON){
        super.init()
        type = json["type"].stringValue
        for e in json["errors"].arrayValue {
            errors.append(Errors(json: e))
        }
    }
}

class Errors: NSObject {
    
    var name:Name!
    var email:Email!
    var password:Password!
    var dob:Dob!
    
    init(json:JSON){
        super.init()
        
        name = Name(json: json)
        email = Email(json: json)
        password = Password(json: json)
        dob = Dob(json: json)
    }
    
}

class Name: NSObject {
    var name = ""
    
    init(json:JSON){
        super.init()
        
        name = json["name"].stringValue
    }
    
}

class Email: NSObject {
    var email = ""
    
    init(json:JSON){
        super.init()
        
        email = json["email"].stringValue
    }
    
}

class Password: NSObject {
    var password = ""
    
    init(json:JSON){
        super.init()
        
        password = json["password"].stringValue
    }
    
}

class Dob: NSObject {
    var dob = ""
    
    init(json:JSON){
        super.init()
        
        dob = json["dob"].stringValue
    }
    
}

class ErrorChangePassword: NSObject {
    var errors:[ChangePasswordError] = []
    
    init(json:JSON){
        super.init()
        for e in json["errors"].arrayValue {
            errors.append(ChangePasswordError(json: e))
        }
    }
}

class ChangePasswordError:NSObject {
    var oldPassword:OldPassword!
    var newPassword:NewPassword!
    var confirmPassword:ConfirmPassword!
    
    init(json:JSON){
        super.init()
        
        oldPassword = OldPassword(json: json)
        newPassword = NewPassword(json: json)
        confirmPassword = ConfirmPassword(json: json)
    }
}

class OldPassword: NSObject {
    var oldPassword = ""
    
    init(json:JSON){
        super.init()
        
        oldPassword = json["oldPassword"].stringValue
    }
    
}

class NewPassword: NSObject {
    var newPassword = ""
    
    init(json:JSON){
        super.init()
        
        newPassword = json["newPassword"].stringValue
    }
    
}

class ConfirmPassword: NSObject {
    var confirmPassword = ""
    
    init(json:JSON){
        super.init()
        
        confirmPassword = json["confirmPassword"].stringValue
    }
    
}
