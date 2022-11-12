//
//  AllHistoryVC.swift

import UIKit
import SwiftyJSON

class AllHistoryVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblAllHistory: UILabel!
    @IBOutlet weak var viewLineAllHistory: UIView!
    @IBOutlet weak var lblTransfers: UILabel!
    @IBOutlet weak var viewLineTransfers: UIView!
    @IBOutlet weak var lblDividends: UILabel!
    @IBOutlet weak var viewLineDividends: UIView!
    
    @IBOutlet weak var stackViewPending: UIStackView!
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblNoPending: UILabel!
    @IBOutlet weak var tblPending: ContentSizedTableView!
    @IBOutlet weak var tblPendingHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewOlderActivity: UIStackView!
    @IBOutlet weak var lblOlderActivity: UILabel!
    @IBOutlet weak var lblNoActivity: UILabel!
    @IBOutlet weak var tblOlderActivity: ContentSizedTableView!
    @IBOutlet weak var tblOlderActivityHeightConstraint: NSLayoutConstraint!
    
    var selectedIndex: Int = 0
    
    var arrPendingHistory: [HistoryObject] = []
    var arrAllHistory: [HistoryObject] = []
    
    var arrPendingTransfer: [TransferObject] = []
    var arrOlderTransfer: [TransferObject] = []
    
    var arrUserDividend: [DividendObject] = []
    var arrAllDividend: [DividendObject] = []
    
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
            self.tblPendingHeightConstraint.constant = self.tblPending.contentSize.height
            self.tblOlderActivityHeightConstraint.constant = self.tblOlderActivity.contentSize.height
        }
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
        
        self.lblAllHistory.textColor = UIColor.labelTextColor
        self.lblTransfers.textColor = UIColor.labelTextColor
        self.lblDividends.textColor = UIColor.labelTextColor
        
        self.lblPending.textColor = UIColor.labelTextColor
        self.lblOlderActivity.textColor = UIColor.labelTextColor
        
        self.lblNoPending.textColor = UIColor.labelTextColor
        self.lblNoActivity.textColor = UIColor.labelTextColor
        
        self.tblPending.showsVerticalScrollIndicator = false
        self.tblPending.tableFooterView = UIView()
        
        self.tblOlderActivity.showsVerticalScrollIndicator = false
        self.tblOlderActivity.tableFooterView = UIView()
        
        self.lblNoPending.isHidden = true
        self.tblPending.isHidden = true
        self.lblNoActivity.isHidden = true
        self.tblOlderActivity.isHidden = true
        
        self.callGetAllHistoryAPI()
        self.callGetTransferAPI()
        self.callGetDividendAPI()
    }
    
    //MARK: - HELPER -
    
    func setupSegmentView() {
        if self.selectedIndex == 0 {
            self.viewLineAllHistory.isHidden = false
            self.viewLineTransfers.isHidden = true
            self.viewLineDividends.isHidden = true
            
            self.lblAllHistory.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblAllHistory.font.pointSize)
            self.lblTransfers.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblTransfers.font.pointSize)
            self.lblDividends.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblDividends.font.pointSize)
            
            self.lblNoPending.text = "No pending data found"
            self.lblNoActivity.text = "No older activity found"
            
            self.stackViewOlderActivity.isHidden = false
            
            if self.arrPendingHistory.count > 0 {
                self.lblNoPending.isHidden = true
                self.tblPending.isHidden = false
            } else {
                self.lblNoPending.isHidden = false
                self.tblPending.isHidden = true
            }
            if self.arrAllHistory.count > 0 {
                self.lblNoActivity.isHidden = true
                self.tblOlderActivity.isHidden = false
            } else {
                self.lblNoActivity.isHidden = false
                self.tblOlderActivity.isHidden = true
            }
            
            GlobalData.shared.reloadTableView(tableView: self.tblPending)
            GlobalData.shared.reloadTableView(tableView: self.tblOlderActivity)
        } else if self.selectedIndex == 1 {
            self.viewLineAllHistory.isHidden = true
            self.viewLineTransfers.isHidden = false
            self.viewLineDividends.isHidden = true
            
            self.lblAllHistory.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblAllHistory.font.pointSize)
            self.lblTransfers.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblTransfers.font.pointSize)
            self.lblDividends.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblDividends.font.pointSize)
            
            self.lblNoPending.text = "No pending data found"
            self.lblNoActivity.text = "No older activity found"
            
            self.stackViewOlderActivity.isHidden = false
            
            if self.arrPendingTransfer.count > 0 {
                self.lblNoPending.isHidden = true
                self.tblPending.isHidden = false
            } else {
                self.lblNoPending.isHidden = false
                self.tblPending.isHidden = true
            }
            if self.arrOlderTransfer.count > 0 {
                self.lblNoActivity.isHidden = true
                self.tblOlderActivity.isHidden = false
            } else {
                self.lblNoActivity.isHidden = false
                self.tblOlderActivity.isHidden = true
            }
            
            GlobalData.shared.reloadTableView(tableView: self.tblPending)
            GlobalData.shared.reloadTableView(tableView: self.tblOlderActivity)
        } else {
            self.viewLineAllHistory.isHidden = true
            self.viewLineTransfers.isHidden = true
            self.viewLineDividends.isHidden = false
            
            self.lblAllHistory.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblAllHistory.font.pointSize)
            self.lblTransfers.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblTransfers.font.pointSize)
            self.lblDividends.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblDividends.font.pointSize)
            
            self.lblNoPending.text = "No dividend data found"
            self.lblNoActivity.text = "No dividend data found"
            
