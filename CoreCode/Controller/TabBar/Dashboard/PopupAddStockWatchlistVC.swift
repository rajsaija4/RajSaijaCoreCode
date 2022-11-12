//
//  PopupAddStockWatchlistVC.swift
//

import UIKit
import SwiftyJSON

class PopupAddStockWatchlistVC: UIViewController {

    // MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var tblList: ContentSizedTableView!
    @IBOutlet weak var tblListHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    
    var strSymbol: String = ""
    var arrWatchlist: [WatchlistObject] = []
    var selectedIndex:Int = -1
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
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
            let height = self.tblList.contentSize.height
            
            if height > 260 {
                self.tblListHeightConstraint.constant = 260
            } else {
                self.tblListHeightConstraint.constant = self.tblList.contentSize.height
            }
        }
    }
    
    // MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.tblList.isHidden = true
        self.lblNoRecord.isHidden = true
        
        self.lblNoRecord.text = "No watchlist found\nAdd any watchlist from watchlist module"
        
        self.callGetWatchlistAPI()
    }
    
    //MARK: - HELPER -
    
    // MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if self.selectedIndex == -1 {
            GlobalData.shared.showSystemToastMesage(message: "Please select any watchlist")
        } else {
            self.callAddStockToWatchlist(WatchlistID: self.arrWatchlist[self.selectedIndex].id)
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension PopupAddStockWatchlistVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrWatchlist.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddStockWatchlistCell", for: indexPath) as! AddStockWatchlistCell
        
        cell.lblName.text = self.arrWatchlist[indexPath.section].name
        
        if indexPath.section == self.selectedIndex {
            cell.btnTick.isSelected = true
        } else {
            cell.btnTick.isSelected = false
        }
        
        cell.btnTick.tag = indexPath.section
        cell.btnTick.addTarget(self, action: #selector(btnTickClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //CELL ACTION
    @objc func btnTickClick(_ sender: UIButton) {
        if sender.tag != self.selectedIndex {
            self.selectedIndex = sender.tag
            self.tblList.reloadData()
        }
    }
}

//MARK: - API CALL -

extension PopupAddStockWatchlistVC {
    //GET WATCHLIST
    func callGetWatchlistAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_WATCHLIST) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrWatchlist.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = WatchlistObject.init(payloadData[i])
                                strongSelf.arrWatchlist.append(objData)
                            }
                            
                            if strongSelf.arrWatchlist.count > 0 {
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
    
    //ADD STOCK TO WATCHLIST
    func callAddStockToWatchlist(WatchlistID watchlistID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.ADD_STOCK_WATCHLIST + "/" + "\(watchlistID)"
        
        var params: [String:Any] = [:]
        params["asset"] = self.strSymbol
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
