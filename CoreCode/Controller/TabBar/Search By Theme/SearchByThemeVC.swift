//
//  SearchByThemeVC.swift

import UIKit
import SideMenuSwift
import SwiftyJSON
import SDWebImage

class SearchByThemeVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblSearchTitle: UILabel!
    @IBOutlet weak var clViewCategory: UICollectionView!
    @IBOutlet weak var clViewCategoryHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var tblList: ContentSizedTableView!
    @IBOutlet weak var tblListHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var imgNoStock: UIImageView!
    
    var selectedIndex:Int = 0

    var arrTheme: [ThemeObject] = []
    var arrStockList: [ThemeStockObject] = []
    var arrSearchList: [ThemeStockObject] = []
    var searchActive: Bool = false
    var strCategoryID: String = ""
    var strCategoryName:String = ""
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupThemeSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        if self.searchActive {
            if self.arrSearchList.count > 0 {
                let arrSymbol = self.arrSearchList.map { $0.symbol }
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
            }
        } else {
            if self.arrStockList.count > 0 {
                let arrSymbol = self.arrStockList.map { $0.symbol }
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
            }
        }
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateThemeBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateThemeTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblListHeightConstraint.constant = self.tblList.contentSize.height
        }
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(SearchByThemeVC.getThemeBarData(notification:)), name: NSNotification.Name(kUpdateThemeBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SearchByThemeVC.getThemeTradesData(notification:)), name: NSNotification.Name(kUpdateThemeTrades), object: nil)
    }
    
    @objc func getThemeBarData(notification: Notification) {
        debugPrint("=====Getting Theme Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if self.searchActive {
                if let row = self.arrSearchList.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrSearchList[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrSearchList[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrSearchList[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrSearchList[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else {
                if let row = self.arrStockList.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrStockList[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrStockList[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrStockList[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            }
        }
    }
    
    @objc func getThemeTradesData(notification: Notification) {
        debugPrint("=====Getting Theme Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if self.searchActive {
                    if let row = self.arrSearchList.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrSearchList[row].openPrice
    //                    let closePrice = self.arrSearchList[row].closePrice
                        let closePrice = self.arrSearchList[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrSearchList[row].current_price = currentPrice
                        self.arrSearchList[row].plVariationValue = variationValue
                        self.arrSearchList[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            self.tblList.reloadSections(IndexSet(integer: row), with: .none)
                            self.tblList.reloadData()
                        }
                    }
                } else {
                    if let row = self.arrStockList.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrStockList[row].openPrice
    //                    let closePrice = self.arrStockList[row].closePrice
                        let closePrice = self.arrStockList[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrStockList[row].current_price = currentPrice
                        self.arrStockList[row].plVariationValue = variationValue
                        self.arrStockList[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            self.tblList.reloadSections(IndexSet(integer: row), with: .none)
                            self.tblList.reloadData()
                        }
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
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.txtSearch.layer.cornerRadius = self.txtSearch.frame.height / 2.0
        }
        
//        self.lblSearchTitle.textColor = UIColor.labelTextColor
        self.txtSearch.textColor = UIColor.textFieldTextColor
        self.txtSearch.backgroundColor = UIColor.searchTextfieldBG
        
        self.txtSearch.setLeftPadding()
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupThemeSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
//        self.callGetAllThemeAPI()
          self.lblTitle.text = strCategoryName
          self.callGetStockByCategoryAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
//        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
}

// MARK: - UICOLLECTIONVIEW DATASOURCE & DELEGATE METHOD -

extension SearchByThemeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrTheme.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCategoryCell", for: indexPath as IndexPath) as! ThemeCategoryCell
        
        let objData = self.arrTheme[indexPath.item]
        
        cell.imgCategory.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
        cell.imgCategory.sd_setImage(with: URL(string: objData.categoryImage), placeholderImage: nil)
        
        cell.lblTitle.text = objData.categoryName
        
        if indexPath.item == self.selectedIndex {
            cell.viewCategory.backgroundColor = UIColor.init(hex: 0x81CF01)
            cell.lblTitle.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblTitle.font.pointSize)
        } else {
            cell.viewCategory.backgroundColor = UIColor.init(hex: 0xF5F5F5)
            cell.lblTitle.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblTitle.font.pointSize)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugPrint("You selected cell #\(indexPath.item)!")
        
        if indexPath.item != self.selectedIndex {
            self.selectedIndex = indexPath.item
            self.clViewCategory.reloadData()
            
            self.searchActive = false
            self.txtSearch.text = ""
            
            self.strCategoryID = self.arrTheme[self.selectedIndex]._id
            self.strCategoryName = self.arrTheme[self.selectedIndex].categoryName
            self.callGetStockByCategoryAPI()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCategoryCell", for: indexPath as IndexPath) as! ThemeCategoryCell
        
        let titleHeight = cell.lblTitle.frame.size.height
        let totalHeight = cell.viewCategory.frame.size.height + 5 + titleHeight
        
        let noOfCellsInRow = 4
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        self.clViewCategoryHeightConstraint.constant = totalHeight
        return CGSize(width: CGFloat(size), height: totalHeight)
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension SearchByThemeVC: UITextFieldDelegate {
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
                if self.strCategoryName.lowercased() == "all" {
                    self.callSearchStockByAllCategoryAPI(SearchString: textField.text ?? "")
                } else {
                    self.callSearchStockByCategoryAPI(SearchString: textField.text ?? "")
                }
            } else {
                self.searchActive = false
                if self.arrStockList.count > 0 {
                    self.imgNoStock.isHidden = true
                } else {
                    self.imgNoStock.isHidden = false
                }
                GlobalData.shared.reloadTableView(tableView: self.tblList)
            }
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension SearchByThemeVC: UITableViewDataSource, UITableViewDelegate {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeStockCell", for: indexPath) as! ThemeStockCell
        
        var objData: ThemeStockObject!
        
        if self.searchActive {
            objData = self.arrSearchList[indexPath.section]
        } else {
            objData = self.arrStockList[indexPath.section]
        }
        
        if objData.image == "" {
            cell.viewStock.backgroundColor = UIColor.init(hex: 0x27B1FC)
            
            let dpName = objData.symbol.prefix(1)
            cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
        } else {
            cell.viewStock.backgroundColor = UIColor.white
            
            cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgStock.sd_setImage(with: URL(string: objData.image), placeholderImage: nil)
        }
        
        cell.lblStockName.text = objData.symbol
        cell.lblStockType.text = objData.exchange
        let decimalPrice = convertThousand(value: objData.current_price)
        cell.lblStockAmount.text = "$" + "\(decimalPrice)"
        if objData.symbole_description.count > 0 {
            cell.lblSymbolDescription.text = objData.symbole_description
        }
        else {
            cell.lblSymbolDescription.text = objData.companyName
        }
        
        if objData.plVariationPer > 0 {
            cell.lblStockVariation.text = "$+\(convertThousand(value: objData.plVariationValue)) (+\(String(format: "%.2f", objData.plVariationPer))%)"
        } else if objData.plVariationPer < 0 {
            cell.lblStockVariation.text = "$\(convertThousand(value: objData.plVariationValue)) (\(String(format: "%.2f", objData.plVariationPer))%)"
        } else {
            cell.lblStockVariation.text = "$\(convertThousand(value: objData.plVariationValue)) (0.00%)"
        }
        
        if objData.plVariationValue > 0 {
            cell.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
        } else if objData.plVariationValue < 0 {
            cell.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            cell.lblStockVariation.textColor = UIColor.tblMarketDepthContent
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var objData: ThemeStockObject!
        
        if self.searchActive {
            objData = self.arrSearchList[indexPath.section]
        } else {
            objData = self.arrStockList[indexPath.section]
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
}

//MARK: - API CALL -

extension SearchByThemeVC {
    //GET ALL THEME
    func callGetAllThemeAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_CATEGORY) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrTheme.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = ThemeObject.init(payloadData[i])
                                strongSelf.arrTheme.append(objData)
                            }
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewCategory)
                            
                            if strongSelf.arrTheme.count > 0 {
                                strongSelf.strCategoryID = strongSelf.arrTheme[0]._id
                                strongSelf.strCategoryName = strongSelf.arrTheme[0].categoryName
                                strongSelf.callGetStockByCategoryAPI()
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET STOCK BY THEME
    func callGetStockByCategoryAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_CATEGORY + "/" + "\(self.strCategoryID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrStockList.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = ThemeStockObject.init(payloadData[i])
                                strongSelf.arrStockList.append(objData)
                            }
                            
                            if strongSelf.arrStockList.count > 0 {
                                let arrSymbol = strongSelf.arrStockList.map { $0.symbol }
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
                                
                                strongSelf.imgNoStock.isHidden = true
                            } else {
                                strongSelf.imgNoStock.isHidden = false
                            }

                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrStockList.removeAll()
                        if strongSelf.arrStockList.count > 0 {
                            strongSelf.imgNoStock.isHidden = true
                        } else {
                            strongSelf.imgNoStock.isHidden = false
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
    
    //GET SEARCH STOCK BY THEME
    func callSearchStockByCategoryAPI(SearchString searchString: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_CATEGORY + "/" + "\(self.strCategoryID)" + "/" + "\(searchString)"
        
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
                                let objData = ThemeStockObject.init(payloadData[i])
                                strongSelf.arrSearchList.append(objData)
                            }
                            
                            if strongSelf.arrSearchList.count > 0 {
                                let arrSymbol = strongSelf.arrSearchList.map { $0.symbol }
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
                                
                                strongSelf.imgNoStock.isHidden = true
                            } else {
                                strongSelf.imgNoStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrSearchList.removeAll()
                        if strongSelf.arrSearchList.count > 0 {
                            strongSelf.imgNoStock.isHidden = true
                        } else {
                            strongSelf.imgNoStock.isHidden = false
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
    
    //GET SEARCH STOCK BY THEME FROM ALL
    func callSearchStockByAllCategoryAPI(SearchString searchString: String) {
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
                                let objData = ThemeStockObject.init(payloadData[i])
                                strongSelf.arrSearchList.append(objData)
                            }
                            
                            if strongSelf.arrSearchList.count > 0 {
                                let arrSymbol = strongSelf.arrSearchList.map { $0.symbol }
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
                                
                                strongSelf.imgNoStock.isHidden = true
                            } else {
                                strongSelf.imgNoStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrSearchList.removeAll()
                        if strongSelf.arrSearchList.count > 0 {
                            strongSelf.imgNoStock.isHidden = true
                        } else {
                            strongSelf.imgNoStock.isHidden = false
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
}