//            self.lblNoActivity.isHidden = true
//            self.tblOlderActivity.isHidden = true
            self.stackViewOlderActivity.isHidden = true
            
            if self.arrAllDividend.count > 0 {
                self.lblNoPending.isHidden = true
                self.tblPending.isHidden = false
            } else {
                self.lblNoPending.isHidden = false
                self.tblPending.isHidden = true
            }
            
            GlobalData.shared.reloadTableView(tableView: self.tblPending)
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSegmentClick(_ sender: UIButton) {
        if sender.tag == 1 {
            if self.selectedIndex != 0 {
                self.selectedIndex = 0
                self.setupSegmentView()
            }
        } else if sender.tag == 2 {
            if self.selectedIndex != 1 {
                self.selectedIndex = 1
                self.setupSegmentView()
            }
        } else {
            if self.selectedIndex != 2 {
                self.selectedIndex = 2
                self.setupSegmentView()
            }
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension AllHistoryVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.selectedIndex == 0 { //ALL HISTORY
            if tableView == self.tblPending { //PENDING
                return self.arrPendingHistory.count
            } else { //OLDER ACTIVITY
                return self.arrAllHistory.count
            }
        } else if self.selectedIndex == 1 { //TRANSFER
            if tableView == self.tblPending { //PENDING
                return self.arrPendingTransfer.count
            } else { //OLDER ACTIVITY
                return self.arrOlderTransfer.count
            }
        } else { //DIVIDENDS
//            if tableView == self.tblPending { //PENDING
//                return self.arrUserDividend.count
//            } else { //OLDER ACTIVITY
                return self.arrAllDividend.count
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.selectedIndex == 0 { //ALL HISTORY
            if tableView == self.tblPending { //PENDING
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
                
                let objData = self.arrPendingHistory[indexPath.section]
                let date = objData.transaction_time.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
                let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
                
                cell.lblName.text = objData.symbol
                cell.lblDate.text = finalDate
                cell.lblAmount.text = "$" + convertThousand(value: Double(objData.price) ?? 0.0)
                
                cell.selectionStyle = .none
                return cell
            } else { //OLDER ACTIVITY
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
                
                let objData = self.arrAllHistory[indexPath.section]
                let date = objData.transaction_time.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
                let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
                
                cell.lblName.text = objData.symbol
                cell.lblDate.text = finalDate
                cell.lblAmount.text = "$" + convertThousand(value: Double(objData.price) ?? 0.0)
                
                cell.selectionStyle = .none
                return cell
            }
        } else if self.selectedIndex == 1 { //TRANSFER
            if tableView == self.tblPending { //PENDING
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
                
                let objData = self.arrPendingTransfer[indexPath.section]
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
            } else { //OLDER ACTIVITY
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
                
                let objData = self.arrOlderTransfer[indexPath.section]
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
        } else { //DIVIDENDS
//            if tableView == self.tblPending { //PENDING
//                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
//
//                cell.lblName.text = "GOOGL Limit Sell"
//                cell.lblDate.text = "Feb 19, 2021"
//                cell.lblAmount.text = "+$5.20"
//
//                cell.selectionStyle = .none
//                return cell
//            } else { //OLDER ACTIVITY
                let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
                
                let objData = self.arrAllDividend[indexPath.section]
                let declaredDate = GlobalData.shared.formattedDateFromString(dateString: objData.declaration_date, InputFormat: "yyyy-MM-dd", OutputFormat: "MMM dd, yyyy")
                let payableDate = GlobalData.shared.formattedDateFromString(dateString: objData.payable_date, InputFormat: "yyyy-MM-dd", OutputFormat: "MMM dd, yyyy")
                
                cell.lblName.text = objData.initiating_symbol
                cell.lblDate.text = "Declared date: \(declaredDate ?? "")\nPayable date: \(payableDate ?? "")"
            cell.lblAmount.text = "$" + convertThousand(value: Double(objData.cash) ?? 0.0)
                
                cell.selectionStyle = .none
                return cell
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.selectedIndex == 0 { //ALL HISTORY
            var objData: HistoryObject!
            
            if tableView == self.tblPending { //PENDING
                objData = self.arrPendingHistory[indexPath.section]
            } else { //OLDER ACTIVITY
                objData = self.arrAllHistory[indexPath.section]
            }
            
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StatementDetailVC") as! StatementDetailVC
            controller.strType = "History"
            controller.objHistory = objData
            self.navigationController?.pushViewController(controller, animated: true)
        } else if self.selectedIndex == 1 { //TRANSFER
            var objData: TransferObject!
            
            if tableView == self.tblPending { //PENDING
                objData = self.arrPendingTransfer[indexPath.section]
            } else { //OLDER ACTIVITY
                objData = self.arrOlderTransfer[indexPath.section]
            }
            
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StatementDetailVC") as! StatementDetailVC
            controller.strType = "Transfer"
            controller.objTransfer = objData
            self.navigationController?.pushViewController(controller, animated: true)
        } else { //DIVIDENDS
//            var objData: DividendObject!
//
////            if tableView == self.tblPending { //PENDING
////                objData = self.arrUserDividend[indexPath.section]
////            } else { //OLDER ACTIVITY
//                objData = self.arrAllDividend[indexPath.section]
////            }
//
//            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StatementDetailVC") as! StatementDetailVC
//            controller.strType = "Dividend"
//            controller.objDividend = objData
//            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension AllHistoryVC {
    //ALL HISTORY API
    func callGetAllHistoryAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_STATEMENT_HISTORY) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let pendingHistory = payloadData["pending"] as? [Dictionary<String, Any>] {
                                strongSelf.arrPendingHistory.removeAll()
                                for i in 0..<pendingHistory.count {
                                    let objData = HistoryObject.init(pendingHistory[i])
                                    strongSelf.arrPendingHistory.append(objData)
                                }
                            }
                            if let allHistory = payloadData["all"] as? [Dictionary<String, Any>] {
                                strongSelf.arrAllHistory.removeAll()
                                for i in 0..<allHistory.count {
                                    let objData = HistoryObject.init(allHistory[i])
                                    strongSelf.arrAllHistory.append(objData)
                                }
                            }
                            strongSelf.setupSegmentView()
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
    
    //TRANSFER API
    func callGetTransferAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_STATEMENT_TRANSFER) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let pending = payloadData["pending"] as? [Dictionary<String, Any>] {
                                strongSelf.arrPendingTransfer.removeAll()
                                for i in 0..<pending.count {
                                    let objData = TransferObject.init(pending[i])
                                    strongSelf.arrPendingTransfer.append(objData)
                                }
                            }
                            if let older = payloadData["older"] as? [Dictionary<String, Any>] {
                                strongSelf.arrOlderTransfer.removeAll()
                                for i in 0..<older.count {
                                    let objData = TransferObject.init(older[i])
                                    strongSelf.arrOlderTransfer.append(objData)
                                }
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
    
    //DIVIDEND API
    func callGetDividendAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_STATEMENT_DIVIDEND) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let userSpecific = payloadData["userSpecfic"] as? [Dictionary<String, Any>] {
                                strongSelf.arrUserDividend.removeAll()
                                for i in 0..<userSpecific.count {
                                    let objData = DividendObject.init(userSpecific[i])
                                    strongSelf.arrUserDividend.append(objData)
                                }
                            }
                            if let allDividend = payloadData["all"] as? [Dictionary<String, Any>] {
                                strongSelf.arrAllDividend.removeAll()
                                for i in 0..<allDividend.count {
                                    let objData = DividendObject.init(allDividend[i])
                                    strongSelf.arrAllDividend.append(objData)
                                }
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
