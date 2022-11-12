//
//  UserDetail.swift
//  projectName
//
//  companyName on 07/01/22.
//

import UIKit

class UserDetail: NSObject, Codable {
    var _id: String = ""
    var givenName: String = ""
    var familyName: String = ""
    var documents: Bool = false
    var email: String = ""
    var W8BENDeclaration: Bool = false
    var W8BENForm: Bool = false
    var nationality: String = ""
    var countryOfResidency: String = ""
    var isVerified: Bool = false
    var active:Bool = false
    var contactNo: String = ""
    var wallet: Double = 0.0
    var userType: String = ""
    var loginType: String = ""
    var deviceType: String = ""
    var deviceToken: String = ""
    var contactCountryCode: String = ""
    var profileImage: String = ""
    var createdAt: String = ""
    var currency: String = ""
    var alphacId:String = "db7014d6-b485-48f9-8480-77424cfcfc27"

    var objLicenceInfo: DrivingLicenseObject = DrivingLicenseObject.init([:])
    var objPassportInfo: PassportObject = PassportObject.init([:])
    var objVoterCardInfo: VoterCardObject = VoterCardObject.init([:])
    var objInsuranceInfo: InsuranceObject = InsuranceObject.init([:])

    class func initWith(dict: Dictionary<String, Any>) -> UserDetail {
        
        let object = UserDetail()
        
        if let id = dict["_id"] as? String {
            object._id = id
        }
        
        if let givenName = dict["givenName"] as? String {
            object.givenName = givenName
        }
        if let familyName = dict["familyName"] as? String {
            object.familyName = familyName
        }
        if let documents = dict["documents"] as? Bool {
            object.documents = documents
        }
        if let email = dict["email"] as? String {
            object.email = email
        }
        if let W8BENDeclaration = dict["W8BENDeclaration"] as? Bool {
            object.W8BENDeclaration = W8BENDeclaration
        }
        if let W8BENForm = dict["W8BENForm"] as? Bool {
            object.W8BENForm = W8BENForm
        }
        if let nationality = dict["nationality"] as? String {
            object.nationality = nationality
        }
        if let countryOfResidency = dict["countryOfResidency"] as? String {
            object.countryOfResidency = countryOfResidency
        }
        if let isVerified = dict["isVerified"] as? Bool {
            object.isVerified = isVerified
        }
        if let active = dict["active"] as? Bool {
            object.active = active
        }
        if let contactNo = dict["contactNo"] as? String {
            object.contactNo = contactNo
        }
        if let wallet = dict["wallet"] as? Double {
            object.wallet = wallet
        }
        if let userType = dict["userType"] as? String {
            object.userType = userType
        }
        if let loginType = dict["loginType"] as? String {
            object.loginType = loginType
        }
        if let deviceType = dict["deviceType"] as? String {
            object.deviceType = deviceType
        }
        if let deviceToken = dict["deviceToken"] as? String {
            object.deviceToken = deviceToken
        }
        if let contactCountryCode = dict["contactCountryCode"] as? String {
            object.contactCountryCode = contactCountryCode
        }
        if let profileImage = dict["profileImage"] as? String {
            object.profileImage = profileImage
        }
        if let createdAt = dict["createdAt"] as? String {
            object.createdAt = createdAt
        }
        if let currency = dict["currency"] as? String {
            object.currency = currency
        }
        
        if let alphacId = dict["alphacId"] as? String {
            object.alphacId = alphacId
        }
        
        //DRIVING LICENSE
        if let drivingLicense = dict["drivingLicense"] as? Dictionary<String, Any> {
            object.objLicenceInfo = DrivingLicenseObject.init(drivingLicense)
        }
        
        //PASSPORT
        if let passport = dict["passport"] as? Dictionary<String, Any> {
            object.objPassportInfo = PassportObject.init(passport)
        }
        
        //VOTER CARD
        if let voterCard = dict["voterCard"] as? Dictionary<String, Any> {
            object.objVoterCardInfo = VoterCardObject.init(voterCard)
        }
        
        //INSURANCE
        if let insurance = dict["insurance"] as? Dictionary<String, Any> {
            object.objInsuranceInfo = InsuranceObject.init(insurance)
        }
        
        return object
    }
}

class DrivingLicenseObject: NSObject, Codable {
    var drivingLicenseFront: String = ""
    var drivingLicenseBack: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.drivingLicenseFront = dictionary["drivingLicenseFront"] as? String ?? ""
        self.drivingLicenseBack = dictionary["drivingLicenseBack"] as? String ?? ""
    }
}

class PassportObject: NSObject, Codable {
    var passportFront: String = ""
    var passportBack: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.passportFront = dictionary["passportFront"] as? String ?? ""
        self.passportBack = dictionary["passportBack"] as? String ?? ""
    }
}

class VoterCardObject: NSObject, Codable {
    var voterCardFront: String = ""
    var voterCardBack: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.voterCardFront = dictionary["voterCardFront"] as? String ?? ""
        self.voterCardBack = dictionary["voterCardBack"] as? String ?? ""
    }
}

class InsuranceObject: NSObject, Codable {
    var insuranceFront: String = ""
    var insuranceBack: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.insuranceFront = dictionary["insuranceFront"] as? String ?? ""
        self.insuranceBack = dictionary["insuranceBack"] as? String ?? ""
    }
}
