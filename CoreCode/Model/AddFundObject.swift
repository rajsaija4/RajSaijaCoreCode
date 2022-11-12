//
//  AddFundObject.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 29/03/22.
//

import Foundation

class AddFundObject: NSObject, Codable {
    var userAlpacaAccId: String = ""
    var cardOrderId: String = ""
    var amount: String = ""
    var addFundCommission: String = ""
    var cardNumber: String = ""
    var transactionStatus: String = ""
    var adminTransferid: String = ""
    var adminTransferrelation_id: String = ""
    var adminaccount_id: String = ""
    var admintype: String = ""
    var adminstatus: String = ""
    var adminamount: String = ""
    var admininstant_amount: String = ""
    var admindirection: String = ""
    var admincreated_at: String = ""
    var adminupdated_at: String = ""
    var admin_expired_at: String = ""
    var adminreason: String = ""
    var adminhold_until: String = ""
    var journalid: String = ""
    var journalentry_type: String = ""
    var journalfrom_account: String = ""
    var journalto_account: String = ""
    var journalsymbol: String = ""
    var journalqty: String = ""
    var journalprice: String = ""
    var journalstatus: String = ""
    var journalsettle_date: String = ""
    var journalsystem_date: String = ""
    var journalnet_amount: String = ""
    var journaldescription: String = ""
    var finalStatus: String = ""
    var _id: String = ""
    var userLocalId: String = ""
    var createdAt: String = ""
    var updatedAt: String = ""
    
    init(_ dictionary: [String: Any]) {
        self.userAlpacaAccId = dictionary["userAlpacaAccId"] as? String ?? ""
        self.cardOrderId = dictionary["cardOrderId"] as? String ?? ""
        self.amount = dictionary["amount"] as? String ?? ""
        self.addFundCommission = dictionary["addFundCommission"] as? String ?? ""
        self.cardNumber = dictionary["cardNumber"] as? String ?? ""
        self.transactionStatus = dictionary["transactionStatus"] as? String ?? ""
        self.adminTransferid = dictionary["adminTransferid"] as? String ?? ""
        self.adminTransferrelation_id = dictionary["adminTransferrelation_id"] as? String ?? ""
        self.adminaccount_id = dictionary["adminaccount_id"] as? String ?? ""
        self.admintype = dictionary["admintype"] as? String ?? ""
        self.adminstatus = dictionary["adminstatus"] as? String ?? ""
        self.adminamount = dictionary["adminamount"] as? String ?? ""
        self.admininstant_amount = dictionary["admininstant_amount"] as? String ?? ""
        self.admindirection = dictionary["admindirection"] as? String ?? ""
        self.admincreated_at = dictionary["admincreated_at"] as? String ?? ""
        self.adminupdated_at = dictionary["adminupdated_at"] as? String ?? ""
        self.admin_expired_at = dictionary["admin_expired_at"] as? String ?? ""
        self.adminreason = dictionary["adminreason"] as? String ?? ""
        self.adminhold_until = dictionary["adminhold_until"] as? String ?? ""
        self.journalid = dictionary["journalid"] as? String ?? ""
        self.journalentry_type = dictionary["journalentry_type"] as? String ?? ""
        self.journalfrom_account = dictionary["journalfrom_account"] as? String ?? ""
        self.journalto_account = dictionary["journalto_account"] as? String ?? ""
        self.journalsymbol = dictionary["journalsymbol"] as? String ?? ""
        self.journalqty = dictionary["journalqty"] as? String ?? ""
        self.journalprice = dictionary["journalprice"] as? String ?? ""
        self.journalstatus = dictionary["journalstatus"] as? String ?? ""
        self.journalsettle_date = dictionary["journalsettle_date"] as? String ?? ""
        self.journalsystem_date = dictionary["journalsystem_date"] as? String ?? ""
        self.journalnet_amount = dictionary["journalnet_amount"] as? String ?? ""
        self.journaldescription = dictionary["journaldescription"] as? String ?? ""
        self.finalStatus = dictionary["finalStatus"] as? String ?? ""
        self._id = dictionary["_id"] as? String ?? ""
        self.userLocalId = dictionary["userLocalId"] as? String ?? ""
        self.createdAt = dictionary["createdAt"] as? String ?? ""
        self.updatedAt = dictionary["updatedAt"] as? String ?? ""
    }
}