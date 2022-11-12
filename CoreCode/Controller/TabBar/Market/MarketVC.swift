//
//  MarketVC.swift
import UIKit
import SideMenuSwift
import DropDown
import SwiftyJSON
import Charts
import SDWebImage

class MarketVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblMarketTitle: UILabel!
    
    @IBOutlet weak var lblNoStocks: UILabel!
    @IBOutlet weak var clViewStocks: UICollectionView!
    
    @IBOutlet weak var lblPopularStockTitle: UILabel!
    @IBOutlet weak var lblNoPopularStock: UILabel!
    @IBOutlet weak var clViewPopularStock: UICollectionView!
    @IBOutlet weak var clViewPopularStockHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblPopularETFTitle: UILabel!
    @IBOutlet weak var lblNoPopularETF: UILabel!
    @IBOutlet weak var clViewPopularETF: UICollectionView!
    @IBOutlet weak var clViewPopularETFHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblMostBoughtTitle: UILabel!
    @IBOutlet weak var lblNoBought: UILabel!
    @IBOutlet weak var clViewMostBought: UICollectionView!
    @IBOutlet weak var clViewMostBoughtHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblAnalystPickTitle: UILabel!
    @IBOutlet weak var lblNoAnalyst: UILabel!
    @IBOutlet weak var clViewAnalystPick: UICollectionView!
    @IBOutlet weak var clViewAnalystPickHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewDropdown: UIStackView!
    @IBOutlet weak var imgArrow: UIImageView!
    @IBOutlet weak var viewThings: UIView!
    @IBOutlet weak var lblIndustry: UILabel!
    @IBOutlet weak var btnDropdown: UIButton!
    @IBOutlet weak var tblView: ContentSizedTableView!
    @IBOutlet weak var tblViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var tblNews: ContentSizedTableView!
    @IBOutlet weak var tblNewsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var clViewCategory: UICollectionView!
    @IBOutlet weak var clViewCategoryHeightConstraint: NSLayoutConstraint!
    
    var arrStockList: [AssetsObject] = []
    var arrPopularStock: [AssetsObject] = []
    var arrPopularETF: [AssetsObject] = []
    var arrMostBought: [AssetsObject] = []
    var arrAnalyst: [AssetsObject] = []
    var arrIndustry: [String] = []
    var objNews = NewsObject.init([:])
    var arrTheme: [ThemeObject] = []
    
    var strCategoryID: String = ""
    var strCategoryName:String = ""

    
    var isIndustryAvailable:Bool = false
    var isNewsAvailable:Bool = false
    
    let inDateFormatter = ISO8601DateFormatter()
    let outDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEEE, dd MMM yyyy, HH:mm:ss"//"EEEE, dd MMM yyyy, h:mm a"//"dd-MM-yyyy"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df
    }()
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.callGetMarketStatusAPI()
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupMarketSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
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
        if self.arrPopularStock.count > 0 {
            let arrSymbol = self.arrPopularStock.map { $0.symbol }
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
        if self.arrPopularETF.count > 0 {
            let arrSymbol = self.arrPopularETF.map { $0.symbol }
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
        if self.arrMostBought.count > 0 {
            let arrSymbol = self.arrMostBought.map { $0.symbol }
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
        if self.arrAnalyst.count > 0 {
            let arrSymbol = self.arrAnalyst.map { $0.symbol }
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
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateMarketBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateMarketTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblViewHeightConstraint.constant = self.tblView.contentSize.height
            self.tblNewsHeightConstraint.constant = self.tblNews.contentSize.height
        }
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(MarketVC.getMarketBarData(notification:)), name: NSNotification.Name(kUpdateMarketBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MarketVC.getMarketTradesData(notification:)), name: NSNotification.Name(kUpdateMarketTrades), object: nil)
    }
    
    @objc func getMarketBarData(notification: Notification) {
        debugPrint("=====Getting Market Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if self.arrStockList.contains(where: { $0.symbol == symbol}) {
                if let row = self.arrStockList.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrStockList[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrStockList[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrStockList[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrStockList[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else if self.arrPopularStock.contains(where: { $0.symbol == symbol}) {
                if let row = self.arrPopularStock.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrPopularStock[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrPopularStock[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularStock[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularStock[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularStock[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrPopularStock[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else if self.arrPopularETF.contains(where: { $0.symbol == symbol}) {
                if let row = self.arrPopularETF.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrPopularETF[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrPopularETF[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularETF[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularETF[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrPopularETF[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrPopularETF[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else if self.arrMostBought.contains(where: { $0.symbol == symbol}) {
                if let row = self.arrMostBought.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrMostBought[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrMostBought[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrMostBought[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrMostBought[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrMostBought[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrMostBought[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else if self.arrAnalyst.contains(where: { $0.symbol == symbol}) {
                if let row = self.arrAnalyst.firstIndex(where: {$0.symbol == symbol}) {
                    self.arrAnalyst[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.arrAnalyst[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.arrAnalyst[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.arrAnalyst[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.arrAnalyst[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.arrAnalyst[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            }
        }
    }
    
    @objc func getMarketTradesData(notification: Notification) {
        debugPrint("=====Getting Market Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if self.arrStockList.contains(where: { $0.symbol == symbol }) {
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
//                            let indexPath = IndexPath(item: row, section: 0)
//                            self.clViewStocks.reloadItems(at: [indexPath])
                            self.clViewStocks.reloadData()
    //                        self.clViewStocks.reloadItems(at: [IndexPath(item: row, section: 0)])
                        }
                    }
                } else if self.arrPopularStock.contains(where: { $0.symbol == symbol }) {
                    if let row = self.arrPopularStock.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrPopularStock[row].openPrice
    //                    let closePrice = self.arrPopularStock[row].closePrice
                        let closePrice = self.arrPopularStock[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrPopularStock[row].current_price = currentPrice
                        self.arrPopularStock[row].plVariationValue = variationValue
                        self.arrPopularStock[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            let indexPath = IndexPath(item: row, section: 0)
//                            self.clViewPopularStock.reloadItems(at: [indexPath])
                            self.clViewPopularStock.reloadData()
    //                        self.clViewPopularStock.reloadItems(at: [IndexPath(item: row, section: 0)])
                        }
                    }
                } else if self.arrPopularETF.contains(where: { $0.symbol == symbol }) {
                    if let row = self.arrPopularETF.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrPopularETF[row].openPrice
    //                    let closePrice = self.arrPopularETF[row].closePrice
                        let closePrice = self.arrPopularETF[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrPopularETF[row].current_price = currentPrice
                        self.arrPopularETF[row].plVariationValue = variationValue
                        self.arrPopularETF[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            let indexPath = IndexPath(item: row, section: 0)
//                            self.clViewPopularETF.reloadItems(at: [indexPath])
                            self.clViewPopularETF.reloadData()
    //                        self.clViewPopularETF.reloadItems(at: [IndexPath(item: row, section: 0)])
                        }
                    }
                } else if self.arrMostBought.contains(where: { $0.symbol == symbol }) {
                    if let row = self.arrMostBought.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrMostBought[row].openPrice
    //                    let closePrice = self.arrMostBought[row].closePrice
                        let closePrice = self.arrMostBought[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrMostBought[row].current_price = currentPrice
                        self.arrMostBought[row].plVariationValue = variationValue
                        self.arrMostBought[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            let indexPath = IndexPath(item: row, section: 0)
//                            self.clViewMostBought.reloadItems(at: [indexPath])
                            self.clViewMostBought.reloadData()
    //                        self.clViewMostBought.reloadItems(at: [IndexPath(item: row, section: 0)])
                        }
                    }
                } else if self.arrAnalyst.contains(where: { $0.symbol == symbol }) {
                    if let row = self.arrAnalyst.firstIndex(where: {$0.symbol == symbol}) {
                        let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        let openPrice = self.arrAnalyst[row].openPrice
    //                    let closePrice = self.arrAnalyst[row].closePrice
                        let closePrice = self.arrAnalyst[row].prev_close_price
                        let variationValue = currentPrice - closePrice //currentPrice - openPrice
                        let variationPer = (variationValue * 100) / closePrice
                        
                        self.arrAnalyst[row].current_price = currentPrice
                        self.arrAnalyst[row].plVariationValue = variationValue
                        self.arrAnalyst[row].plVariationPer = variationPer
                        
                        DispatchQueue.main.async {
//                            let indexPath = IndexPath(item: row, section: 0)
//                            self.clViewAnalystPick.reloadItems(at: [indexPath])
                            self.clViewAnalystPick.reloadData()
    //                        self.clViewAnalystPick.reloadItems(at: [IndexPath(item: row, section: 0)])
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
        }
        
        self.lblMarketTitle.textColor = UIColor.labelTextColor
        
        self.lblPopularStockTitle.textColor = UIColor.labelTextColor
        self.lblPopularETFTitle.textColor = UIColor.labelTextColor
        self.lblMostBoughtTitle.textColor = UIColor.labelTextColor
        self.lblAnalystPickTitle.textColor = UIColor.labelTextColor
        
        self.lblNoStocks.textColor = UIColor.labelTextColor
        self.lblNoPopularStock.textColor = UIColor.labelTextColor
        self.lblNoPopularETF.textColor = UIColor.labelTextColor
        self.lblNoBought.textColor = UIColor.labelTextColor
        self.lblNoAnalyst.textColor = UIColor.labelTextColor
        
        self.viewThings.isHidden = true
        
        self.tblView.showsVerticalScrollIndicator = false
        self.tblView.tableFooterView = UIView()
        
        self.lblNewsTitle.textColor = UIColor.labelTextColor
        
        self.tblNews.showsVerticalScrollIndicator = false
        self.tblNews.tableFooterView = UIView()
        
        self.lblNoStocks.isHidden = true
        self.lblNoPopularStock.isHidden = true
        self.lblNoPopularETF.isHidden = true
        self.lblNoBought.isHidden = true
        self.lblNoAnalyst.isHidden = true
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupMarketSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
        self.callGetDefaultListAPI()
        self.callGetPopularStockAPI()
        self.callGetPopularETFAPI()
        self.callGetMostBoughtAPI()
        self.callGetAnalystPickAPI()
        self.callGetIndustryTypeAPI()
        self.callGetAllThemeAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnDropdownClick(_ sender: UIButton) {
        self.btnDropdown.isSelected = !self.btnDropdown.isSelected
        
        if self.btnDropdown.isSelected {
            self.imgArrow.image = UIImage.init(named: "ic_up_arrow")
            self.viewThings.isHidden = false
        } else {
            self.imgArrow.image = UIImage.init(named: "ic_down_arrow")
            self.viewThings.isHidden = true
        }
    }
}

// MARK: - UICOLLECTIONVIEW DATASOURCE & DELEGATE METHOD -

extension MarketVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.clViewStocks {
            return self.arrStockList.count
        }
        else if collectionView == self.clViewPopularStock {
            return self.arrPopularStock.count
        }
        else if collectionView == self.clViewPopularETF {
            return self.arrPopularETF.count
        }
        else if collectionView == self.clViewMostBought {
            return self.arrMostBought.count
        }
        
        else if collectionView == self.clViewCategory {
            return self.arrTheme.count
        }
        else {
            return self.arrAnalyst.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.clViewStocks {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketStockCell", for: indexPath as IndexPath) as! MarketStockCell
            
            let objDict = self.arrStockList[indexPath.item]
            
            if objDict.image == "" {
                let dpName = objDict.symbol.prefix(1)
                cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
            } else {
                cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
            }
            
            cell.lblStockName.text = objDict.symbol
            
            if objDict.plVariationPer > 0 {
                cell.lblPrice.text = "+\(String(format: "%.2f", objDict.plVariationPer))%" //"+\(String(format: "%.2f", objDict.current_price)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblPrice.text = "\(String(format: "%.2f", objDict.plVariationPer))%" //"\(String(format: "%.2f", objDict.current_price)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblPrice.text = "0.00%" //"\(String(format: "%.2f", objDict.current_price)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.viewPriceBG.backgroundColor = UIColor.init(hex: 0x81CF01)
            } else if objDict.plVariationValue < 0 {
                cell.viewPriceBG.backgroundColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.viewPriceBG.backgroundColor = UIColor.init(hex: 0x27B1FC)
            }
            
            return cell
        }
        else if collectionView == self.clViewPopularStock {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalystPickCell", for: indexPath as IndexPath) as! AnalystPickCell
            
            let objDict = self.arrPopularStock[indexPath.item]
            
            if objDict.image == "" {
                let dpName = objDict.symbol.prefix(1)
                cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
            } else {
                cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
            }
            
            cell.lblStockName.text = objDict.symbol
            
            if objDict.plVariationPer > 0 {
                cell.lblPrice.text = "+\(String(format: "%.2f", objDict.plVariationPer))%" //"+\(String(format: "%.2f", objDict.current_price)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblPrice.text = "\(String(format: "%.2f", objDict.plVariationPer))%" //"\(String(format: "%.2f", objDict.current_price)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblPrice.text = "0.00%" //"\(String(format: "%.2f", objDict.current_price)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0x81CF01)
            } else if objDict.plVariationValue < 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.lblPrice.textColor = UIColor.init(hex: 0x27B1FC)
            }
            
                if indexPath.row == arrPopularStock.count - 1 || indexPath.row != 1 && (indexPath.row + 1) % 3 == 0  {
                    cell.viewBottom.isHidden = true
                }
                
                else {
                    cell.viewBottom.isHidden = false
                }
            return cell
        }
        else if collectionView == self.clViewPopularETF {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalystPickCell", for: indexPath as IndexPath) as! AnalystPickCell
            
            let objDict = self.arrPopularETF[indexPath.item]
            
            if objDict.image == "" {
                let dpName = objDict.symbol.prefix(1)
                cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
            } else {
                cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
            }
            
            cell.lblStockName.text = objDict.symbol
            
            if objDict.plVariationPer > 0 {
                cell.lblPrice.text = "+\(String(format: "%.2f", objDict.plVariationPer))%" //"+\(String(format: "%.2f", objDict.current_price)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblPrice.text = "\(String(format: "%.2f", objDict.plVariationPer))%" //"\(String(format: "%.2f", objDict.current_price)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblPrice.text = "0.00%" //"\(String(format: "%.2f", objDict.current_price)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0x81CF01)
            } else if objDict.plVariationValue < 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.lblPrice.textColor = UIColor.init(hex: 0x27B1FC)
            }
//
                if indexPath.row == arrPopularETF.count - 1 || indexPath.row != 1 && (indexPath.row + 1) % 3 == 0  {
                    cell.viewBottom.isHidden = true
                }
                
                else {
                    cell.viewBottom.isHidden = false
                }
                                    
            return cell
        }
        else if collectionView == self.clViewMostBought {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalystPickCell", for: indexPath as IndexPath) as! AnalystPickCell
            
            let objDict = self.arrMostBought[indexPath.item]
            
            if objDict.image == "" {
                let dpName = objDict.symbol.prefix(1)
                cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
            } else {
                cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
            }
            
            cell.lblStockName.text = objDict.symbol
            
            if objDict.plVariationPer > 0 {
                cell.lblPrice.text = "+\(String(format: "%.2f", objDict.plVariationPer))%" //"+\(String(format: "%.2f", objDict.current_price)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblPrice.text = "\(String(format: "%.2f", objDict.plVariationPer))%" //"\(String(format: "%.2f", objDict.current_price)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblPrice.text = "0.00%" //"\(String(format: "%.2f", objDict.current_price)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0x81CF01)
            } else if objDict.plVariationValue < 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.lblPrice.textColor = UIColor.init(hex: 0x27B1FC)
            }
            
            if indexPath.row == arrMostBought.count - 1 || indexPath.row != 1 && (indexPath.row + 1) % 3 == 0  {
                cell.viewBottom.isHidden = true
            }
            
            else {
                cell.viewBottom.isHidden = false
            }
                        
            return cell
        }
        else if collectionView == self.clViewCategory {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeCategoryCell", for: indexPath as IndexPath) as! ThemeCategoryCell
            
            let objData = self.arrTheme[indexPath.item]
            
            cell.imgCategory.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
            cell.imgCategory.sd_setImage(with: URL(string: objData.categoryImage), placeholderImage: nil)
            
            cell.lblTitle.text = objData.categoryName
            return cell

        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnalystPickCell", for: indexPath as IndexPath) as! AnalystPickCell
            
            let objDict = self.arrAnalyst[indexPath.item]
            
            if objDict.image == "" {
                let dpName = objDict.symbol.prefix(1)
                cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
            } else {
                cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
            }
            
            cell.lblStockName.text = objDict.symbol
            
            if objDict.plVariationPer > 0 {
                cell.lblPrice.text = "+\(String(format: "%.2f", objDict.plVariationPer))%" //"+\(String(format: "%.2f", objDict.current_price)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else if objDict.plVariationPer < 0 {
                cell.lblPrice.text = "\(String(format: "%.2f", objDict.plVariationPer))%" //"\(String(format: "%.2f", objDict.current_price)) (\(String(format: "%.2f", objDict.plVariationPer))%)"
            } else {
                cell.lblPrice.text = "0.00%" //"\(String(format: "%.2f", objDict.current_price)) (0.00%)"
            }
            
            if objDict.plVariationValue > 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0x81CF01)
            } else if objDict.plVariationValue < 0 {
                cell.lblPrice.textColor = UIColor.init(hex: 0xFE3D2F)
            } else {
                cell.lblPrice.textColor = UIColor.init(hex: 0x27B1FC)
            }
            
            if indexPath.row == arrAnalyst.count - 1 || indexPath.row != 1 && (indexPath.row + 1) % 3 == 0  {
                cell.viewBottom.isHidden = true
            }
            
            else {
                cell.viewBottom.isHidden = false
            }
                        
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.clViewStocks {
            let objDict = self.arrStockList[indexPath.item]
            
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
            controller.strSymbol = objDict.symbol
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if collectionView == self.clViewPopularStock {
            let objDict = self.arrPopularStock[indexPath.item]
            
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
            controller.strSymbol = objDict.symbol
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if collectionView == self.clViewPopularETF {
            let objDict = self.arrPopularETF[indexPath.item]
            
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
            controller.strSymbol = objDict.symbol
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if collectionView == self.clViewMostBought {
            let objDict = self.arrMostBought[indexPath.item]
            
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
            controller.strSymbol = objDict.symbol
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if collectionView == self.clViewCategory {
            let objDict = self.arrTheme[indexPath.item]
            let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "SearchByThemeVC") as! SearchByThemeVC
            controller.strCategoryID = objDict._id
            controller.strCategoryName = objDict.categoryName
            self.navigationController?.pushViewController(controller, animated: true)

        }
        else {
            let objDict = self.arrAnalyst[indexPath.item]
            
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
            controller.strSymbol = objDict.symbol
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == self.clViewStocks {
            /*
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MarketStockCell", for: indexPath as IndexPath) as! MarketStockCell
            
//            var stockNameHeight: CGFloat = 0.0
//            let lblStockName = UILabel(frame: CGRect.zero)
//            lblStockName.text = cell.lblStockName.text
//            lblStockName.sizeToFit()
//            stockNameHeight = lblStockName.frame.size.height
            
            let stockNameHeight = cell.lblStockName.frame.size.height
            let viewPriceHeight = cell.viewPriceBG.frame.size.height
            let totalHeight = cell.imgStock.frame.size.height + 8 + stockNameHeight + 8 + viewPriceHeight + 20
            
            let noOfCellsInRow = 3
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            
//            return CGSize(width: size, height: 230)
            return CGSize(width: CGFloat(size), height: totalHeight)
            */
            
            let noOfCellsInRow = 3
            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
            let totalSpace = flowLayout.sectionInset.left
                + flowLayout.sectionInset.right
                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
            
            return CGSize(width: size, height: 180)
        }
        else if collectionView == self.clViewPopularStock {
                        
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height / 4)
            
//            let noOfCellsInRow = 3
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//
//            if Constants.DeviceType.IS_IPHONE_5 {
//                self.clViewPopularStockHeightConstraint.constant = 130
//                return CGSize(width: size, height: 130)
//            } else if Constants.DeviceType.IS_IPHONE_6P {
//                self.clViewPopularStockHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_X {
//                self.clViewPopularStockHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
//                self.clViewPopularStockHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO {
//                self.clViewPopularStockHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
//                self.clViewPopularStockHeightConstraint.constant = 150
//                return CGSize(width: size, height: 150)
//            } else {
//                self.clViewPopularStockHeightConstraint.constant = 135
//                return CGSize(width: size, height: 135)
//            }
        }
        else if collectionView == self.clViewPopularETF {
            
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height / 4)

//            let noOfCellsInRow = 3
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//
//            if Constants.DeviceType.IS_IPHONE_5 {
//                self.clViewPopularETFHeightConstraint.constant = 130
//                return CGSize(width: size, height: 130)
//            } else if Constants.DeviceType.IS_IPHONE_6P {
//                self.clViewPopularETFHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_X {
//                self.clViewPopularETFHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
//                self.clViewPopularETFHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO {
//                self.clViewPopularETFHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
//                self.clViewPopularETFHeightConstraint.constant = 150
//                return CGSize(width: size, height: 150)
//            } else {
//                self.clViewPopularETFHeightConstraint.constant = 135
//                return CGSize(width: size, height: 135)
//            }
        }
        else if collectionView == self.clViewMostBought {
            
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height / 4)

//            let noOfCellsInRow = 3
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//
//            if Constants.DeviceType.IS_IPHONE_5 {
//                self.clViewMostBoughtHeightConstraint.constant = 130
//                return CGSize(width: size, height: 130)
//            } else if Constants.DeviceType.IS_IPHONE_6P {
//                self.clViewMostBoughtHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_X {
//                self.clViewMostBoughtHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
//                self.clViewMostBoughtHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO {
//                self.clViewMostBoughtHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
//                self.clViewMostBoughtHeightConstraint.constant = 150
//                return CGSize(width: size, height: 150)
//            } else {
//                self.clViewMostBoughtHeightConstraint.constant = 135
//                return CGSize(width: size, height: 135)
//            }
        }
        
        else if collectionView == clViewCategory {
            
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
        else {
            
            return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height / 4)

//            let noOfCellsInRow = 3
//            let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
//            let totalSpace = flowLayout.sectionInset.left
//                + flowLayout.sectionInset.right
//                + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
//
//            let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
//
//            if Constants.DeviceType.IS_IPHONE_5 {
//                self.clViewAnalystPickHeightConstraint.constant = 130
//                return CGSize(width: size, height: 130)
//            } else if Constants.DeviceType.IS_IPHONE_6P {
//                self.clViewAnalystPickHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_X {
//                self.clViewAnalystPickHeightConstraint.constant = 140
//                return CGSize(width: size, height: 140)
//            } else if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
//                self.clViewAnalystPickHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO {
//                self.clViewAnalystPickHeightConstraint.constant = 145
//                return CGSize(width: size, height: 145)
//            } else if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
//                self.clViewAnalystPickHeightConstraint.constant = 150
//                return CGSize(width: size, height: 150)
//            } else {
//                self.clViewAnalystPickHeightConstraint.constant = 135
//                return CGSize(width: size, height: 135)
//            }
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension MarketVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tblView {
            if self.isIndustryAvailable {
                return self.arrIndustry.count
            } else {
                return 1
            }
        } else {
            if self.isNewsAvailable {
                return self.objNews.arrNews.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblView {
            if self.isIndustryAvailable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThingsCell", for: indexPath) as! ThingsCell
                
                cell.lblTitle.text = self.arrIndustry[indexPath.section]
                
                return cell
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                if (cell == nil) {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                
                cell?.textLabel?.text = "No industry found"
                cell?.textLabel?.textAlignment = .center
                
                return cell!
            }
        } else {
            if self.isNewsAvailable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
                
                let objDict = self.objNews.arrNews[indexPath.section]
                let date = objDict.published_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd, hh:mm a")
                let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd, hh:mm a", OutputFormat: "MMM dd, yyyy hh:mm a")
                                
                cell.imgNews.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell.imgNews.sd_setImage(with: URL(string: objDict.image_url), placeholderImage: nil)
                
                cell.lblTitle.text = objDict.title
                cell.lblDescription.text = objDict.description_news
                cell.lblDate.text = finalDate
                
                cell.selectionStyle = .none
                return cell
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                if (cell == nil) {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                
                cell?.textLabel?.text = "No news found"
                cell?.textLabel?.textAlignment = .center
                
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.tblView {
            if self.isIndustryAvailable {
                self.btnDropdown.isSelected = false
                self.imgArrow.image = UIImage.init(named: "ic_down_arrow")
                self.viewThings.isHidden = true
                
                self.lblIndustry.text = self.arrIndustry[indexPath.section]
                
                self.callGetNewsByIndustryAPI(IndustryType: self.arrIndustry[indexPath.section])
            }
        } else {
            if self.isNewsAvailable {
                let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                controller.isFrom = "News"
                controller.objNews = self.objNews.arrNews[indexPath.section]
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tblView {
            return 50
        } else {
            if self.isNewsAvailable {
                return 130
            } else {
                return 50
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension MarketVC {
    //GET MARKET STATUS
    func callGetMarketStatusAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_MARKET_STATUS) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            let nextOpen = "\(payloadData["next_open"] ?? "")"
                            let nextClose = "\(payloadData["next_close"] ?? "")"
                           
                            let openDate = strongSelf.inDateFormatter.date(from: nextOpen)
                            let closeDate = strongSelf.inDateFormatter.date(from: nextClose)
                            
                            let finalOpenDate = strongSelf.outDateFormatter.string(from: openDate!)
                            let finalCloseDate = strongSelf.outDateFormatter.string(from: closeDate!)
                            
                            debugPrint(finalOpenDate)
                            debugPrint(finalCloseDate)
                            
                            let today = GlobalData.shared.convertDateToString(Date: Date(), DateFormat: "EEEE, dd MMM yyyy, HH:mm:ss")
                            debugPrint(today)
                            
                            let tempToday = GlobalData.shared.convertStringToDate(StrDate: today, DateFormat: "EEEE, dd MMM yyyy, HH:mm:ss")
                            let tempOpen = GlobalData.shared.convertStringToDate(StrDate: finalOpenDate, DateFormat: "EEEE, dd MMM yyyy, HH:mm:ss")
                                                        
                            let formatter = DateComponentsFormatter()
                            formatter.allowedUnits = [.hour, .minute, .second]
                            debugPrint(formatter.string(from: tempToday, to: tempOpen)!)
                            
                            let difference = Calendar.current.dateComponents([.hour, .minute, .second], from: tempToday, to: tempOpen)
                            let formattedString = String(format: "%02ld:%02ld:%02ld", difference.hour!, difference.minute!, difference.second!)
                            debugPrint(formattedString)
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
                                
                                strongSelf.lblNoStocks.isHidden = true
                            } else {
                                strongSelf.lblNoStocks.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewStocks)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrStockList.removeAll()
                        if strongSelf.arrStockList.count > 0 {
                            strongSelf.lblNoStocks.isHidden = true
                        } else {
                            strongSelf.lblNoStocks.isHidden = false
                        }
                        
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewStocks)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET POPULAR STOCK LIST
    func callGetPopularStockAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_POPULAR_STOCK) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrPopularStock.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrPopularStock.append(objData)
                            }
                            
                            if strongSelf.arrPopularStock.count > 0 {
                                let arrSymbol = strongSelf.arrPopularStock.map { $0.symbol }
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
                                
                                strongSelf.lblNoPopularStock.isHidden = true
                            } else {
                                strongSelf.lblNoPopularStock.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewPopularStock)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrPopularStock.removeAll()
                        if strongSelf.arrPopularStock.count > 0 {
                            strongSelf.lblNoPopularStock.isHidden = true
                        } else {
                            strongSelf.lblNoPopularStock.isHidden = false
                        }
                        
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewPopularStock)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET POPULAR ETFS LIST
    func callGetPopularETFAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_POPULAR_ETFS) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrPopularETF.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrPopularETF.append(objData)
                            }
                            
                            if strongSelf.arrPopularETF.count > 0 {
                                let arrSymbol = strongSelf.arrPopularETF.map { $0.symbol }
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
                                
                                strongSelf.lblNoPopularETF.isHidden = true
                            } else {
                                strongSelf.lblNoPopularETF.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewPopularETF)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrPopularETF.removeAll()
                        if strongSelf.arrPopularETF.count > 0 {
                            strongSelf.lblNoPopularETF.isHidden = true
                        } else {
                            strongSelf.lblNoPopularETF.isHidden = false
                        }
                        
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewPopularETF)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET MOST BOUGHT LIST
    func callGetMostBoughtAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_MOST_BOUGHT) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrMostBought.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrMostBought.append(objData)
                            }
                            
                            if strongSelf.arrMostBought.count > 0 {
                                let arrSymbol = strongSelf.arrMostBought.map { $0.symbol }
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
                                
                                strongSelf.lblNoBought.isHidden = true
                            } else {
                                strongSelf.lblNoBought.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewMostBought)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrMostBought.removeAll()
                        if strongSelf.arrMostBought.count > 0 {
                            strongSelf.lblNoBought.isHidden = true
                        } else {
                            strongSelf.lblNoBought.isHidden = false
                        }
                        
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewMostBought)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET ANALYST PICK LIST
    func callGetAnalystPickAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_ANALYST_PICK) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrAnalyst.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = AssetsObject.init(payloadData[i])
                                strongSelf.arrAnalyst.append(objData)
                            }
                            
                            if strongSelf.arrAnalyst.count > 0 {
                                let arrSymbol = strongSelf.arrAnalyst.map { $0.symbol }
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
                                
                                strongSelf.lblNoAnalyst.isHidden = true
                            } else {
                                strongSelf.lblNoAnalyst.isHidden = false
                            }
                            
                            GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewAnalystPick)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrAnalyst.removeAll()
                        if strongSelf.arrAnalyst.count > 0 {
                            strongSelf.lblNoAnalyst.isHidden = true
                        } else {
                            strongSelf.lblNoAnalyst.isHidden = false
                        }
                        
                        GlobalData.shared.reloadCollectionView(collectionView: strongSelf.clViewAnalystPick)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET INDUSTRY TYPE LIST
    func callGetIndustryTypeAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }

        let params: [String:Any] = [:]

        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)

        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_INDUSTRY_TYPE, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }

            GlobalData.shared.hideProgress()

            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [String] {
                            strongSelf.arrIndustry = payloadData
                            
                            if strongSelf.arrIndustry.count > 0 {
                                strongSelf.isIndustryAvailable = true
                                strongSelf.lblIndustry.text = strongSelf.arrIndustry[0]
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblView)
                                
                                strongSelf.callGetNewsByIndustryAPI(IndustryType: strongSelf.arrIndustry[0])
                            } else {
                                strongSelf.isIndustryAvailable = false
                                strongSelf.isNewsAvailable = false
                                
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblView)
                                GlobalData.shared.reloadTableView(tableView: strongSelf.tblNews)
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
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET NEWS BY INDUSTRY
    func callGetNewsByIndustryAPI(IndustryType industryType: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["industry"] = industryType
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_NEWS_INDUSTRY, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objNews = NewsObject.init(payloadData)
                            
                            if strongSelf.objNews.arrNews.count > 0 {
                                strongSelf.isNewsAvailable = true
                            } else {
                                strongSelf.isNewsAvailable = false
                            }
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblNews)
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
                            
//                            if strongSelf.arrTheme.count > 0 {
//                                strongSelf.strCategoryID = strongSelf.arrTheme[0]._id
//                                strongSelf.strCategoryName = strongSelf.arrTheme[0].categoryName
//                                strongSelf.callGetStockByCategoryAPI()
//                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
//                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
