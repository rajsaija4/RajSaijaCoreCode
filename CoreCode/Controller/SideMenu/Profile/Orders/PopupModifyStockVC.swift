//
//  PopupModifyStockVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 06/01/22.
//

import UIKit
import SwiftyJSON
import SDWebImage

class PopupModifyStockVC: UIViewController {

    // MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewPopupStock: UIView!
    @IBOutlet weak var viewStockBG: UIView!
    @IBOutlet weak var viewStockBGsub1: UIView!
    @IBOutlet weak var viewStockBGsub2: UIView!
    @IBOutlet weak var viewContentStock: UIView!
    
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblMarket: UILabel!
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockSymbol: UILabel!
    @IBOutlet weak var lblStockPrice: UILabel!
    @IBOutlet weak var lblStockVariation: UILabel!
     
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var lblTradedQty: UILabel!
    @IBOutlet weak var lblPendingQty: UILabel!
    @IBOutlet weak var lblOrderType: UILabel!
    @IBOutlet weak var btnModify: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    var objOrderDetail = OrderObject.init([:])
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
        SocketIOManager.shared.setupOrdersSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        var objBars = Dictionary<String,AnyObject>()
        objBars["symbol"] = self.objOrderDetail.symbol as AnyObject
        objBars["type"] = EMIT_TYPE_BARS as AnyObject
        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var objTrades = Dictionary<String,AnyObject>()
            objTrades["symbol"] = self.objOrderDetail.symbol as AnyObject
            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
        }
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateOrdersBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateOrdersTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(PopupModifyStockVC.getOrdersBarData(notification:)), name: NSNotification.Name(kUpdateOrdersBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PopupModifyStockVC.getOrdersTradesData(notification:)), name: NSNotification.Name(kUpdateOrdersTrades), object: nil)
    }
    
    @objc func getOrdersBarData(notification: Notification) {
        debugPrint("=====Getting Orders Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if symbol == self.objOrderDetail.symbol {
                self.objOrderDetail.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                self.objOrderDetail.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.objOrderDetail.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.objOrderDetail.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.objOrderDetail.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.objOrderDetail.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getOrdersTradesData(notification: Notification) {
        debugPrint("=====Getting Orders Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objOrderDetail.symbol {
                    let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    let openPrice = self.objOrderDetail.openPrice
                    let closePrice = self.objOrderDetail.closePrice
                    let variationValue = currentPrice - closePrice //currentPrice - openPrice
                    let variationPer = (variationValue * 100) / closePrice
                    
                    self.objOrderDetail.current_price = currentPrice
                    self.objOrderDetail.plVariationValue = variationValue
                    self.objOrderDetail.plVariationPer = variationPer
                    
                    DispatchQueue.main.async {
                        self.setupLiveData()
                    }
                }
            }
        }
    }
    
    // MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewStockBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewStockBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewStockBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewContentStock.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewStatus.roundCorners(corners: [.topLeft, .bottomRight], radius: 6)
            
            self.viewStock.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.imgStock.layer.cornerRadius = self.imgStock.layer.frame.size.width/2
            
            self.btnModify.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            self.btnCancel.createButtonShadow(BorderColor: UIColor.init(hex: 0x27B1FC, a: 0.35), ShadowColor: UIColor.init(hex: 0x27B1FC, a: 0.35))
        }
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupOrdersSocketEvents()
//        SocketIOManager.shared.socket?.connect()
//
//        var objBars = Dictionary<String,AnyObject>()
//        objBars["symbol"] = self.objOrderDetail.symbol as AnyObject
//        objBars["type"] = EMIT_TYPE_BARS as AnyObject
//        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            var objTrades = Dictionary<String,AnyObject>()
//            objTrades["symbol"] = self.objOrderDetail.symbol as AnyObject
//            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//        }
        
        //SET DATA
        if self.objOrderDetail.side == "buy" {
            self.lblStatus.text = "BUY"
            self.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01)
        } else {
            self.lblStatus.text = "SELL"
            self.viewStatus.backgroundColor = UIColor.init(hex: 0xFE3D2F)
        }
        
        if self.objOrderDetail.order_type == "market" {
            if self.objOrderDetail.notional == "" {
                self.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: self.objOrderDetail.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
            } else {
                self.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Price:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: self.objOrderDetail.notional == "" ? "" : "$" + self.objOrderDetail.notional, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
            }
        } else {
            self.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: self.objOrderDetail.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
        }
        
        self.lblMarket.text = self.objOrderDetail.order_type
        if self.objOrderDetail.image == "" {
            self.viewStock.backgroundColor = UIColor.init(hex: 0x27B1FC)
            
            let dpName = self.objOrderDetail.symbol.prefix(1)
            self.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgStock.frame.size.width, imageHeight: self.imgStock.frame.size.height, name: "\(dpName)")
        } else {
            self.viewStock.backgroundColor = UIColor.white
            
            self.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgStock.sd_setImage(with: URL(string: self.objOrderDetail.image), placeholderImage: nil)
        }
        self.lblStockSymbol.text = self.objOrderDetail.symbol
        
        self.setupLiveData()

        self.lblOrderStatus.text = self.objOrderDetail.status
        self.lblTradedQty.text = self.objOrderDetail.filled_qty
        self.lblPendingQty.text = self.objOrderDetail.qty == "" ? "-" : self.objOrderDetail.qty
        self.lblOrderType.text = self.objOrderDetail.order_type
        
        self.callOrderDetailByIDAPI()
        self.callStockDetailAPI()
    }
    
    //SETUP LIVE DATA
    func setupLiveData() {
        self.lblStockPrice.text = "$" + convertThousand(value: self.objOrderDetail.current_price)
        
        if self.objOrderDetail.plVariationPer > 0 {
            self.lblStockVariation.text = "$+\(String(format: "%.2f", self.objOrderDetail.plVariationValue)) (+\(String(format: "%.2f", self.objOrderDetail.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
        } else if self.objOrderDetail.plVariationPer < 0 {
            self.lblStockVariation.text = "$\(String(format: "%.2f", self.objOrderDetail.plVariationValue)) (\(String(format: "%.2f", self.objOrderDetail.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
        } else {
            self.lblStockVariation.text = "$\(String(format: "%.2f", self.objOrderDetail.plVariationValue)) (0.00%)"
        }
        
        if self.objOrderDetail.plVariationValue > 0 {
            self.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
        } else if self.objOrderDetail.plVariationValue < 0 {
            self.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            self.lblStockVariation.textColor = UIColor.init(hex: 0x676767)
        }
    }
    
    //MARK: - HELPER -
    
    // MARK: - ACTIONS -

    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnModifyPopupClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            var dict = [String: Any]()
            dict["order"] = self.objOrderDetail
            dict["assets"] = self.objStockDetail
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveToEditOrder"), object: nil, userInfo: dict)
        })
    }
    
    @IBAction func btnCancelPopuplClick(_ sender: UIButton) {
        GlobalData.shared.displayConfirmationAlert(self, title: "Cancel Order", message: "Are you sure you want to cancel this order?", btnTitle1: "No", btnTitle2: "Yes", actionBlock: { (isConfirmed) in
            if isConfirmed {
                self.callCancelOrderAPI()
            }
        })
    }
}

