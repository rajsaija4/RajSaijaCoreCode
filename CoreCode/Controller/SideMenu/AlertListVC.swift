//

import UIKit
import SideMenuSwift
import SwiftyJSON

class AlertListVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrAlert: [AlertObject] = []
    
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
        
        self.callGetAlertListAPI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateExistingAlertInList(_:)), name: NSNotification.Name(rawValue: kUpdateAlert), object: nil)
    }
    
    //MARK: - HELPER -
    
    @objc private func updateExistingAlertInList(_ notification: NSNotification) {
        if let objUpdatedAlert = notification.userInfo?["data"] as? AlertObject {
            if let row = self.arrAlert.firstIndex(where: {$0._id == objUpdatedAlert._id}) {
                self.arrAlert[row] = objUpdatedAlert
                GlobalData.shared.reloadTableView(tableView: self.tblList)
            }
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension AlertListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrAlert.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as! AlertCell
        
        let objData = self.arrAlert[indexPath.section]
        let attString = GlobalData.shared.convertStringtoAttributedText(strFirst: objData.alertSharesymbol + "\n", strFirstFont: UIFont.init(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: cell.lblOfName.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: objData.exchange, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblOfName.font.pointSize - 2)!, strSecondColor: UIColor.labelTextColor)
        
        cell.lblStatus.text = "Active"
        
        if objData.alertFlag == "Greater than equal" {
            cell.lblValidity.text = "VALIDITY: GTT"
        } else {
            cell.lblValidity.text = "VALIDITY: LTT"
        }
                
        cell.lblOfName.attributedText = attString
        cell.lblNote.text = "Note: \(objData.alertName)"
        cell.lblAmountIsTitle.text = objData.alertFlag.uppercased()
        cell.lblAmount.text = "$" + convertThousand(value: Double(objData.alertPrice) ?? 0.0)
        
        cell.btnDelete.tag = indexPath.section
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteClick), for: .touchUpInside)
        
        cell.btnEdit.tag = indexPath.section
        cell.btnEdit.addTarget(self, action: #selector(btnEditClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 165
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //CELL ACTION
    @objc func btnDeleteClick(_ sender: UIButton) {
        GlobalData.shared.displayConfirmationAlert(self, title: "Delete Alert", message: "Are you sure you want to delete this alert?", btnTitle1: "Cancel", btnTitle2: "Delete", actionBlock: { (isConfirmed) in
            if isConfirmed {
                let alertID = self.arrAlert[sender.tag]._id
                self.callDeleteAlertAPI(AlertID: alertID)
            }
        })
    }
    
    @objc func btnEditClick(_ sender: UIButton) {
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "SetAlertVC") as! SetAlertVC
        controller.isFromEdit = true
        controller.objEditAlert = self.arrAlert[sender.tag]
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - API CALL -

extension AlertListVC {
    //ALERT LIST API
    func callGetAlertListAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_ALERT) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrAlert.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AlertObject.init(payloadData[i])
                                strongSelf.arrAlert.append(objData)
                            }
                            
                            if strongSelf.arrAlert.count > 0 {
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
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        if strongSelf.arrAlert.count > 0 {
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
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //DELETE ALERT API
    func callDeleteAlertAPI(AlertID alertID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_ALERT + "/" + "\(alertID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestDELETEURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let row = strongSelf.arrAlert.firstIndex(where: {$0._id == alertID}) {
                            strongSelf.arrAlert.remove(at: row)
                        }
                        
                        if strongSelf.arrAlert.count > 0 {
                            strongSelf.tblList.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblList.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
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
