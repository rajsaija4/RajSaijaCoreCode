//
//  StatementHistoryVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 28/12/21.
//

import UIKit
import SwiftyJSON

class StatementHistoryVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblHeaderTitle: UILabel!
    @IBOutlet weak var lblHistoryTitle: UILabel!
    @IBOutlet weak var tblHistory: ContentSizedTableView!
    @IBOutlet weak var tblHistoryHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    @IBOutlet weak var lblDocumentTitle: UILabel!
    @IBOutlet weak var lblAccountStatement: UILabel!
    @IBOutlet weak var lblTaxDocument: UILabel!
    
    var arrHistoryList: [HistoryObject] = []
    
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
            self.tblHistoryHeightConstraint.constant = self.tblHistory.contentSize.height
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
        
        self.lblHeaderTitle.textColor = UIColor.labelTextColor
        self.lblHistoryTitle.textColor = UIColor.labelTextColor
        
        self.lblDocumentTitle.textColor = UIColor.labelTextColor
        self.lblAccountStatement.textColor = UIColor.labelTextColor
        self.lblTaxDocument.textColor = UIColor.labelTextColor
        
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblHistory.showsVerticalScrollIndicator = false
        self.tblHistory.tableFooterView = UIView()
        
        self.tblHistory.isHidden = true
        self.lblNoRecord.isHidden = true
        
        self.callGetAllHistoryAPI()
    }

    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShowMoreClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "AllHistoryVC") as! AllHistoryVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnAccountStatementClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "AccountStatementVC") as! AccountStatementVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnTaxDocumentClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "TaxDocumentVC") as! TaxDocumentVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension StatementHistoryVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrHistoryList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatementHistoryCell") as! StatementHistoryCell
        
        let objData = self.arrHistoryList[indexPath.section]
        let date = objData.transaction_time.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
        let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
        
        cell.lblName.text = objData.symbol
        cell.lblDate.text = finalDate
        cell.lblAmount.text = "$" + convertThousand(value: Double(objData.price) ?? 0.0)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let objData = self.arrHistoryList[indexPath.section]
        
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StatementDetailVC") as! StatementDetailVC
        controller.strType = "History"
        controller.objHistory = objData
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension StatementHistoryVC {
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
                            if let allHistory = payloadData["all"] as? [Dictionary<String, Any>] {
                                strongSelf.arrHistoryList.removeAll()
                                
                                if allHistory.count > 5 {
                                    for i in 0..<5 {
                                        let objData = HistoryObject.init(allHistory[i])
                                        strongSelf.arrHistoryList.append(objData)
                                    }
                                } else {
                                    for i in 0..<allHistory.count {
                                        let objData = HistoryObject.init(allHistory[i])
                                        strongSelf.arrHistoryList.append(objData)
                                    }
                                }
                                
                                if strongSelf.arrHistoryList.count > 0 {
                                    strongSelf.tblHistory.isHidden = false
                                    strongSelf.lblNoRecord.isHidden = true
                                } else {
                                    strongSelf.tblHistory.isHidden = true
                                    strongSelf.lblNoRecord.isHidden = false
                                }
                                
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblHistory)
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
