//
//  FractionalShareVC.swift

import UIKit
import SwiftyJSON

class FractionalShareVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var objScroll: UIScrollView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblBalance: UILabel!
    @IBOutlet weak var lblShareCountTitle: UILabel!
    @IBOutlet weak var lblShareCountValue: UILabel!
    @IBOutlet weak var lblMarketPriceTitle: UILabel!
    @IBOutlet weak var lblMarketPriceValue: UILabel!
    @IBOutlet weak var lblCostTitle: UILabel!
    @IBOutlet weak var lblCostValue: UILabel!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var viewPopupSuccess: UIView!
    @IBOutlet weak var lblSuccess: UILabel!
    
    var isFromPortfolio:Bool = false
    var isFromBuy:Bool = false
    var strAmount: String = ""
    var objPortfolio: PortfolioObject!
    var objStockDetail = AssetsObject.init([:])
    
    var arrHoldingList: [PortfolioObject] = []
    
    var isFromEdit:Bool = false
    var objOrderDetail = OrderObject.init([:])
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        if self.isFromPortfolio {
            SocketIOManager.shared.setupSocket()
            SocketIOManager.shared.setupPortfolioSocketEvents()
            SocketIOManager.shared.socket?.connect()
            
            var objBars = Dictionary<String,AnyObject>()
            objBars["symbol"] = self.objPortfolio.symbol as AnyObject
            objBars["type"] = EMIT_TYPE_BARS as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var objTrades = Dictionary<String,AnyObject>()
                objTrades["symbol"] = self.objPortfolio.symbol as AnyObject
                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
            }
            
            self.SetupAllPortfolioSocketNotification()
        } else {
            SocketIOManager.shared.setupSocket()
            SocketIOManager.shared.setupBuySellFractionalSocketEvents()
            SocketIOManager.shared.socket?.connect()
            
            var objBars = Dictionary<String,AnyObject>()
            objBars["symbol"] = self.objStockDetail.symbol as AnyObject
            objBars["type"] = EMIT_TYPE_BARS as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var objTrades = Dictionary<String,AnyObject>()
                objTrades["symbol"] = self.objStockDetail.symbol as AnyObject
                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
            }
            
            self.SetupAllBuySellSocketNotification()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllPortfolioSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(FractionalShareVC.getPortfolioBarData(notification:)), name: NSNotification.Name(kUpdatePortfolioBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FractionalShareVC.getPortfolioTradesData(notification:)), name: NSNotification.Name(kUpdatePortfolioTrades), object: nil)
    }
    
    func SetupAllBuySellSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(FractionalShareVC.getBuySellFractionalBarData(notification:)), name: NSNotification.Name(kUpdateBuySellFractionalBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(FractionalShareVC.getBuySellFractionalTradesData(notification:)), name: NSNotification.Name(kUpdateBuySellFractionalTrades), object: nil)
    }
    
    //PORTFOLIO
    @objc func getPortfolioBarData(notification: Notification) {
        debugPrint("=====Getting Portfolio Sell Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if symbol == self.objPortfolio.symbol {
                self.objPortfolio.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                self.objPortfolio.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.objPortfolio.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.objPortfolio.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.objPortfolio.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.objPortfolio.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getPortfolioTradesData(notification: Notification) {
        debugPrint("=====Getting Portfolio Sell Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objPortfolio.symbol {
                    let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    let openPrice = self.objPortfolio.openPrice
                    let closePrice = self.objPortfolio.closePrice
                    let variationValue = currentPrice - closePrice //currentPrice - openPrice
                    let variationPer = (variationValue * 100) / closePrice
                    
                    self.objPortfolio.lastday_price = "\(currentPrice)"
                    self.objPortfolio.plVariationValue = variationValue
                    self.objPortfolio.plVariationPer = variationPer
                    self.objPortfolio.stock_current = currentPrice
                    
                    let marketPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
                    let amount = (self.strAmount as NSString).doubleValue
                    let shareCount = (amount/marketPrice)
                                    
                    DispatchQueue.main.async {
                        if self.isFromBuy {
                            self.lblShareCountValue.text = "\(String(format: "%.5f", shareCount)) Shares"
                            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
                            self.lblCostValue.text = "$" + self.strAmount
                        } else {
                            let qty = (self.objPortfolio.qty as NSString).doubleValue
                            let current = qty * marketPrice
                            
                            self.lblBalance.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "$" + "\(String(format: "%.2f", current))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblBalance.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: "available", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblBalance.font.pointSize - 4)!, strSecondColor: UIColor.tblStatementContent)
                            
                            self.lblShareCountValue.text = (String(format: "%.5f", shareCount))
                            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
                            self.lblCostValue.text = "$" + self.strAmount
                        }
                    }
                }
            }
        }
    }
    
    //BUY/SELL FRACTIONAL
    @objc func getBuySellFractionalBarData(notification: Notification) {
        debugPrint("=====Getting Fractional Share Sell Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if symbol == self.objStockDetail.symbol {
                self.objStockDetail.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.objStockDetail.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getBuySellFractionalTradesData(notification: Notification) {
        debugPrint("=====Getting Fractional Share Sell Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objStockDetail.symbol {
                    self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.plVariationValue = self.objStockDetail.current_price - self.objStockDetail.closePrice //self.objStockDetail.current_price - self.objStockDetail.openPrice
                    self.objStockDetail.plVariationPer = (self.objStockDetail.plVariationValue * 100) / self.objStockDetail.closePrice
                    
                    let marketPrice = self.objStockDetail.current_price
                    let amount = (self.strAmount as NSString).doubleValue
                    let shareCount = (amount/marketPrice)
                                    
                    DispatchQueue.main.async {
                        if self.isFromBuy {
                            self.lblShareCountValue.text = "\(String(format: "%.5f", shareCount)) Shares"
                            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
                            self.lblCostValue.text = "$" + self.strAmount
                        } else {
                            var current: Double = 0.0
                            
                            if let objPort = self.arrHoldingList.filter({ $0.symbol == self.objStockDetail.symbol}).first {
                                let qty = (objPort.qty as NSString).doubleValue
                                current = qty * marketPrice
                            } else {
                                current = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
                            }
                            
                            self.lblBalance.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "$" + "\(String(format: "%.2f", current))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblBalance.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: "available", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblBalance.font.pointSize - 4)!, strSecondColor: UIColor.tblStatementContent)
                            
                            self.lblShareCountValue.text = (String(format: "%.5f", shareCount))
                            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
                            self.lblCostValue.text = "$" + self.strAmount
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
            
            self.objScroll.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
            self.objScroll.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.btnSubmit.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblStockName.textColor = UIColor.labelTextColor
        self.lblShareCountTitle.textColor = UIColor.labelTextColor
        self.lblShareCountValue.textColor = UIColor.labelTextColor
        self.lblMarketPriceTitle.textColor = UIColor.labelTextColor
        self.lblMarketPriceValue.textColor = UIColor.labelTextColor
        self.lblCostTitle.textColor = UIColor.labelTextColor
        self.lblCostValue.textColor = UIColor.labelTextColor
        
        var marketPrice: Double = 0.0
        var amount: Double = 0.0
        var shareCount: Double = 0.0
        
        if self.isFromPortfolio {
//            SocketIOManager.shared.setupSocket()
//            SocketIOManager.shared.setupPortfolioSocketEvents()
//            SocketIOManager.shared.socket?.connect()
//
//            var objBars = Dictionary<String,AnyObject>()
//            objBars["symbol"] = self.objPortfolio.symbol as AnyObject
//            objBars["type"] = EMIT_TYPE_BARS as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                var objTrades = Dictionary<String,AnyObject>()
//                objTrades["symbol"] = self.objPortfolio.symbol as AnyObject
//                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//            }
            
            marketPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
            amount = (self.strAmount as NSString).doubleValue
            shareCount = (amount/marketPrice)
        } else {
//            SocketIOManager.shared.setupSocket()
//            SocketIOManager.shared.setupBuySellFractionalSocketEvents()
//            SocketIOManager.shared.socket?.connect()
//
//            var objBars = Dictionary<String,AnyObject>()
//            objBars["symbol"] = self.objStockDetail.symbol as AnyObject
//            objBars["type"] = EMIT_TYPE_BARS as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                var objTrades = Dictionary<String,AnyObject>()
//                objTrades["symbol"] = self.objStockDetail.symbol as AnyObject
//                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//            }
            
            marketPrice = self.objStockDetail.current_price
            amount = (self.strAmount as NSString).doubleValue
            shareCount = (amount/marketPrice)
        }
        
        if self.isFromBuy {
            self.lblShareCountTitle.text = "Number Of Shares"
            self.lblMarketPriceTitle.text = "Market Price"
            self.lblCostTitle.text = "Estimated Cost"
            
            //SET DATA
            self.lblStockName.text = "Buy \(self.objStockDetail.symbol)"
            self.lblBalance.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "$" + GlobalData.shared.objTradingAccount.buying_power + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblBalance.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: "available", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblBalance.font.pointSize - 4)!, strSecondColor: UIColor.tblStatementContent)
                        
            self.lblShareCountValue.text = "\(String(format: "%.5f", shareCount)) Shares"
            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
            self.lblCostValue.text = "$" + self.strAmount
        } else {
            self.lblShareCountTitle.text = "Shares of F"
            self.lblMarketPriceTitle.text = "Market Price"
            self.lblCostTitle.text = "Estimated Credit"
            
            var current: Double = 0.0
            
            //SET DATA
            if self.isFromPortfolio {
                let qty = (self.objPortfolio.qty as NSString).doubleValue
                let lastDayPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
                current = qty * lastDayPrice
            } else {
                if let objPort = self.arrHoldingList.filter({ $0.symbol == self.objStockDetail.symbol}).first {
                    let qty = (objPort.qty as NSString).doubleValue
                    let lastDayPrice = (objPort.lastday_price as NSString).doubleValue
                    current = qty * lastDayPrice
                } else {
                    current = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
                }
            }
            
            self.lblStockName.text = "Sell \(self.objStockDetail.symbol)"
            self.lblBalance.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "$" + "\(String(format: "%.2f", current))" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblBalance.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: "available", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblBalance.font.pointSize - 4)!, strSecondColor: UIColor.tblStatementContent)
            
            self.lblShareCountValue.text = (String(format: "%.5f", shareCount))
            self.lblMarketPriceValue.text = "$" + "\(marketPrice)"
            self.lblCostValue.text = "$" + self.strAmount
        }
        
        self.viewPopupSuccess.isHidden = true
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        if self.isFromBuy {
            if self.isFromEdit == false {
                self.callBuyOrderAPI()
            } else {
                self.callUpdateBuyOrderAPI()
            }
        } else {
            if self.isFromEdit == false {
                self.callSellOrderAPI()
            } else {
                self.callUpdateSellOrderAPI()
            }
        }
    }
}

