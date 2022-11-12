//
//  CreateWatchlistVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 24/01/22.
//

import UIKit
import SwiftyJSON
import SDWebImage

class CreateWatchlistVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var btnSave: UIButton!

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var txtWatchlist: UITextField!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblStocklist: UITableView!
    @IBOutlet weak var lblNoStock: UILabel!
    
    var arrStockList: [AssetsObject] = []
    var arrSearchList: [AssetsObject] = []
    var searchActive: Bool = false
    
    var page:Int = 1
    var apiCall:Int = 0
    
    var selectedAssets: [String] = []
    
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
        }
        
        self.txtSearch.textColor = UIColor.textFieldTextColor
        self.txtWatchlist.textColor = UIColor.textFieldTextColor
        self.lblNoStock.textColor = UIColor.labelTextColor
        
        self.txtSearch.setLeftPadding()
        
        self.tblStocklist.showsVerticalScrollIndicator = false
        self.tblStocklist.tableFooterView = UIView()
        
        self.viewContent.isHidden = true
        self.lblNoStock.isHidden = true
        
        self.lblNoStock.text = "No stock found"
        
        self.callGetDefaultListAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveClick(_ sender: UIButton) {
        if self.txtWatchlist.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Watchlist name is required")
        }
        else if self.selectedAssets.count < 1 {
            GlobalData.shared.showSystemToastMesage(message: "Selection any share is required")
        }
        else {
            let strAssets = self.selectedAssets.joined(separator: ", ")
            
            self.btnSave.isUserInteractionEnabled = false
            self.callCreateWatchlistAPI(SelectedAssets: strAssets)
        }
    }
    
    @IBAction func btnMicrophoneClick(_ sender: UIButton) {
        debugPrint("Microphone Click")
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension CreateWatchlistVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        } else if string == "" {
            if textField == self.txtSearch {
                return false
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtSearch {
            if textField.text != "" {
                self.searchActive = true
                self.callSearchShareAPI(SearchString: textField.text ?? "")
            } else {
                self.searchActive = false
                if self.arrStockList.count > 0 {
                    self.viewContent.isHidden = false
                    self.lblNoStock.isHidden = true
                } else {
                    self.viewContent.isHidden = true
                    self.lblNoStock.isHidden = false
                }
                GlobalData.shared.reloadTableView(tableView: self.tblStocklist)
            }
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension CreateWatchlistVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchActive {
            return self.arrSearchList.count
        } else {
            return self.arrStockList.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddStockCell", for: indexPath) as! AddStockCell
        
        var objDict: AssetsObject!
        
        if self.searchActive {
            objDict = self.arrSearchList[indexPath.section]
        } else {
            objDict = self.arrStockList[indexPath.section]
        }
        
        if objDict.image == "" {
            cell.viewStock.backgroundColor = UIColor.init(hex: 0x27B1FC)
            
            let dpName = objDict.symbol.prefix(1)
            cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
        } else {
            cell.viewStock.backgroundColor = UIColor.white
            
            cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
        }
        
        cell.lblStockName.text = objDict.symbol
        cell.lblStockExchange.text = objDict.exchange
        
        if self.selectedAssets.contains(objDict.symbol) {
            cell.btnAdd.isSelected = true
        } else {
            cell.btnAdd.isSelected = false
        }
        
        cell.btnAdd.tag = indexPath.section
        cell.btnAdd.addTarget(self, action: #selector(btnAddStockClick), for: .touchUpInside)
        
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
    
    //FOOTER VIEW
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
//        footerView.backgroundColor = .clear
//        return footerView
//    }
    
    //CELL ACTION
    @objc func btnAddStockClick(_ sender: UIButton) {
        var objDict: AssetsObject!
        
        if self.searchActive {
            objDict = self.arrSearchList[sender.tag]
        } else {
            objDict = self.arrStockList[sender.tag]
        }
        
        if self.selectedAssets.contains(objDict.symbol) {
            if let index = self.selectedAssets.firstIndex(of: objDict.symbol) {
                self.selectedAssets.remove(at: index)
            }
            self.tblStocklist.reloadSections(IndexSet(integer: sender.tag), with: .none)
        } else {
            if self.selectedAssets.count < 20 {
                self.selectedAssets.append(objDict.symbol)
                self.tblStocklist.reloadSections(IndexSet(integer: sender.tag), with: .none)
            } else {
                GlobalData.shared.showSystemToastMesage(message: "You can add maximum 20 records in single watchlist")
            }
        }
    }
    /*
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            if offsetY > contentHeight - scrollView.frame.height {
                scrollingFinish()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        if offsetY > contentHeight - scrollView.frame.height {
            scrollingFinish()
        }
    }

    func scrollingFinish() {
        if apiCall == 5 {
            self.callGetStocklistAPI()
        } else {
            debugPrint("No more data found...")
        }
    }
    */
}

//MARK: - API CALL -

extension CreateWatchlistVC {
    /*
    //GET STOCK LIST
    func callGetStocklistAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_STOCKLIST + "/" + "\(self.page)"
        
        if self.page == 1 {
            GlobalData.shared.showDefaultProgress()
        }
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let result = payloadData["result"] as? [Dictionary<String, Any>] {
                                if strongSelf.page == 1 {
                                    strongSelf.arrStockList.removeAll()
                                }
                                
                                if result.count > 0 {
                                    strongSelf.page = strongSelf.page + 1
                                    strongSelf.apiCall = 5
                                } else {
                                    strongSelf.apiCall = 0
                                }
                                
                                for i in 0..<result.count {
                                    let objData = AssetsObject.init(result[i])
                                    strongSelf.arrStockList.append(objData)
                                }
                                
                                if strongSelf.arrStockList.count > 0 {
                                    strongSelf.viewContent.isHidden = false
                                    strongSelf.lblNoStock.isHidden = true
                                } else {
                                    strongSelf.viewContent.isHidden = true
                                    strongSelf.lblNoStock.isHidden = false
                                }
                                
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblStocklist)
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
    */
    
    //GET DEFAULT STOCK LIST
    func callGetDefaultListAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_DEFAULT_STOCKLIST) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrStockList.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrStockList.append(objData)
                            }
                            
                            if strongSelf.arrStockList.count > 0 {
                                strongSelf.viewContent.isHidden = false
                                strongSelf.lblNoStock.isHidden = true
                            } else {
                                strongSelf.viewContent.isHidden = true
                                strongSelf.lblNoStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblStocklist)
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
    
    //SEARCH SHARE BY NAME
    func callSearchShareAPI(SearchString searchString: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.SEARCH_SHARE_NAME + "/" + "\(searchString)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrSearchList.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrSearchList.append(objData)
                            }
                            
                            if strongSelf.arrSearchList.count > 0 {
                                strongSelf.lblNoStock.isHidden = true
                            } else {
                                strongSelf.lblNoStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblStocklist)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrSearchList.removeAll()
                        if strongSelf.arrSearchList.count > 0 {
                            strongSelf.lblNoStock.isHidden = true
                        } else {
                            strongSelf.lblNoStock.isHidden = false
                        }
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblStocklist)
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //CREATE WATCHLIST
    func callCreateWatchlistAPI(SelectedAssets selectedAssets: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
       
        var params: [String:Any] = [:]
        params["assets"] = selectedAssets
        params["name"] = self.txtWatchlist.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_WATCHLIST, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.btnSave.isUserInteractionEnabled = true
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateWatchlist), object: nil)
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnSave.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnSave.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnSave.isUserInteractionEnabled = true
        }
    }
}
