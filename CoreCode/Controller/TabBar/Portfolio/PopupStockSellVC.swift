//
//  PopupStockSellVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 09/12/21.
//

import UIKit
import SwiftyJSON

class PopupStockSellVC: UIViewController {

    // MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewPopupSell: UIView!
    @IBOutlet weak var viewSellBG: UIView!
    @IBOutlet weak var viewSellBGsub1: UIView!
    @IBOutlet weak var viewSellBGsub2: UIView!
    @IBOutlet weak var viewContentSell: UIView!
    @IBOutlet weak var lblStockNameSell: UILabel!
    @IBOutlet weak var lblStockTypePriceSell: UILabel!
    @IBOutlet weak var lblStockVariationSell: UILabel!
    @IBOutlet weak var btnSell: UIButton!
    @IBOutlet weak var btnExit: UIButton!
    @IBOutlet weak var lblStockInvestedSell: UILabel!
    @IBOutlet weak var lblStockCurrentSell: UILabel!
    @IBOutlet weak var lblStockPLSell: UILabel!
    @IBOutlet weak var lblStockQtySell: UILabel!
    @IBOutlet weak var lblStockAvgPriceSell: UILabel!
    
    var objPortfolio: PortfolioObject!
    var objStockDetail = AssetsObject.init([:])
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
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
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(PopupStockSellVC.getBarData(notification:)), name: NSNotification.Name(kUpdatePortfolioBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopupStockSellVC.getTradesData(notification:)), name: NSNotification.Name(kUpdatePortfolioTrades), object: nil)
    }
    
    @objc func getBarData(notification: Notification) {
        debugPrint("=====Getting Popup Portfolio Bar Data=====")
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
    
    @objc func getTradesData(notification: Notification) {
        debugPrint("=====Getting Popup Portfolio Trades Data=====")
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
                    
                    DispatchQueue.main.async {
                        self.setupData()
                    }
                }
            }
        }
    }
    
    // MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewSellBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewSellBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewSellBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewContentSell.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            self.btnExit.createButtonShadow(BorderColor: UIColor.init(hex: 0x27B1FC, a: 0.35), ShadowColor: UIColor.init(hex: 0x27B1FC, a: 0.35))
        }
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupPortfolioSocketEvents()
//        SocketIOManager.shared.socket?.connect()
//
//        var objBars = Dictionary<String,AnyObject>()
//        objBars["symbol"] = self.objPortfolio.symbol as AnyObject
//        objBars["type"] = EMIT_TYPE_BARS as AnyObject
//        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            var objTrades = Dictionary<String,AnyObject>()
//            objTrades["symbol"] = self.objPortfolio.symbol as AnyObject
//            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//        }
        
        self.setupData()
        
        self.callStockDetailAPI()
    }
    
    // MARK: - SETUP DATA -
    
    func setupData() {
        let invested = (self.objPortfolio.cost_basis as NSString).doubleValue
        let qty = (self.objPortfolio.qty as NSString).doubleValue
        let avgPrice = (self.objPortfolio.avg_entry_price as NSString).doubleValue
        let lastDayPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
        let current = qty * lastDayPrice
        let plValue = current - invested
//        let variationValue = (self.objPortfolio.unrealized_pl as NSString).doubleValue
//        let variationPer = (self.objPortfolio.unrealized_plpc as NSString).doubleValue
//        let strVariationPer = String(format: "%.4f", variationPer)
                
        self.lblStockNameSell.text = self.objPortfolio.symbol
        if lastDayPrice > 0 || lastDayPrice > 0.0 {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objPortfolio.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x676767), strSecond: "$" + String(format: "%.2f", lastDayPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x65AA3D))
        } else {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objPortfolio.exchange + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x676767), strSecond: "$" + String(format: "%.2f", lastDayPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
        }
        
        if self.objPortfolio.plVariationPer > 0 {
            self.lblStockVariationSell.text = "+\(String(format: "%.2f", self.objPortfolio.plVariationValue)) (+\(String(format: "%.2f", self.objPortfolio.plVariationPer))%)"
        } else if self.objPortfolio.plVariationPer < 0 {
            self.lblStockVariationSell.text = "\(String(format: "%.2f", self.objPortfolio.plVariationValue)) (\(String(format: "%.2f", self.objPortfolio.plVariationPer))%)"
        } else {
            self.lblStockVariationSell.text = "\(String(format: "%.2f", self.objPortfolio.plVariationValue)) (0.00%)"
        }
        
        if self.objPortfolio.plVariationValue > 0 {
            self.lblStockVariationSell.textColor = UIColor.init(hex: 0x65AA3D)
        } else {
            self.lblStockVariationSell.textColor = UIColor.init(hex: 0xFE3D2F)
        }
        
        self.lblStockInvestedSell.text = "$" + String(format: "%.2f", invested)
        self.lblStockCurrentSell.text = "$" + String(format: "%.2f", current)
        self.lblStockPLSell.text = String(format: "%.2f", plValue)
        self.lblStockQtySell.text = String(format: "%.4f", qty)
        self.lblStockAvgPriceSell.text = "$" + String(format: "%.2f", avgPrice)
        
        if current > invested {
            self.lblStockCurrentSell.textColor = UIColor.init(hex: 0x65AA3D)
        } else {
            self.lblStockCurrentSell.textColor = UIColor.init(hex: 0xFE3D2F)
        }
        
        if plValue > 0 {
            self.lblStockPLSell.textColor = UIColor.init(hex: 0x65AA3D)
        } else {
            self.lblStockPLSell.textColor = UIColor.init(hex: 0xFE3D2F)
        }
    }
    
    //MARK: - HELPER -
    
    // MARK: - ACTIONS -

    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnSellPopupClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
