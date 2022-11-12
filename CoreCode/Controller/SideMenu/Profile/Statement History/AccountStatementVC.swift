//
//  AccountStatementVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/12/21.
//

import UIKit
import SwiftyJSON

class AccountStatementVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblDocumentTitle: UILabel!
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrStatement: [OrderObject] = []
    
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
        self.lblDocumentTitle.textColor = UIColor.tblMarketDepthContent
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.tblList.isHidden = true
        self.lblNoRecord.isHidden = true
        
        self.callGetStatementAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension AccountStatementVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrStatement.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AccountStatementCell", for: indexPath) as! AccountStatementCell
        
        let objData = self.arrStatement[indexPath.section]
        let date = objData.created_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
        let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
        
        cell.lblTitle.text = "Account Statement"
        cell.lblDate.text = finalDate
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
                
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        controller.isFrom = "Account Statement"
        controller.objStatement = self.arrStatement[indexPath.section]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension AccountStatementVC {
    //WITHDRAW FUNDS HISTORY
    func callGetStatementAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_STATEMENT) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrStatement.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = OrderObject.init(payloadData[i])
                                strongSelf.arrStatement.append(objData)
                            }
                            
                            if strongSelf.arrStatement.count > 0 {
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
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
