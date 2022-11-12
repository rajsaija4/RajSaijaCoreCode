//
//  WatchlistVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 03/11/21.
//

import UIKit
import SideMenuSwift
import SwiftyJSON
import SDWebImage

class WatchlistVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var clView: UICollectionView!
    @IBOutlet weak var lblNoWatchlist: UILabel!
    @IBOutlet weak var txtSelectedWatchlist: UITextField!
    @IBOutlet weak var btnEditWatchlist: UIButton!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblWatchlist: UITableView!
    @IBOutlet weak var lblNoStock: UILabel!
        
    var selectedIndex:Int = 0
    var arrWatchlist: [WatchlistObject] = []
    var objStockDetail = StockObject.init([:])
    var arrSymbol: [String] = []

    var arrSearchList: [AssetsObject] = []
    var searchActive: Bool = false
    
    var isBackFromCreate:Bool = false
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if !self.isBackFromCreate {
        selectedIndex = 0
        self.setupViewDetail()
        }
        
        if self.isBackFromCreate {
            let strSymbol = self.arrSymbol.joined(separator: ",")
            
            SocketIOManager.shared.setupSocket()
            SocketIOManager.shared.setupWatchlistSocketEvents()
            SocketIOManager.shared.socket?.connect()
            
            var objBars = Dictionary<String,AnyObject>()
            objBars["symbol"] = strSymbol as AnyObject
            objBars["type"] = EMIT_TYPE_BARS as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var objTrades = Dictionary<String,AnyObject>()
                objTrades["symbol"] = strSymbol as AnyObject
                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
            }
            
            self.isBackFromCreate = false
        }
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateWatchlistBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateWatchlistTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(WatchlistVC.getWatchlistBarData(notification:)), name: NSNotification.Name(kUpdateWatchlistBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(WatchlistVC.getWatchlistTradesData(notification:)), name: NSNotification.Name(kUpdateWatchlistTrades), object: nil)
    }
    
    @objc func getWatchlistBarData(notification: Notification) {
        debugPrint("=====Getting Watchlist Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if let row = self.objStockDetail.arrAssets.firstIndex(where: {$0.symbol == symbol}) {
                self.objStockDetail.arrAssets[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                self.objStockDetail.arrAssets[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.arrAssets[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.arrAssets[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.arrAssets[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.objStockDetail.arrAssets[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getWatchlistTradesData(notification: Notification) {
        debugPrint("=====Getting Watchlist Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if let row = self.objStockDetail.arrAssets.firstIndex(where: {$0.symbol == symbol}) {
                    let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    let openPrice = self.objStockDetail.arrAssets[row].openPrice
    //                let closePrice = self.objStockDetail.arrAssets[row].closePrice
                    let closePrice = self.objStockDetail.arrAssets[row].prev_close_price
                    let variationValue = currentPrice - closePrice //currentPrice - openPrice
                    let variationPer = (variationValue * 100) / closePrice
                    
                    self.objStockDetail.arrAssets[row].current_price = currentPrice
                    self.objStockDetail.arrAssets[row].plVariationValue = variationValue
                    self.objStockDetail.arrAssets[row].plVariationPer = variationPer
                    
                    DispatchQueue.main.async {
//                        self.tblWatchlist.reloadSections(IndexSet(integer: row), with: .none)
                        self.tblWatchlist.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
        self.txtSearch.textColor = UIColor.textFieldTextColor
        self.lblNoWatchlist.textColor = UIColor.labelTextColor
        self.txtSelectedWatchlist.textColor = UIColor.textFieldTextColor
        self.lblNoStock.textColor = UIColor.labelTextColor
        self.txtSelectedWatchlist.isUserInteractionEnabled = false
        self.btnEditWatchlist.setImage(UIImage(named: "ic_edit"), for: .normal)
        
        self.txtSearch.setLeftPadding()
        
        self.tblWatchlist.showsVerticalScrollIndicator = false
        self.tblWatchlist.tableFooterView = UIView()
        
        self.lblTitle.textColor = UIColor.labelTextColor
                
        self.viewContent.isHidden = true
        self.lblNoWatchlist.isHidden = true
        
        self.lblNoWatchlist.text = "No watchlist found\nAdd watchlist by click on + button"
        self.lblNoStock.text = "No stock found"
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupWatchlistSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
        self.callGetWatchlistAPI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateWatchlist), object: nil)
    }
    
    //MARK: - HELPER -
    
    @objc func updateData() {
        self.selectedIndex = 0
        self.txtSelectedWatchlist.isUserInteractionEnabled = false
        self.btnEditWatchlist.setImage(UIImage(named: "ic_edit"), for: .normal)
        
        self.searchActive = false
        self.txtSearch.text = ""
        
        self.callGetWatchlistAPI()
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.arrWatchlist.count < 4 {
            self.isBackFromCreate = true
            let controller = GlobalData.watchlistStoryBoard().instantiateViewController(withIdentifier: "CreateWatchlistVC") as! CreateWatchlistVC
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            GlobalData.shared.showSystemToastMesage(message: "You can add maximum 4 watchlist")
        }
    }
    
    @IBAction func btnEditWatchlistClick(_ sender: UIButton) {
        if self.btnEditWatchlist.hasImage(named: "ic_edit", for: .normal) {
            self.btnEditWatchlist.setImage(UIImage(named: "ic_save"), for: .normal)
            self.txtSelectedWatchlist.isUserInteractionEnabled = true
        } else {
            if self.txtSelectedWatchlist.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Watchlist name is required")
            }
            else {
                self.btnEditWatchlist.isUserInteractionEnabled = false
                self.callUpdateWatchlistAPI(WatchlistID: self.arrWatchlist[self.selectedIndex].id, WatchlistName: self.txtSelectedWatchlist.text ?? "")
            }
        }
    }
    
    @IBAction func btnDeleteWatchlistClick(_ sender: UIButton) {
        GlobalData.shared.displayConfirmationAlert(self, title: "Delete Watchlist", message: "Are you sure you want to delete this watchlist?", btnTitle1: "Cancel", btnTitle2: "Delete", actionBlock: { (isConfirmed) in
            if isConfirmed {
                self.callDeleteWatchlistAPI(WatchlistID: self.arrWatchlist[self.selectedIndex].id)
            }
        })
    }
    
    @IBAction func btnMicrophoneClick(_ sender: UIButton) {
        debugPrint("Microphone Click")
    }
}

// MARK: - UICOLLECTIONVIEW DATASOURCE & DELEGATE METHOD -

extension WatchlistVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrWatchlist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistHeaderCell", for: indexPath as IndexPath) as! WatchlistHeaderCell
        
        cell.lblTitle.text = self.arrWatchlist[indexPath.item].name
        
        if indexPath.item == self.selectedIndex {
            cell.viewLine.isHidden = false
        } else {
            cell.viewLine.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("You selected cell #\(indexPath.item)!")
        
        if indexPath.item != self.selectedIndex {
            self.view.endEditing(true)
            
            self.selectedIndex = indexPath.item
            
            self.clView.reloadData()
            
            self.txtSelectedWatchlist.isUserInteractionEnabled = false
            self.btnEditWatchlist.setImage(UIImage(named: "ic_edit"), for: .normal)
            
            self.searchActive = false
            self.txtSearch.text = ""
            
            SocketIOManager.shared.disconnectSocket()
            
            self.txtSelectedWatchlist.text = self.arrWatchlist[self.selectedIndex].name
            self.callGetStockListAPI(WatchlistID: self.arrWatchlist[self.selectedIndex].id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WatchlistHeaderCell", for: indexPath as IndexPath) as! WatchlistHeaderCell
        
        let font = UIFont(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblTitle.font.pointSize)!
        var width: CGFloat = 0
        let item = self.arrWatchlist[indexPath.item].name
        
        width = NSString(string: item).size(withAttributes: [NSAttributedString.Key.font : font]).width
        
        return CGSize(width: width + 20, height: 45)
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension WatchlistVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        } else if string == " " {
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
                if self.objStockDetail.arrAssets.count > 0 {
                    self.lblNoStock.isHidden = true
                } else {
                    self.lblNoStock.isHidden = false
                }
                GlobalData.shared.reloadTableView(tableView: self.tblWatchlist)
            }
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension WatchlistVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchActive {
            return self.arrSearchList.count
        } else {
            return self.objStockDetail.arrAssets.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchActive {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddStockCell", for: indexPath) as! AddStockCell
            
            let objDict = self.arrSearchList[indexPath.section]
            
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
            
            if self.arrSymbol.contains(objDict.symbol) {
                cell.btnAdd.isSelected = true
            } else {
                cell.btnAdd.isSelected = false
            }
            
            cell.btnAdd.tag = indexPath.section
            cell.btnAdd.addTarget(self, action: #selector(btnAddStockClick), for: .touchUpInside)
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchlistCell", for: indexPath) as! WatchlistCell
            
            let objDict = self.objStockDetail.arrAssets[indexPath.section]
            
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
            let decimalCurrentPrice = convertThousand(value: objDict.current_price)
            cell.lblStockAmount.text = "$" + "\(decimalCurrentPrice)"
            if objDict.symbole_description.count > 0 {
                cell.lblCompanyDetails.text = objDict.symbole_description
            }
            else {
                cell.lblCompanyDetails.text = objDict.companyName
            }
            
            if objDict.plVariationPer > 0 {
                cell.lblStockVariation.text = "$+\(convertThousand(value: objDict.plVariationValue)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblStockVariation.text = "$\(convertThousand(value: objDict.plVariationValue)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblStockVariation.text = "$\(convertThousand(value: objDict.plVariationValue)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
            } else if objDict.plVariationValue < 0 {
                cell.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.lblStockVariation.textColor = UIColor.tblMarketDepthContent
            }
                        
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var objData: AssetsObject!
        
        if self.searchActive {
            objData = self.arrSearchList[indexPath.section]
        } else {
            objData = self.objStockDetail.arrAssets[indexPath.section]
        }
        
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
        controller.strSymbol = objData.symbol
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let objDict = self.objStockDetail.arrAssets[indexPath.section]
            
            GlobalData.shared.displayConfirmationAlert(self, title: "Delete Stock", message: "Are you sure you want to delete this stock from watchlist?", btnTitle1: "Cancel", btnTitle2: "Delete", actionBlock: { (isConfirmed) in
                if isConfirmed {
                    self.callDeleteStockFromWatchlistAPI(WatchlistID: self.arrWatchlist[self.selectedIndex].id, StockSymbol: objDict.symbol)
                }
            })
        }
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
        let objDict = self.arrSearchList[sender.tag]
        
        if !self.arrSymbol.contains(objDict.symbol) {
            if self.objStockDetail.arrAssets.count < 20 {
                self.callAddStockToWatchlist(WatchlistID: self.arrWatchlist[self.selectedIndex].id, StockSymbol: objDict.symbol)
            } else {
                GlobalData.shared.showSystemToastMesage(message: "You can add maximum 20 records in single watchlist")
            }
        }
    }
}

//MARK: - API CALL -

extension WatchlistVC {
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
                                strongSelf.viewContent.isHidden = false
                                strongSelf.lblNoWatchlist.isHidden = true
                            } else {
                                strongSelf.viewContent.isHidden = true
                                strongSelf.lblNoWatchlist.isHidden = false
                            }
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clView)
                            
                            if strongSelf.arrWatchlist.count > 0 {
                                strongSelf.txtSelectedWatchlist.text = strongSelf.arrWatchlist[0].name
                                strongSelf.callGetStockListAPI(WatchlistID: strongSelf.arrWatchlist[0].id)
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        if strongSelf.arrWatchlist.count > 0 {
                            strongSelf.viewContent.isHidden = false
                            strongSelf.lblNoWatchlist.isHidden = true
                        } else {
                            strongSelf.viewContent.isHidden = true
                            strongSelf.lblNoWatchlist.isHidden = false
                        }
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clView)

                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET STOCK LIST OF SELECTED WATCHLIST
    func callGetStockListAPI(WatchlistID watchlistID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_WATCHLIST + "/" + "\(watchlistID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = StockObject.init(payload)
                            strongSelf.arrSymbol = strongSelf.objStockDetail.arrAssets.map { $0.symbol }
                            
                            if strongSelf.objStockDetail.arrAssets.count > 0 {
                                let strSymbol = strongSelf.arrSymbol.joined(separator: ",")
                                
                                SocketIOManager.shared.setupSocket()
                                SocketIOManager.shared.setupWatchlistSocketEvents()
                                SocketIOManager.shared.socket?.connect()
                                
                                var objBars = Dictionary<String,AnyObject>()
                                objBars["symbol"] = strSymbol as AnyObject
                                objBars["type"] = EMIT_TYPE_BARS as AnyObject
                                SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    var objTrades = Dictionary<String,AnyObject>()
                                    objTrades["symbol"] = strSymbol as AnyObject
                                    objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                                    SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
                                }
                                
                                strongSelf.lblNoStock.isHidden = true
                            } else {
                                strongSelf.lblNoStock.isHidden = false
                            }
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
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
    func callAddStockToWatchlist(WatchlistID watchlistID: String, StockSymbol stockSymbol: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.ADD_STOCK_WATCHLIST + "/" + "\(watchlistID)"
        
        var params: [String:Any] = [:]
        params["asset"] = stockSymbol
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = StockObject.init(payload)
                            strongSelf.arrSymbol = strongSelf.objStockDetail.arrAssets.map { $0.symbol }
                            
                            if strongSelf.objStockDetail.arrAssets.count > 0 {
//                                let strSymbol = strongSelf.arrSymbol.joined(separator: ",")
                                
                                var objBars = Dictionary<String,AnyObject>()
//                                objBars["symbol"] = strSymbol as AnyObject
                                objBars["symbol"] = stockSymbol as AnyObject
                                objBars["type"] = EMIT_TYPE_BARS as AnyObject
                                SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    var objTrades = Dictionary<String,AnyObject>()
//                                    objTrades["symbol"] = strSymbol as AnyObject
                                    objTrades["symbol"] = stockSymbol as AnyObject
                                    objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                                    SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
                                }
                                
                                strongSelf.lblNoStock.isHidden = true
                            } else {
                                strongSelf.lblNoStock.isHidden = false
                            }
                            
                            strongSelf.searchActive = false
                            strongSelf.txtSearch.text = ""
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
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
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //DELETE STOCK FROM WATCHLIST API
    func callDeleteStockFromWatchlistAPI(WatchlistID watchlistID: String, StockSymbol stockSymbol: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.DELETE_STOCK_WATCHLIST + "/" + "\(watchlistID)"
        
        var params: [String:Any] = [:]
        params["asset"] = stockSymbol
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let row = strongSelf.objStockDetail.arrAssets.firstIndex(where: {$0.symbol == stockSymbol}) {
                            strongSelf.objStockDetail.arrAssets.remove(at: row)
                        }
                        
                        strongSelf.arrSymbol = strongSelf.objStockDetail.arrAssets.map { $0.symbol }
                        
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        if strongSelf.objStockDetail.arrAssets.count > 0 {
                            strongSelf.lblNoStock.isHidden = true
                        } else {
                            strongSelf.lblNoStock.isHidden = false
                        }
                        
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
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
    
    //UPDATE WATCHLIST
    func callUpdateWatchlistAPI(WatchlistID watchlistID: String, WatchlistName watchlistName: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_WATCHLIST + "/" + "\(watchlistID)"
        
        var params: [String:Any] = [:]
        params["name"] = watchlistName
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = StockObject.init(payload)
                            strongSelf.arrSymbol = strongSelf.objStockDetail.arrAssets.map { $0.symbol }
                            
                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            
                            strongSelf.btnEditWatchlist.isUserInteractionEnabled = true
                            strongSelf.btnEditWatchlist.setImage(UIImage(named: "ic_edit"), for: .normal)
                            
                            strongSelf.txtSelectedWatchlist.isUserInteractionEnabled = false
                            
//                            if let row = strongSelf.arrWatchlist.firstIndex(where: {$0.id == watchlistID}) {
//                                strongSelf.arrWatchlist[row].name = strongSelf.objStockDetail.name
//                            }
                            strongSelf.arrWatchlist[strongSelf.selectedIndex].name = strongSelf.objStockDetail.name
                            
                            if strongSelf.objStockDetail.arrAssets.count > 0 {
                                strongSelf.lblNoStock.isHidden = true
                            } else {
                                strongSelf.lblNoStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clView)
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnEditWatchlist.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnEditWatchlist.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnEditWatchlist.isUserInteractionEnabled = true
        }
    }
    
    //DELETE WATCHLIST
    func callDeleteWatchlistAPI(WatchlistID watchlistID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.DELETE_WATCHLIST + "/" + "\(watchlistID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestDELETEURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let row = strongSelf.arrWatchlist.firstIndex(where: {$0.id == watchlistID}) {
                            strongSelf.arrWatchlist.remove(at: row)
                        }
                        
                        if strongSelf.arrWatchlist.count > 0 {
                            strongSelf.viewContent.isHidden = false
                            strongSelf.lblNoWatchlist.isHidden = true
                        } else {
                            strongSelf.viewContent.isHidden = true
                            strongSelf.lblNoWatchlist.isHidden = false
                        }
                        
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clView)
                        
                        if strongSelf.arrWatchlist.count > 0 {
                            strongSelf.selectedIndex = 0
                            strongSelf.txtSelectedWatchlist.text = strongSelf.arrWatchlist[0].name
                            strongSelf.callGetStockListAPI(WatchlistID: strongSelf.arrWatchlist[0].id)
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
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
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
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblWatchlist)
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