//            var dict = [String: AssetsObject]()
//            dict["data"] = self.objStockDetail
            
            var dict = [String: Any]()
            dict["portfolio"] = self.objPortfolio
            dict["assets"] = self.objStockDetail
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveToNextController"), object: nil, userInfo: dict)
        })
    }
    
    @IBAction func btnExitPopuplClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - API CALL -

extension PopupStockSellVC {
    //GET STOCK DETAIL BY SYMBOL
    func callStockDetailAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.SEARCH_SHARE_SYMBOL + "/" + "\(self.objPortfolio.symbol)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = AssetsObject.init(payload)
                            
                            if strongSelf.objStockDetail.plVariationValue > 0 {
                                strongSelf.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: strongSelf.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: strongSelf.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x676767), strSecond: "$" + String(format: "%.2f", strongSelf.objStockDetail.current_price), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: strongSelf.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x65AA3D))
                            } else {
                                strongSelf.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: strongSelf.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: strongSelf.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.init(hex: 0x676767), strSecond: "$" + String(format: "%.2f", strongSelf.objStockDetail.current_price), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: strongSelf.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
                            }
                            
                            if strongSelf.objStockDetail.plVariationPer > 0 {
                                strongSelf.lblStockVariationSell.text = "+\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", strongSelf.objStockDetail.plVariationPer))%)"
                            } else if strongSelf.objStockDetail.plVariationPer < 0 {
                                strongSelf.lblStockVariationSell.text = "\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (\(String(format: "%.2f", strongSelf.objStockDetail.plVariationPer))%)"
                            } else {
                                strongSelf.lblStockVariationSell.text = "\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (0.00%)"
                            }
                            
                            if strongSelf.objStockDetail.plVariationValue > 0 {
                                strongSelf.lblStockVariationSell.textColor = UIColor.init(hex: 0x65AA3D)
                            } else if strongSelf.objStockDetail.plVariationValue < 0 {
                                strongSelf.lblStockVariationSell.textColor = UIColor.init(hex: 0xFE3D2F)
                            } else {
                                strongSelf.lblStockVariationSell.textColor = UIColor.init(hex: 0x676767)
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
