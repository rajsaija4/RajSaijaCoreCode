//
//  PortfolioVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 03/11/21.
//

import UIKit
import SideMenuSwift
import SwiftyJSON

class PortfolioVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblInvestedValue: UILabel!
    @IBOutlet weak var lblCurrentValue: UILabel!
    @IBOutlet weak var lblPLValue: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tblPortfolio: ContentSizedTableView!
    @IBOutlet weak var tblPortfolioHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!

    var sortBy:Int = -1
    
    var arrPortfolio: [PortfolioObject] = []
    
    var arrSearchList: [PortfolioObject] = []
    var searchActive: Bool = false
    
    var investedAmount: Double = 0.0
    var currentAmount: Double = 0.0
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupPortfolioSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        var strSymbol:String = ""
        
        if self.searchActive {
            let arrSymbol = self.arrSearchList.map { $0.symbol }
            strSymbol = arrSymbol.joined(separator: ",")
        } else {
            let arrSymbol = self.arrPortfolio.map { $0.symbol }
            strSymbol = arrSymbol.joined(separator: ",")
        }
        
        if strSymbol != "" {
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
        }
        
        self.SetupAllSocketNotification()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updatePortfolioData), name: NSNotification.Name(rawValue: kUpdatePortfolio), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToNextController(_:)), name: NSNotification.Name(rawValue: "moveToNextController"), object: nil)
        
        //ADDED NOTIFICATION OBSERVER TO NOTIFY ON KEYBOARD SHOW/HIDE
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdatePortfolioBars), object: nil)
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdatePortfolioTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblPortfolioHeightConstraint.constant = self.tblPortfolio.contentSize.height
        }
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioVC.getPortfolioBarData(notification:)), name: NSNotification.Name(kUpdatePortfolioBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioVC.getPortfolioTradesData(notification:)), name: NSNotification.Name(kUpdatePortfolioTrades), object: nil)
    }
    
    @objc func getPortfolioBarData(notification: Notification) {
        debugPrint("=====Getting Portfolio Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if self.searchActive {
                if let row = self.arrSearchList.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrSearchList[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrSearchList[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else {
                if let row = self.arrPortfolio.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrPortfolio[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                    self.arrPortfolio[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrPortfolio[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrPortfolio[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrPortfolio[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrPortfolio[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            }
        }
    }
    
    @objc func getPortfolioTradesData(notification: Notification) {
        debugPrint("=====Getting Portfolio Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if self.searchActive {
                    if let row = self.arrSearchList.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrSearchList[row].openPrice
                        let closePrice = self.arrSearchList[row].closePrice
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrSearchList[row].lastday_price = "\(currentPrice)"
                        self.arrSearchList[row].plVariationValue = variationValue
                        self.arrSearchList[row].plVariationPer = variationPer
                        self.arrSearchList[row].stock_current = currentPrice
                        
                        let arrCurrent = self.arrSearchList.map { $0.stock_current }
                        self.currentAmount = arrCurrent.sum()
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.setPortfolioData()
//                            self.tblPortfolio.reloadSections(IndexSet(integer: row), with: .none)
//                        }
                        DispatchQueue.main.async {
                            self.setPortfolioData()
//                            self.tblPortfolio.reloadSections(IndexSet(integer: row), with: .none)
                            self.tblPortfolio.reloadData()
                        }
                    }
                } else {
                    if let row = self.arrPortfolio.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrPortfolio[row].openPrice
                        let closePrice = self.arrPortfolio[row].closePrice
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrPortfolio[row].lastday_price = "\(currentPrice)"
                        self.arrPortfolio[row].plVariationValue = variationValue
                        self.arrPortfolio[row].plVariationPer = variationPer
                        self.arrPortfolio[row].stock_current = currentPrice
                        
                        let arrCurrent = self.arrPortfolio.map { $0.stock_current }
                        self.currentAmount = arrCurrent.sum()
                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                            self.setPortfolioData()
//                            self.tblPortfolio.reloadSections(IndexSet(integer: row), with: .none)
//                        }
                        DispatchQueue.main.async {
                            self.setPortfolioData()
//                            self.tblPortfolio.reloadSections(IndexSet(integer: row), with: .none)
                            self.tblPortfolio.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        self.searchBar.showsCancelButton = false
        self.searchBar.delegate = self
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.searchBar.setupSearchBar(background: .clear, inputText: UIColor.textFieldTextColor, placeholderText: UIColor.tblMarketDepthContent, image: UIColor.tblMarketDepthContent)
            self.searchBar.setImage(UIImage(), for: .search, state: .normal)
            self.searchBar.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
        }
                
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblNoRecord.textColor = UIColor.labelTextColor
                
        self.tblPortfolio.showsVerticalScrollIndicator = false
        self.tblPortfolio.tableFooterView = UIView()
        
        self.tblPortfolio.isHidden = true
        self.lblNoRecord.isHidden = true
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupPortfolioSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
        self.callGetPortfolioAPI()
    }
    
    func setPortfolioData() {
        let variationValue = self.currentAmount - self.investedAmount
        let variationPer = (variationValue * 100) / self.investedAmount
        
        self.lblInvestedValue.text = "$" + "\(convertThousand(value: Double(self.investedAmount)))"
        self.lblCurrentValue.text = "$" + "\(convertThousand(value: Double(self.currentAmount)))"
        
        if variationValue > 0 {
            self.lblPLValue.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "+ $\(convertThousand(value: variationValue))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x81CF01), strSecond: "+\(String(format: "%.2f", variationPer))%", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize - 5)!, strSecondColor: UIColor.init(hex: 0x81CF01))
        } else if variationValue < 0 {
            self.lblPLValue.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: " $\(convertThousand(value: variationValue))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize)!, strFirstColor: UIColor.init(hex: 0xFE3D2F), strSecond: "\(String(format: "%.2f", variationPer))%", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize - 5)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
        } else {
            self.lblPLValue.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: " $\(convertThousand(value: variationValue))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x676767), strSecond: "\(String(format: "%.2f", variationPer))%", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblPLValue.font.pointSize - 5)!, strSecondColor: UIColor.init(hex: 0x676767))
        }
    }
    
    //MARK: - HELPER -
    
    @objc func updatePortfolioData() {
        self.sortBy = -1
        self.callTradingAccountAPI()
        self.callGetPortfolioAPI()
    }
    
    @objc private func moveToNextController(_ notification: NSNotification) {
        if let objData = notification.userInfo as? [String: Any] {
            var objPortfolio: PortfolioObject!
            var objStockDetail: AssetsObject!
            
            if let portfolio = objData["portfolio"] as? PortfolioObject {
                objPortfolio = portfolio
            }
            if let assets = objData["assets"] as? AssetsObject {
                objStockDetail = assets
            }
            
//        if let objStockDetail = notification.userInfo?["data"] as? AssetsObject {
            
            let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewMarketVc") as! NewMarketVc
//            controller.objPortfolio = objPortfolio
            controller.objStockDetail = objStockDetail
            controller.isSelectedBuy = false
            self.navigationController?.pushViewController(controller, animated: true)
            
//            let controller = GlobalData.portfolioStoryBoard().instantiateViewController(withIdentifier: "PortfolioStockSellVC") as! PortfolioStockSellVC
//            controller.objPortfolio = objPortfolio
//            controller.objStockDetail = objStockDetail
//            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    //TO AVOIDE DATA GOES BEHIND TABLEVIEW WE SET TABLEVIEW BOTTOM OFFSET TO KEYBOARD HEIGHT SO THAT TABLEVIEW LAST RECORD DISPLAY ABOVE KEYBOARD
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            self.tblPortfolio.setBottomInset(to: keyboardHeight)
        }
    }

    //RESET TABLEVIEW BOTTOM OFFSET TO 0 ON KEYBOARD HIDES
    @objc func keyboardWillHide(notification: Notification) {
        self.tblPortfolio.setBottomInset(to: 0.0)
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnFilterClick(_ sender: UIButton) {
        let controller = GlobalData.portfolioStoryBoard().instantiateViewController(withIdentifier: "PopupPortfolioFilterVC") as! PopupPortfolioFilterVC
        controller.sortBy = self.sortBy
        controller.delegate = self
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnViewReportClick(_ sender: UIButton) {
        let controller = GlobalData.portfolioStoryBoard().instantiateViewController(withIdentifier: "ViewReportVC") as! ViewReportVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - FILTER DELEGATE -

extension PortfolioVC: selectedFilterDelegate {
    func selectedFilter(sortBy: Int) {
        self.sortBy = sortBy
        
        if self.sortBy == 0 {
            self.callGetPortfolioFilterAPI(SortingBy: "name")
        } else if self.sortBy == 1 {
            self.callGetPortfolioFilterAPI(SortingBy: "percentage")
        } else {
            self.callGetPortfolioAPI()
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension PortfolioVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchActive {
            return self.arrSearchList.count
        } else {
            return self.arrPortfolio.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PortfolioCell", for: indexPath) as! PortfolioCell
        
        var objDict: PortfolioObject!
        
        if self.searchActive {
            objDict = self.arrSearchList[indexPath.section]
        } else {
            objDict = self.arrPortfolio[indexPath.section]
        }
        
        let qty = (objDict.qty as NSString).doubleValue
        let avgPrice = (objDict.avg_entry_price as NSString).doubleValue
        let invested = (objDict.cost_basis as NSString).doubleValue
        let lastDayPrice = (objDict.lastday_price as NSString).doubleValue
//        let variationValue = (objDict.unrealized_pl as NSString).doubleValue
//        let variationPer = (objDict.unrealized_plpc as NSString).doubleValue
//        let strVariationPer = String(format: "%.4f", variationPer)
        let current = qty * lastDayPrice
        let plValue = current - invested
        let plPer = (plValue * 100) / invested
        
        cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: String(format: "%.4f", qty), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
        cell.lblAvg.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Avg:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblAvg.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: "$" + convertThousand(value: avgPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblAvg.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
        cell.lblName.text = objDict.symbol
        cell.lblInvested.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Invested:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblInvested.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: "$" + convertThousand(value: invested), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblInvested.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
        cell.lblAmount.text = "$" + convertThousand(value: lastDayPrice)
        
        //**********//
//        if objDict.plVariationPer > 0 {
//            cell.lblVariation.text = "+\(String(format: "%.2f", objDict.plVariationValue)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
//        } else if objDict.plVariationPer < 0 {
//            cell.lblVariation.text = "\(String(format: "%.2f", objDict.plVariationValue)) (\(String(format: "%.2f", objDict.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
//        } else {
//            cell.lblVariation.text = "\(String(format: "%.2f", objDict.plVariationValue)) (0.00%)"
//        }
        
        if plPer > 0 {
            cell.lblVariation.text = "$+\(convertThousand(value: plValue)) (+\(String(format: "%.2f", plPer))%)"
            cell.lblVariation.textColor = UIColor.init(hex: 0x65AA3D)
        } else if plPer < 0 {
            cell.lblVariation.text = "$\(convertThousand(value: plValue)) (\(String(format: "%.2f", plPer))%)"
            cell.lblVariation.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            cell.lblVariation.text = "$\(convertThousand(value: plValue)) (0.00%)"
            cell.lblVariation.textColor = UIColor.tblMarketDepthContent
        }
        //**********//
        cell.lblLTPValue.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "LTP" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblLTPValue.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: "$" + convertThousand(value: lastDayPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblLTPValue.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
       
        if objDict.plVariationValue > 0 {
            cell.lblAmount.textColor = UIColor.init(hex: 0x65AA3D)
//            cell.lblVariation.textColor = UIColor.init(hex: 0x65AA3D)
        } else if objDict.plVariationValue < 0 {
            cell.lblAmount.textColor = UIColor.init(hex: 0xFE3D2F)
//            cell.lblVariation.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            cell.lblAmount.textColor = UIColor.tblMarketDepthContent
//            cell.lblVariation.textColor = UIColor.tblMarketDepthContent
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var objDict: PortfolioObject!
        
        if self.searchActive {
            objDict = self.arrSearchList[indexPath.section]
        }
        else {
            if self.searchBar.text?.count ?? "".count <= 0 {
                self.searchActive = false
                objDict = self.arrPortfolio[indexPath.section]
            }
            else {
                self.searchActive = true
                objDict = self.arrSearchList[indexPath.section]
            }
        }
        
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        
        let controller = GlobalData.portfolioStoryBoard().instantiateViewController(withIdentifier: "PopupStockSellVC") as! PopupStockSellVC
        controller.objPortfolio = objDict
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - UISEARCHBAR DELEGATE METHOD -

extension PortfolioVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if(searchBar.text != "") {
            self.searchActive = true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
        searchBar.text = nil
        searchBar.resignFirstResponder()
        self.tblPortfolio.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.tblPortfolio.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchActive = false
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBar.showsCancelButton = true
        if(searchText != "") {
            self.searchActive = true
            if (self.arrPortfolio.count) > 0 {
                self.arrSearchList = self.arrPortfolio.filter() {
                let symbolExchange = ("\(($0 as PortfolioObject).symbol.lowercased())")// \(($0 as PortfolioObject).exchange.lowercased())
                    return symbolExchange.contains(searchText.lowercased())
                }
            }
        } else {
            self.searchActive = false
        }
        
        if self.searchActive {
            if self.arrSearchList.count > 0 {
                self.lblNoRecord.isHidden = true
            } else {
                self.lblNoRecord.isHidden = false
            }
        } else {
            if self.arrPortfolio.count > 0 {
                self.lblNoRecord.isHidden = true
            } else {
                self.lblNoRecord.isHidden = false
            }
        }
        
        self.tblPortfolio.reloadData()
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension PortfolioVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - API CALL -

extension PortfolioVC {
    //PORTFOLIO DATA
    func callGetPortfolioAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_PORTFOLIO) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrPortfolio.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = PortfolioObject.init(payloadData[i])
                                strongSelf.arrPortfolio.append(objData)
                            }
                                                        
                            if strongSelf.arrPortfolio.count > 0 {
                                let arrInvestment = strongSelf.arrPortfolio.map { $0.stock_investment }
                                strongSelf.investedAmount = arrInvestment.sum()
                                
                                let arrCurrent = strongSelf.arrPortfolio.map { $0.stock_current }
                                strongSelf.currentAmount = arrCurrent.sum()
                                
                                strongSelf.setPortfolioData()
                                
                                let arrSymbol = strongSelf.arrPortfolio.map { $0.symbol }
                                let strSymbol = arrSymbol.joined(separator: ",")
                                
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
                                
                                strongSelf.tblPortfolio.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblPortfolio.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblPortfolio)
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
    
    //PORTFOLIO FILTER DATA
    func callGetPortfolioFilterAPI(SortingBy sortingBy: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_PORTFOLIO_FILTER + "\(sortingBy)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrPortfolio.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = PortfolioObject.init(payloadData[i])
                                strongSelf.arrPortfolio.append(objData)
                            }
                                                        
                            if strongSelf.arrPortfolio.count > 0 {
                                let arrInvestment = strongSelf.arrPortfolio.map { $0.stock_investment }
                                strongSelf.investedAmount = arrInvestment.sum()
                                
                                let arrCurrent = strongSelf.arrPortfolio.map { $0.stock_current }
                                strongSelf.currentAmount = arrCurrent.sum()
                                
                                strongSelf.setPortfolioData()
                                
                                let arrSymbol = strongSelf.arrPortfolio.map { $0.symbol }
                                let strSymbol = arrSymbol.joined(separator: ",")
                                
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
                                
                                strongSelf.tblPortfolio.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblPortfolio.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblPortfolio)
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
    
    //TRADING ACCOUNT DETAIL
    func callTradingAccountAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.TRADING_ACCOUNT) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            GlobalData.shared.objTradingAccount = TradingAccountObject.init(payload)
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
