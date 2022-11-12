//
//  FundsTransactionVC.swift


import UIKit
import SwiftyJSON
import Foundation

class FundsTransactionVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var viewAddLine: UIView!
    @IBOutlet weak var btnWithdraw: UIButton!
    @IBOutlet weak var viewWithdrawLine: UIView!
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var isNeedToPopOnly:Bool = true
    var isSelectedAdd:Bool = true
    
    var arrFunds: [AddFundObject] = []
    var arrWithdraw: [WithdrawFundObject] = []
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.tblList.isHidden = true
        self.lblNoRecord.isHidden = true
        
        self.setupSegmentView()
        
        if self.isSelectedAdd {
            self.callGetAddFundsAPI()
//            self.callGetWithdrawFundsAPI()
        } else {
            self.callGetWithdrawFundsAPI()
//            self.callGetAddFundsAPI()
        }
    }
    
    //MARK: - HELPER -
    
    func setupSegmentView() {
        if self.isSelectedAdd {
            self.btnAdd.setTitleColor(UIColor.init(hex: 0xFE3D2F), for: [])
            self.btnAdd.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: (self.btnAdd.titleLabel?.font.pointSize)!)
            self.btnWithdraw.setTitleColor(UIColor.white, for: [])
            self.btnWithdraw.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: (self.btnWithdraw.titleLabel?.font.pointSize)!)
            self.viewAddLine.isHidden = false
            self.viewWithdrawLine.isHidden = true
            
            if self.arrFunds.count > 0 {
                self.tblList.isHidden = false
                self.lblNoRecord.isHidden = true
            } else {
                self.tblList.isHidden = true
                self.lblNoRecord.isHidden = false
            }
            
            GlobalData.shared.reloadTableView(tableView: self.tblList)
        } else {
            self.btnAdd.setTitleColor(UIColor.white, for: [])
            self.btnAdd.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: (self.btnAdd.titleLabel?.font.pointSize)!)
            self.btnWithdraw.setTitleColor(UIColor.init(hex: 0xFE3D2F), for: [])
            self.btnWithdraw.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: (self.btnWithdraw.titleLabel?.font.pointSize)!)
            self.viewAddLine.isHidden = true
            self.viewWithdrawLine.isHidden = false
            
            if self.arrWithdraw.count > 0 {
                self.tblList.isHidden = false
                self.lblNoRecord.isHidden = true
            } else {
                self.tblList.isHidden = true
                self.lblNoRecord.isHidden = false
            }
            
            GlobalData.shared.reloadTableView(tableView: self.tblList)
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        if self.isNeedToPopOnly {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToViewController(ofClass: FundAmountVC.self, animated: true)
        }
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        self.callGetAddFundsAPI()
        if self.isSelectedAdd == false {
            self.isSelectedAdd = true
            
            self.setupSegmentView()
        }
    }
    
    @IBAction func btnWithdrawClick(_ sender: UIButton) {
        self.callGetWithdrawFundsAPI()
        if self.isSelectedAdd == true {
            self.isSelectedAdd = false
            
            self.setupSegmentView()
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension FundsTransactionVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.isSelectedAdd {
            return self.arrFunds.count + 1
        } else {
            return self.arrWithdraw.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FundTransactionCell", for: indexPath) as! FundTransactionCell
        
        if indexPath.section == 0 {
            cell.stackviewHeader.isHidden = false
            cell.stackviewContent.isHidden = true
        } else {
            cell.stackviewHeader.isHidden = true
            cell.stackviewContent.isHidden = false
        }
        
        if self.isSelectedAdd {
            if self.arrFunds.count > 0 {
                if indexPath.section != 0 {
                    let objData = self.arrFunds[indexPath.section - 1]
                    let date = objData.createdAt.fromUTCToLocalDateTime(OutputFormat: "yyyy-MM-dd")
        //            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
                    
                    cell.lblDate.text = date
                    cell.lblStatus.text = objData.finalStatus
                    cell.lblAmount.text = "$" + convertThousand(value: Double(objData.adminamount) ?? 0.0)
                    
                    if objData.finalStatus == "Complete" {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0x81CF01, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0x81CF01, a: 1.0)
                    }
                    else if objData.finalStatus == "Pending" {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0xFFCF4A, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0xFFCF4A, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0xFFCF4A, a: 1.0)
                    }
                    else if objData.finalStatus == "Failed" {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0xC2C2C2, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0xC2C2C2, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0xC2C2C2, a: 1.0)
                    }
                    else {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0xACACAC, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0xACACAC, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0xACACAC, a: 1.0)
                    }
                }
            }
        } else {
            if self.arrWithdraw.count > 0 {
                if indexPath.section != 0 {
                    let objData = self.arrWithdraw[indexPath.section - 1]
                    let date = objData.created_at.fromUTCToLocalDateTime(OutputFormat: "yyyy-MM-dd")
                    
                    let status = objData.status.replacingOccurrences(of: "_", with: " ")
                    
                    //NOTE:- import Foundation and then use the capitalized property.
                    cell.lblDate.text = date
                    cell.lblStatus.text = status.capitalized
                    cell.lblAmount.text = "$" + convertThousand(value: Double(objData.amount) ?? 0.0)
                    
                    if (objData.status == "QUEUED" || objData.status == "PENDING" || objData.status == "APPROVAL_PENDING" || objData.status == "SENT_TO_CLEARING" || objData.status == "APPROVED" ) {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0xFFCF4A, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0xFFCF4A, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0xFFCF4A, a: 1.0)
                    }
                    else if (objData.status == "COMPLETE") {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0x81CF01, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0x81CF01, a: 1.0)
                    }
                    else if (objData.status == "REJECTED" || objData.status == "CANCELED" || objData.status == "RETURNED") {
                        cell.viewStatus.backgroundColor = UIColor.init(hex: 0xC2C2C2, a: 0.20)
                        cell.viewStatus.layer.borderColor = UIColor.init(hex: 0xC2C2C2, a: 1.0).cgColor
                        cell.viewStatus.layer.borderWidth = 1.0
                        
                        cell.lblStatus.textColor = UIColor.init(hex: 0xC2C2C2, a: 1.0)
                    }
                }
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension FundsTransactionVC {
    //ADD FUNDS HISTORY
    func callGetAddFundsAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.ADD_FUNDS_HISTORY) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrFunds.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AddFundObject.init(payloadData[i])
                                strongSelf.arrFunds.append(objData)
                            }
                            
                            if strongSelf.isSelectedAdd {
                                if strongSelf.arrFunds.count > 0 {
                                    strongSelf.tblList.isHidden = false
                                    strongSelf.lblNoRecord.isHidden = true
                                } else {
                                    strongSelf.tblList.isHidden = true
                                    strongSelf.lblNoRecord.isHidden = false
                                }
                                
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                            }
                        }
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
    
    //WITHDRAW FUNDS HISTORY
    func callGetWithdrawFundsAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.WITHDRAW_FUNDS_HISTORY) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrWithdraw.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = WithdrawFundObject.init(payloadData[i])
                                strongSelf.arrWithdraw.append(objData)
                            }
                            
                            if strongSelf.isSelectedAdd == false {
                                if strongSelf.arrWithdraw.count > 0 {
                                    strongSelf.tblList.isHidden = false
                                    strongSelf.lblNoRecord.isHidden = true
                                } else {
                                    strongSelf.tblList.isHidden = true
                                    strongSelf.lblNoRecord.isHidden = false
                                }
                                
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                            }
                        }
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
}
