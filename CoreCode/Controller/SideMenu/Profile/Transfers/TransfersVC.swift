//
//  TransfersVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 04/01/22.
//

import UIKit
import SwiftyJSON

class TransfersVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewTransferBank: UIView!
    @IBOutlet weak var lblTransferBankTitle: UILabel!
    @IBOutlet weak var lblTransferBankDesc: UILabel!
    
    @IBOutlet weak var lblWithdrawableCashTitle: UILabel!
    @IBOutlet weak var lblWithdrawableCashValue: UILabel!
    @IBOutlet weak var lblWithdrawableCashDesc: UILabel!
    
    @IBOutlet weak var lblLinkedAccountTitle: UILabel!
    @IBOutlet weak var lblChecking2: UILabel!
    
    @IBOutlet weak var lblRecentTransferTitle: UILabel!
    @IBOutlet weak var tblTransfer: ContentSizedTableView!
    @IBOutlet weak var tblTransferHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrBank: [BankObject] = []
    var arrRecentTransfer: [TransferObject] = []
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblTransferHeightConstraint.constant = self.tblTransfer.contentSize.height
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewTransferBank.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblTransferBankTitle.textColor = UIColor.labelTextColor
        self.lblTransferBankDesc.textColor = UIColor.tblStatementContent
        
        self.lblWithdrawableCashTitle.textColor = UIColor.labelTextColor
        self.lblWithdrawableCashValue.textColor = UIColor.labelTextColor
        self.lblWithdrawableCashDesc.textColor = UIColor.tblStatementContent
        
        self.lblLinkedAccountTitle.textColor = UIColor.labelTextColor
        self.lblChecking2.textColor = UIColor.labelTextColor
        
        self.lblRecentTransferTitle.textColor = UIColor.labelTextColor
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblTransfer.showsVerticalScrollIndicator = false
        self.tblTransfer.tableFooterView = UIView()
        
        self.lblNoRecord.isHidden = true
        self.tblTransfer.isHidden = true
        
        self.callGetRecentTransferAPI()
        
        //SET DATA
        let withdrawableCash = (GlobalData.shared.objTradingAccount.cash_withdrawable as NSString).doubleValue
        let attString = GlobalData.shared.convertStringtoAttributedText(strFirst: "The cash amount that you can withdraw from your account." + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblWithdrawableCashDesc.font.pointSize + 3)!, strFirstColor: UIColor.labelTextColor, strSecond: "Only settled cash can be withdrawn in cash accounts.", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblWithdrawableCashDesc.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
        
        self.lblTransferBankDesc.text = "Withdraw your Funds"
        
        self.lblWithdrawableCashValue.text = "$" + convertThousand(value: withdrawableCash)
        self.lblWithdrawableCashDesc.attributedText = attString
        
        self.callGetBankDetailAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnTransferBankClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundAmountVC") as! FundAmountVC
        controller.isFromMenu = false
        controller.isFromAdd = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension TransfersVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrRecentTransfer.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransferCell") as! TransferCell
        
        let objData = self.arrRecentTransfer[indexPath.section]
        let date = objData.created_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
        let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
        
        if objData.direction == "INCOMING" {
            cell.lblName.text = "Deposit"
        } else {
            cell.lblName.text = "Withdrawal"
        }
        cell.lblDate.text = finalDate
        cell.lblAmount.text = "$" + convertThousand(value: Double(objData.amount) ?? 0.0)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension TransfersVC {
    //GET BANK DETAIL
    func callGetBankDetailAPI() {
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
                                let accNo = strongSelf.arrBank[0].account_number
                                let last4 = accNo.suffix(4)
                                
                                strongSelf.lblChecking2.text = "Checking **** \(last4)"
                                strongSelf.lblChecking2.textAlignment = .left
                            } else {
                                strongSelf.lblChecking2.text = "No bank detail added yet"
                                strongSelf.lblChecking2.textAlignment = .center
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        if strongSelf.arrBank.count > 0 {
                            let accNo = strongSelf.arrBank[0].account_number
                            let last4 = accNo.suffix(4)
                            
                            strongSelf.lblChecking2.text = "Checking **** \(last4)"
                            strongSelf.lblChecking2.textAlignment = .left
                        } else {
                            strongSelf.lblChecking2.text = "No bank detail added yet"
                            strongSelf.lblChecking2.textAlignment = .center
                        }
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //RECENT TRANSFER API
    func callGetRecentTransferAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_RECENT_TRANSFER) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrRecentTransfer.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = TransferObject.init(payloadData[i])
                                strongSelf.arrRecentTransfer.append(objData)
                            }
                            
                            if strongSelf.arrRecentTransfer.count > 0 {
                                strongSelf.tblTransfer.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblTransfer.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblTransfer)
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