//MARK: - API CALL -

extension FractionalShareVC {
    //BUY ORDER API
    func callBuyOrderAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["symbol"] = self.objStockDetail.symbol
        params["side"] = "buy"
        params["qty"] = ""
        params["notional"] = self.strAmount
        params["time_in_force"] = "day"
        params["type"] = "market"
        params["stop_price"] = ""
        params["stop_loss"] = ""
        params["limit_price"] = ""
        params["trail_price"] = ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "true"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_ORDER, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.lblSuccess.text = "Successfully Buy"
                        strongSelf.viewPopupSuccess.isHidden = false
                        
                        if strongSelf.isFromPortfolio {
                            NotificationCenter.default.post(name: Notification.Name(kUpdatePortfolio), object: nil)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.navigationController?.popToViewController(ofClass: StockDetailVC.self, animated: true)
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
    
    //SELL ORDER API
    func callSellOrderAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["symbol"] = self.objStockDetail.symbol
        params["side"] = "sell"
        params["qty"] = ""
        params["notional"] = self.strAmount
        params["time_in_force"] = "day"
        params["type"] = "market"
        params["stop_price"] = ""
        params["stop_loss"] = ""
        params["limit_price"] = ""
        params["trail_price"] = ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "true"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_ORDER, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.lblSuccess.text = "Successfully Sell"
                        strongSelf.viewPopupSuccess.isHidden = false
                        
                        if strongSelf.isFromPortfolio {
                            NotificationCenter.default.post(name: Notification.Name(kUpdatePortfolio), object: nil)
                        } else {
                            NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.navigationController?.popToViewController(ofClass: StockDetailVC.self, animated: true)
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
    
    //UPDATE BUY ORDER API
    func callUpdateBuyOrderAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_ORDER + "/" + "\(self.objOrderDetail.id)"
        
        var params: [String:Any] = [:]
        params["symbol"] = self.objStockDetail.symbol
        params["side"] = "buy"
        params["qty"] = ""
        params["notional"] = self.strAmount
        params["time_in_force"] = "day"
        params["type"] = "market"
        params["stop_price"] = ""
        params["stop_loss"] = ""
        params["limit_price"] = ""
        params["trail_price"] = ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "true"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPATCHURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.lblSuccess.text = "Successfully Update"
                        strongSelf.viewPopupSuccess.isHidden = false
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.navigationController?.popToViewController(ofClass: OrdersVC.self, animated: true)
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
    
    //UPDATE SELL ORDER API
    func callUpdateSellOrderAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_ORDER + "/" + "\(self.objOrderDetail.id)"
        
        var params: [String:Any] = [:]
        params["symbol"] = self.objStockDetail.symbol
        params["side"] = "sell"
        params["qty"] = ""
        params["notional"] = self.strAmount
        params["time_in_force"] = "day"
        params["type"] = "market"
        params["stop_price"] = ""
        params["stop_loss"] = ""
        params["limit_price"] = ""
        params["trail_price"] = ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "true"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPATCHURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.lblSuccess.text = "Successfully Update"
                        strongSelf.viewPopupSuccess.isHidden = false
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.navigationController?.popToViewController(ofClass: OrdersVC.self, animated: true)
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
}