//MARK: - API CALL -

extension PopupModifyStockVC {
    //ORDER DETAIL BY ID API
    func callOrderDetailByIDAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_ORDER_DETAIL_ID + "/" + "\(self.objOrderDetail.id)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objOrderDetail = OrderObject.init(payload)
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
    
    //GET STOCK DETAIL BY SYMBOL
    func callStockDetailAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.SEARCH_SHARE_SYMBOL + "/" + "\(self.objOrderDetail.symbol)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = AssetsObject.init(payload)
                            
                            strongSelf.lblStockPrice.text = "$" + convertThousand(value: strongSelf.objStockDetail.current_price)
                                                        
                            if strongSelf.objStockDetail.plVariationPer > 0 {
                                strongSelf.lblStockVariation.text = "$+\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", strongSelf.objStockDetail.plVariationPer))%)"
                            } else if strongSelf.objStockDetail.plVariationPer < 0 {
                                strongSelf.lblStockVariation.text = "$\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (\(String(format: "%.2f", strongSelf.objStockDetail.plVariationPer))%)"
                            } else {
                                strongSelf.lblStockVariation.text = "$\(String(format: "%.2f", strongSelf.objStockDetail.plVariationValue)) (0.00%)"
                            }
                            
                            if strongSelf.objStockDetail.plVariationValue > 0 {
                                strongSelf.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
                            } else if strongSelf.objStockDetail.plVariationValue < 0 {
                                strongSelf.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
                            } else {
                                strongSelf.lblStockVariation.textColor = UIColor.init(hex: 0x676767)
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
    
    //CANCEL ORDER API
    func callCancelOrderAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.CANCEL_ORDER + "/" + "\(self.objOrderDetail.id)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestDELETEURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateOrder), object: nil)
                        strongSelf.dismiss(animated: true, completion: nil)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        UIApplication.topViewController()?.dismiss(animated: false, completion: {
                            GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                        })
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
