//

import UIKit
import SwiftyJSON

class BankListVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    @IBOutlet weak var btnDone: UIButton!
    
    var isFromAdd:Bool = false
    var strAmount:String = ""
    
    var arrBank: [BankObject] = []
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.callGetBankListAPI()
    }

    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.tblList.isHidden = true
        self.lblNoRecord.isHidden = true
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        if self.arrBank.count > 0 {
            GlobalData.shared.showSystemToastMesage(message: "You can add only one bank account at a time")
        } else {
            let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "AddBankAccountVC") as! AddBankAccountVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if self.arrBank.count > 0 {
            self.btnDone.isUserInteractionEnabled = false

            let bankID = self.arrBank[sender.tag].id
            self.callAddWithdrawAPI(BankID: bankID)
        } else {
            GlobalData.shared.showSystemToastMesage(message: "Please add your bank account first")
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension BankListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrBank.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BankCell", for: indexPath) as! BankCell
        
        let objData = self.arrBank[indexPath.section]
        let accNo = objData.account_number
        let last4 = accNo.suffix(4)
        
        cell.lblAmount.text = "$" + convertThousand(value: Double(self.strAmount) ?? 0.0)
        cell.lblAccNo.text = "**** \(last4)"
        
        cell.btnDelete.tag = indexPath.section
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //CELL ACTION
    @objc func btnDeleteClick(_ sender: UIButton) {
        debugPrint("Delete \(sender.tag)")
        GlobalData.shared.displayConfirmationAlert(self, title: "Delete Bank", message: "Are you sure you want to delete this bank detail?", btnTitle1: "Cancel", btnTitle2: "Delete", actionBlock: { (isConfirmed) in
            if isConfirmed {
                let bankID = self.arrBank[sender.tag].id
                self.callDeleteBankAPI(BankID: bankID)
            }
        })
    }
}

//MARK: - API CALL -

extension BankListVC {
    //GET BANK LIST
    func callGetBankListAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_BANK) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrBank.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = BankObject.init(payloadData[i])
                                strongSelf.arrBank.append(objData)
                            }
                            
                            if strongSelf.arrBank.count > 0 {
                                strongSelf.tblList.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblList.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrBank.removeAll()
                        if strongSelf.arrBank.count > 0 {
                            strongSelf.tblList.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblList.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //DELETE BANK API
    func callDeleteBankAPI(BankID bankID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_BANK + "/" + "\(bankID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestDELETEURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let row = strongSelf.arrBank.firstIndex(where: {$0.id == bankID}) {
                            strongSelf.arrBank.remove(at: row)
                        }
                        
                        if strongSelf.arrBank.count > 0 {
                            strongSelf.tblList.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblList.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //ADD WITHDRAW API
    func callAddWithdrawAPI(BankID bankID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["transferType"] = "wire"
        params["bankId"] = bankID
        params["amount"] = self.strAmount
        params["direction"] = "OUTGOING"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.ADD_WITHDRAW, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.btnDone.isUserInteractionEnabled = true
                        
                        GlobalData.shared.displayAlertWithOkAction(strongSelf, title: "Success", message: (response["message"] as! String), btnTitle: "Ok") { (isOK) in
                            if isOK {
                                let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "FundsTransactionVC") as! FundsTransactionVC
                                controller.isSelectedAdd = false
                                controller.isNeedToPopOnly = false
                                strongSelf.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnDone.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnDone.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnDone.isUserInteractionEnabled = true
        }
    }
}
