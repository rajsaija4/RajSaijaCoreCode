//
//  ModifyOrderVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 25/04/22.
//

import UIKit
import SwiftyJSON
import DropDown

class ModifyOrderVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var viewBuy: UIView!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var viewBuyLine: UIView!
    @IBOutlet weak var viewSell: UIView!
    @IBOutlet weak var btnSell: UIButton!
    @IBOutlet weak var viewSellLine: UIView!
    
    //BUY VIEW
    @IBOutlet weak var scrollViewBuy: UIScrollView!
    @IBOutlet weak var viewContentBuy: UIView!
    
    @IBOutlet weak var viewStockDetailBuy: UIView!
    @IBOutlet weak var lblStockNameBuy: UILabel!
    @IBOutlet weak var lblStockCompanyBuy: UILabel!
    @IBOutlet weak var lblStockPriceBuy: UILabel!
    @IBOutlet weak var lblStockVariationBuy: UILabel!
    
    @IBOutlet weak var lblQuantityTitleBuy: UILabel!
    @IBOutlet weak var txtQuantityBuy: NoPopUpTextField!
    
    @IBOutlet weak var lblPriceTitleBuy: UILabel!
    @IBOutlet weak var txtPriceBuy: NoPopUpTextField!
    
    @IBOutlet weak var lblValidityTitleBuy: UILabel!
    @IBOutlet weak var viewValidityBuy: UIView!
    @IBOutlet weak var txtValidityBuy: UITextField!
    
    @IBOutlet weak var lblOrderTypeTitleBuy: UILabel!
    @IBOutlet weak var viewOrderTypeBuy: UIView!
    @IBOutlet weak var txtOrderTypeBuy: UITextField!
    
    @IBOutlet weak var lblTriggerTitleBuy: UILabel!
    @IBOutlet weak var txtTriggerBuy: NoPopUpTextField!
    
    @IBOutlet weak var lblTargetTitleBuy: UILabel!
    @IBOutlet weak var txtTargetBuy: NoPopUpTextField!
    
    @IBOutlet weak var lblTrailingStoplossTitleBuy: UILabel!
    @IBOutlet weak var txtTrailingStoplossBuy: NoPopUpTextField!
    
    @IBOutlet weak var lblCommissionDescBuy: UILabel!
    
    @IBOutlet weak var viewSwipeBuy: UIView!
    @IBOutlet weak var imgSwipeBuy: UIImageView!
    @IBOutlet weak var lblSwipeBuy: UILabel!
    
    //SELL VIEW
    @IBOutlet weak var scrollViewSell: UIScrollView!
    @IBOutlet weak var viewContentSell: UIView!
    
    @IBOutlet weak var viewStockDetailSell: UIView!
    @IBOutlet weak var lblStockNameSell: UILabel!
    @IBOutlet weak var lblStockCompanySell: UILabel!
    @IBOutlet weak var lblStockPriceSell: UILabel!
    @IBOutlet weak var lblStockVariationSell: UILabel!
    
    @IBOutlet weak var lblTypeTitleSell: UILabel!
    @IBOutlet weak var txtTypeSell: UITextField!
    
    @IBOutlet weak var lblTriggerPriceTitleSell: UILabel!
    @IBOutlet weak var txtTriggerPrice1Sell: NoPopUpTextField!
    @IBOutlet weak var lblTriggerPrice2Sell: UILabel!
    
    @IBOutlet weak var lblValidityTitleSell: UILabel!
    @IBOutlet weak var viewValiditySell: UIView!
    @IBOutlet weak var txtValiditySell: UITextField!
    
    @IBOutlet weak var lblOrderTitleSell: UILabel!
    @IBOutlet weak var viewOrderSell: UIView!
    @IBOutlet weak var txtOrderSell: UITextField!
    
    @IBOutlet weak var lblQuantityTitleSell: UILabel!
    @IBOutlet weak var txtQuantitySell: NoPopUpTextField!
    
    @IBOutlet weak var lblPriceTitleSell: UILabel!
    @IBOutlet weak var txtPriceSell: NoPopUpTextField!
    
    @IBOutlet weak var lblTargetTitleSell: UILabel!
    @IBOutlet weak var txtTargetSell: NoPopUpTextField!
    
    @IBOutlet weak var lblTrailingStoplossTitleSell: UILabel!
    @IBOutlet weak var txtTrailingStoplossSell: NoPopUpTextField!
    
    @IBOutlet weak var lblCommissionDescSell: UILabel!

    @IBOutlet weak var btnConfirmation: UIButton!
    @IBOutlet weak var lblConfirmation: UILabel!
        
    @IBOutlet weak var viewSwipeSell: UIView!
    @IBOutlet weak var imgSwipeSell: UIImageView!
    @IBOutlet weak var lblSwipeSell: UILabel!
    
    //
    @IBOutlet weak var viewPopupFail: UIView!
    @IBOutlet weak var lblBuyingPower: UILabel!
    @IBOutlet weak var btnOkPopup: UIButton!
    
    @IBOutlet weak var viewPopupSuccess: UIView!
    @IBOutlet weak var lblSuccess: UILabel!
    
    //BUY VIEW
    var validityBuyDropDown = DropDown()
    
    //SELL VIEW
    var validitySellDropDown = DropDown()
    
    var swipeBuyGesture = UISwipeGestureRecognizer()
    var swipeSellGesture = UISwipeGestureRecognizer()
    
    var isSelectedBuy:Bool = true

    var objOrderDetail = OrderObject.init([:])
    var objStockDetail = AssetsObject.init([:])
    
    var buyingPower: Double = 0.0
    
    var arrHoldingList: [PortfolioObject] = []
    
    var commissionValue: String = ""
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupModifyBuySellSocketEvents()
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
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateModifyBuySellBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateModifyBuySellTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(ModifyOrderVC.getModifyBuySellBarData(notification:)), name: NSNotification.Name(kUpdateModifyBuySellBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ModifyOrderVC.getModifyBuySellTradesData(notification:)), name: NSNotification.Name(kUpdateModifyBuySellTrades), object: nil)
    }
    
    @objc func getModifyBuySellBarData(notification: Notification) {
        debugPrint("=====Getting Modify BuySell Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if symbol == self.objStockDetail.symbol {
                self.objStockDetail.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                self.objStockDetail.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.objStockDetail.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.objStockDetail.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getModifyBuySellTradesData(notification: Notification) {
        debugPrint("=====Getting Modify BuySell Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objStockDetail.symbol {
                    self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.plVariationValue = self.objStockDetail.current_price - self.objStockDetail.prev_close_price//closePrice //self.objStockDetail.current_price - self.objStockDetail.openPrice
                    self.objStockDetail.plVariationPer = (self.objStockDetail.plVariationValue * 100) / self.objStockDetail.prev_close_price//closePrice
                    
                    DispatchQueue.main.async {
                        self.setupLiveData()
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
            
            //BUY VIEW
            self.viewContentBuy.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
            self.viewContentBuy.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
                        
            self.viewSwipeBuy.layer.cornerRadius = self.viewSwipeBuy.frame.height / 2.0
            self.viewSwipeBuy.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            
            self.btnOkPopup.createButtonShadow(BorderColor: UIColor.init(hex: 0x27B1FC, a: 0.35), ShadowColor: UIColor.init(hex: 0x27B1FC, a: 0.35))
            
            //SELL VIEW
            self.viewContentSell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
            self.viewContentSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
                        
            self.viewSwipeSell.layer.cornerRadius = self.viewSwipeSell.frame.height / 2.0
            self.viewSwipeSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        //BUY VIEW
        self.lblQuantityTitleBuy.textColor = UIColor.labelTextColor
        self.txtQuantityBuy.textColor = UIColor.textFieldTextColor
        
        self.lblPriceTitleBuy.textColor = UIColor.labelTextColor
        self.txtPriceBuy.textColor = UIColor.textFieldTextColor
        
        self.lblValidityTitleBuy.textColor = UIColor.labelTextColor
        self.txtValidityBuy.textColor = UIColor.textFieldTextColor
        
        self.lblOrderTypeTitleBuy.textColor = UIColor.labelTextColor
        self.txtOrderTypeBuy.textColor = UIColor.textFieldTextColor
        
        self.lblTriggerTitleBuy.textColor = UIColor.labelTextColor
        self.txtTriggerBuy.textColor = UIColor.textFieldTextColor
        
        self.lblTargetTitleBuy.textColor = UIColor.labelTextColor
        self.txtTargetBuy.textColor = UIColor.textFieldTextColor
        
        self.lblTrailingStoplossTitleBuy.textColor = UIColor.labelTextColor
        self.txtTrailingStoplossBuy.textColor = UIColor.textFieldTextColor
                
        self.txtPriceBuy.isUserInteractionEnabled = false
        self.txtValidityBuy.isUserInteractionEnabled = false
        self.txtOrderTypeBuy.isUserInteractionEnabled = false
        
        //SELL VIEW
        self.lblTypeTitleSell.textColor = UIColor.labelTextColor
        self.txtTypeSell.textColor = UIColor.textFieldTextColor
        
        self.lblTriggerPriceTitleSell.textColor = UIColor.labelTextColor
        self.txtTriggerPrice1Sell.textColor = UIColor.textFieldTextColor
        self.lblTriggerPrice2Sell.textColor = UIColor.tblMarketDepthContent
        
        self.lblValidityTitleSell.textColor = UIColor.labelTextColor
        self.txtValiditySell.textColor = UIColor.textFieldTextColor
        
        self.lblOrderTitleSell.textColor = UIColor.labelTextColor
        self.txtOrderSell.textColor = UIColor.textFieldTextColor
        
        self.lblQuantityTitleSell.textColor = UIColor.labelTextColor
        self.txtQuantitySell.textColor = UIColor.textFieldTextColor
        
        self.lblPriceTitleSell.textColor = UIColor.labelTextColor
        self.txtPriceSell.textColor = UIColor.textFieldTextColor
        
        self.lblTargetTitleSell.textColor = UIColor.labelTextColor
        self.txtTargetSell.textColor = UIColor.textFieldTextColor
        
        self.lblTrailingStoplossTitleSell.textColor = UIColor.labelTextColor
        self.txtTrailingStoplossSell.textColor = UIColor.textFieldTextColor
                
        self.lblConfirmation.textColor = UIColor.taxExemptionAgreeTerms

        self.viewSell.isHidden = true
        if self.arrHoldingList.count > 0 {
            let arrSymbol = self.arrHoldingList.map { $0.symbol }
            
            if arrSymbol.contains(self.objStockDetail.symbol) {
                self.viewSell.isHidden = false
            } else {
                self.viewSell.isHidden = true
            }
        }
        
        self.txtTypeSell.isUserInteractionEnabled = false
        self.txtValiditySell.isUserInteractionEnabled = false
        self.txtOrderSell.isUserInteractionEnabled = false
        self.txtPriceSell.isUserInteractionEnabled = false
        
        //
        let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        
        for direction in directions {
            self.swipeBuyGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeBuyImage(_:)))
            self.imgSwipeBuy.addGestureRecognizer(self.swipeBuyGesture)
            self.swipeBuyGesture.direction = direction
            self.imgSwipeBuy.isUserInteractionEnabled = true
            self.imgSwipeBuy.isMultipleTouchEnabled = true
        }
        
        for dir in directions {
            self.swipeSellGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeSellImage(_:)))
            self.imgSwipeSell.addGestureRecognizer(self.swipeSellGesture)
            self.swipeSellGesture.direction = dir
            self.imgSwipeSell.isUserInteractionEnabled = true
            self.imgSwipeSell.isMultipleTouchEnabled = true
        }
        
        self.buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
        self.lblBuyingPower.text = "You have available only '$\(self.buyingPower.clean)' buying power to buy stock"
        
        self.viewPopupFail.isHidden = true
        self.viewPopupSuccess.isHidden = true
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupModifyBuySellSocketEvents()
//        SocketIOManager.shared.socket?.connect()
//
//        var objBars = Dictionary<String,AnyObject>()
//        objBars["symbol"] = self.objStockDetail.symbol as AnyObject
//        objBars["type"] = EMIT_TYPE_BARS as AnyObject
//        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            var objTrades = Dictionary<String,AnyObject>()
//            objTrades["symbol"] = self.objStockDetail.symbol as AnyObject
//            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//        }
        
        self.callGetCommissionAPI()
        
        self.setupBuySellView()
    }
    
    //MARK: - HELPER -
    
    func setupBuySellView() {
        if self.isSelectedBuy == true {
            self.btnBuy.setTitleColor(UIColor.init(hex: 0xFE3D2F), for: [])
            self.btnBuy.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: (self.btnBuy.titleLabel?.font.pointSize)!)
            self.btnSell.setTitleColor(UIColor.white, for: [])
            self.btnSell.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: (self.btnSell.titleLabel?.font.pointSize)!)
            self.viewBuyLine.isHidden = false
            self.viewSellLine.isHidden = true
            
            self.viewBuy.isHidden = false
            self.viewSell.isHidden = true
            
            self.scrollViewBuy.isHidden = false
            self.scrollViewSell.isHidden = true
            
            self.setupBuyData()
        } else {
            self.btnBuy.setTitleColor(UIColor.white, for: [])
            self.btnBuy.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: (self.btnBuy.titleLabel?.font.pointSize)!)
            self.btnSell.setTitleColor(UIColor.init(hex: 0xFE3D2F), for: [])
            self.btnSell.titleLabel?.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: (self.btnSell.titleLabel?.font.pointSize)!)
            self.viewBuyLine.isHidden = true
            self.viewSellLine.isHidden = false
            
            self.viewBuy.isHidden = true
            self.viewSell.isHidden = false
            
            self.scrollViewBuy.isHidden = true
            self.scrollViewSell.isHidden = false
            
            self.setupSellData()
        }
    }
    
    func setupBuyData() {
        //SET DATA
        self.lblStockNameBuy.text = self.objStockDetail.symbol
        self.lblStockCompanyBuy.text = self.objStockDetail.name
        
        self.setupLiveData()
        
        self.txtValidityBuy.text = "day"
        self.txtOrderTypeBuy.text = "market"
        
        if self.commissionValue != "" {
            self.lblCommissionDescBuy.text = "Prospuh will charge $\(self.commissionValue) commission for every trade"
        }
        
        self.setupValidityBuyDropDown()
    }
    
    func setupSellData() {
        //SET DATA
        self.lblStockNameSell.text = self.objStockDetail.symbol
        self.lblStockCompanySell.text = self.objStockDetail.name
        
        self.setupLiveData()
                
        self.txtTypeSell.text = "Sell"
        self.lblTriggerPrice2Sell.text = "5.00% OF LTP"
        self.txtValiditySell.text = "day"
        self.txtOrderSell.text = "market"
        
        if self.commissionValue != "" {
            self.lblCommissionDescSell.text = "Prospuh will charge $\(self.commissionValue) commission for every trade"
        }
        
        self.setupValiditySellDropDown()
    }
    
    //SET LIVE DATA
    func setupLiveData() {
        var strVariation: String = ""
        
        if self.objStockDetail.plVariationPer > 0 {
            strVariation = "+\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else if self.objStockDetail.plVariationPer < 0 {
            strVariation = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else {
            strVariation = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (0.00%)"
        }
        
        //
        if self.isSelectedBuy == true {
            self.lblStockPriceBuy.text = "$" + String(format: "%.2f", self.objStockDetail.current_price)
            
            if self.objStockDetail.plVariationValue > 0 {
                self.lblStockVariationBuy.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x81CF01))
            } else if self.objStockDetail.plVariationValue < 0 {
                self.lblStockVariationBuy.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
            } else {
                self.lblStockVariationBuy.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationBuy.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x676767))
            }
        }
        else {
            self.lblStockPriceSell.text = "$" + String(format: "%.2f", self.objStockDetail.current_price)
            
            if self.objStockDetail.plVariationValue > 0 {
                self.lblStockVariationSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x81CF01))
            } else if self.objStockDetail.plVariationValue < 0 {
                self.lblStockVariationSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
            } else {
                self.lblStockVariationSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariationSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x676767))
            }
            
            if let objPortfolio = self.arrHoldingList.filter({ $0.symbol == self.objStockDetail.symbol}).first {
                let qty = (objPortfolio.qty as NSString).doubleValue
                let price = qty * self.objStockDetail.current_price
                
                self.txtQuantitySell.text = "\(qty)" //String(format: "%.4f", qty)
                self.txtPriceSell.text = "\(price)" //String(format: "%.2f", price)
            }
        }
    }
    
    //BUY VIEW
    func setupValidityBuyDropDown() {
        self.validityBuyDropDown = DropDown()
        let arrValidity = ["day", "gtc", "opg", "cls", "ioc", "fok"]
        
        self.validityBuyDropDown.backgroundColor = .white
        self.validityBuyDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.validityBuyDropDown.textColor = .black
        self.validityBuyDropDown.selectedTextColor = .white
        
        self.validityBuyDropDown.anchorView = self.viewValidityBuy
        self.validityBuyDropDown.bottomOffset = CGPoint(x: 0, y:((self.validityBuyDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.validityBuyDropDown.dataSource = arrValidity
        self.validityBuyDropDown.direction = .bottom
        self.validityBuyDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.validityBuyDropDown.cellHeight = 42
        
        if self.txtValidityBuy.text != "" {
            guard let index = arrValidity.firstIndex(of: self.txtValidityBuy.text!) else { return }
            self.validityBuyDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.validityBuyDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtValidityBuy.text = item
        }
    }
    
    //SELL VIEW
    func setupValiditySellDropDown() {
        self.validitySellDropDown = DropDown()
        let arrValidity = ["day", "gtc", "opg", "cls", "ioc", "fok"]
        
        self.validitySellDropDown.backgroundColor = .white
        self.validitySellDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.validitySellDropDown.textColor = .black
        self.validitySellDropDown.selectedTextColor = .white
        
        self.validitySellDropDown.anchorView = self.viewValiditySell
        self.validitySellDropDown.bottomOffset = CGPoint(x: 0, y:((self.validitySellDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.validitySellDropDown.dataSource = arrValidity
        self.validitySellDropDown.direction = .bottom
        self.validitySellDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.validitySellDropDown.cellHeight = 42
        
        if self.txtValiditySell.text != "" {
            guard let index = arrValidity.firstIndex(of: self.txtValiditySell.text!) else { return }
            self.validitySellDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.validitySellDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtValiditySell.text = item
        }
    }
    
    //MARK: - ACTIONS -
    
    @objc func didSwipeBuyImage(_ sender : UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        
//        guard let inputPrice = Double(self.txtPriceBuy.text ?? "") else { return }
        let inputPrice = Double(self.txtPriceBuy.text ?? "") ?? 0.0
        
        if self.txtOrderTypeBuy.text == "market" {
            if self.txtQuantityBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if inputPrice > self.buyingPower {
                self.viewPopupFail.isHidden = false
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeBuy.isHidden = true
                        self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                        
                        self.txtTriggerBuy.text = ""
                        self.txtTargetBuy.text = ""
                        self.txtTrailingStoplossBuy.text = ""
                        
                        self.callUpdateBuyOrderAPI()
                    }
                    self.imgSwipeBuy.layoutIfNeeded()
                    self.imgSwipeBuy.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderTypeBuy.text == "limit" {
            if self.txtQuantityBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTargetBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Target is required")
            } else if inputPrice > self.buyingPower {
                self.viewPopupFail.isHidden = false
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeBuy.isHidden = true
                        self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                        
                        self.txtTriggerBuy.text = ""
                        self.txtTrailingStoplossBuy.text = ""
                        
                        self.callUpdateBuyOrderAPI()
                    }
                    self.imgSwipeBuy.layoutIfNeeded()
                    self.imgSwipeBuy.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderTypeBuy.text == "trailing_stop" {
            if self.txtQuantityBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTrailingStoplossBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trailing stoploss value is required")
            } else if inputPrice > self.buyingPower {
                self.viewPopupFail.isHidden = false
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeBuy.isHidden = true
                        self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                        
                        self.txtTriggerBuy.text = ""
                        self.txtTargetBuy.text = ""
                        
                        self.callUpdateBuyOrderAPI()
                    }
                    self.imgSwipeBuy.layoutIfNeeded()
                    self.imgSwipeBuy.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderTypeBuy.text == "stop" {
            if self.txtQuantityBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTriggerBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trigger value is required")
            } else if inputPrice > self.buyingPower {
                self.viewPopupFail.isHidden = false
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeBuy.isHidden = true
                        self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                        
                        self.txtTargetBuy.text = ""
                        self.txtTrailingStoplossBuy.text = ""
                        
                        self.callUpdateBuyOrderAPI()
                    }
                    self.imgSwipeBuy.layoutIfNeeded()
                    self.imgSwipeBuy.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderTypeBuy.text == "stop_limit" {
            if self.txtQuantityBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTriggerBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trigger value is required")
            } else if self.txtTargetBuy.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Target value is required")
            } else if inputPrice > self.buyingPower {
                self.viewPopupFail.isHidden = false
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeBuy.isHidden = true
                        self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                        
                        self.txtTrailingStoplossBuy.text = ""
                        
                        self.callUpdateBuyOrderAPI()
                    }
                    self.imgSwipeBuy.layoutIfNeeded()
                    self.imgSwipeBuy.setNeedsDisplay()
                }
            }
        }
    }
    
    @objc func didSwipeSellImage(_ sender : UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        
        if self.txtOrderSell.text == "market" {
            if self.txtQuantitySell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.btnConfirmation.isSelected == false {
                GlobalData.shared.showSystemToastMesage(message: "Please accept terms for sell")
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeSell.isHidden = true
                        self.imgSwipeSell.frame = CGRect(x: self.viewSwipeSell.frame.size.width - self.imgSwipeSell.frame.size.width - 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
                        
                        self.txtTriggerPrice1Sell.text = ""
                        self.txtTargetSell.text = ""
                        self.txtTrailingStoplossSell.text = ""
                        
                        self.callUpdateSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderSell.text == "limit" {
            if self.txtQuantitySell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTargetSell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Target is required")
            } else if self.btnConfirmation.isSelected == false {
                GlobalData.shared.showSystemToastMesage(message: "Please accept terms for sell")
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeSell.isHidden = true
                        self.imgSwipeSell.frame = CGRect(x: self.viewSwipeSell.frame.size.width - self.imgSwipeSell.frame.size.width - 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
                        
                        self.txtTriggerPrice1Sell.text = ""
                        self.txtTrailingStoplossSell.text = ""
                        
                        self.callUpdateSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderSell.text == "trailing_stop" {
            if self.txtQuantitySell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTrailingStoplossSell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trailing stoploss value is required")
            } else if self.btnConfirmation.isSelected == false {
                GlobalData.shared.showSystemToastMesage(message: "Please accept terms for sell")
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeSell.isHidden = true
                        self.imgSwipeSell.frame = CGRect(x: self.viewSwipeSell.frame.size.width - self.imgSwipeSell.frame.size.width - 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
                        
                        self.txtTriggerPrice1Sell.text = ""
                        self.txtTargetSell.text = ""
                        
                        self.callUpdateSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderSell.text == "stop" {
            if self.txtQuantitySell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTriggerPrice1Sell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trigger value is required")
            } else if self.btnConfirmation.isSelected == false {
                GlobalData.shared.showSystemToastMesage(message: "Please accept terms for sell")
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeSell.isHidden = true
                        self.imgSwipeSell.frame = CGRect(x: self.viewSwipeSell.frame.size.width - self.imgSwipeSell.frame.size.width - 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
                        
                        self.txtTargetSell.text = ""
                        self.txtTrailingStoplossSell.text = ""
                        
                        self.callUpdateSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
        else if self.txtOrderSell.text == "stop_limit" {
            if self.txtQuantitySell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Quantity is required")
            } else if self.txtTriggerPrice1Sell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Trigger value is required")
            } else if self.txtTargetSell.isEmpty() == 1 {
                GlobalData.shared.showSystemToastMesage(message: "Target value is required")
            } else if self.btnConfirmation.isSelected == false {
                GlobalData.shared.showSystemToastMesage(message: "Please accept terms for sell")
            } else {
                UIView.animate(withDuration: 1.0) {
                    if sender.direction == .right {
                        self.lblSwipeSell.isHidden = true
                        self.imgSwipeSell.frame = CGRect(x: self.viewSwipeSell.frame.size.width - self.imgSwipeSell.frame.size.width - 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
                        
                        self.txtTrailingStoplossSell.text = ""
                        
                        self.callUpdateSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
    }
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //BUY VIEW
    @IBAction func btnValidityBuyClick(_ sender: UIButton) {
        self.validityBuyDropDown.show()
    }
    
    @IBAction func btnOrderTypeBuyClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "OrderTypeVC") as! OrderTypeVC
        controller.isFromBuy = true
        controller.completionBlock = {[weak self] (strOrderType) in
            guard let strongSelf = self else { return }
            strongSelf.txtOrderTypeBuy.text = strOrderType
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnOkPopupClick(_ sender: UIButton) {
        self.viewPopupFail.isHidden = true
        
        self.imgSwipeBuy.frame = CGRect(x: 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.lblSwipeBuy.isHidden = false
        }
    }
    
    //SELL VIEW
    @IBAction func btnValiditySellClick(_ sender: UIButton) {
        self.validitySellDropDown.show()
    }
    
    @IBAction func btnOrderSellClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "OrderTypeVC") as! OrderTypeVC
        controller.isFromBuy = false
        controller.completionBlock = {[weak self] (strOrderType) in
            guard let strongSelf = self else { return }
            strongSelf.txtOrderSell.text = strOrderType
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnConfirmationClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension ModifyOrderVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text: NSString = textField.text! as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if self.isSelectedBuy == true {
            if textField == self.txtQuantityBuy {
                let qty = (resultString as NSString).doubleValue
                let price = qty * self.objStockDetail.current_price
                
                self.txtPriceBuy.text = String(format: "%.2f", price)
            }
        } else {
            if textField == self.txtQuantitySell {
                let qty = (resultString as NSString).doubleValue
                let price = qty * self.objStockDetail.current_price
                
                self.txtPriceSell.text = String(format: "%.2f", price)
            }
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.isSelectedBuy == false {
            if textField == self.txtQuantitySell {
                if let objPortfolio = self.arrHoldingList.filter({ $0.symbol == self.objStockDetail.symbol}).first {
                    guard let inputValue = Double(self.txtQuantitySell.text ?? "") else { return }
                    let originalQTY = (objPortfolio.qty as NSString).doubleValue
                    
                    if inputValue > originalQTY {
                        GlobalData.shared.showDarkStyleToastMesage(message: "You don't have enough quantity to sell")
                        self.txtQuantitySell.text = ""
                        self.txtPriceSell.text = ""
                    }
                }
            }
        }
    }
}

//MARK: - API CALL -

extension ModifyOrderVC {
    //GET COMMISSION API
    func callGetCommissionAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        let params: [String:Any] = [:]
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPATCHURL(Constants.URLS.GET_COMMISSION, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.commissionValue = "\(payload["tradeCommission"] ?? "")"
                            
                            strongSelf.lblCommissionDescBuy.text = "Prospuh will charge $\(strongSelf.commissionValue) commission for every trade"
                            strongSelf.lblCommissionDescSell.text = "Prospuh will charge $\(strongSelf.commissionValue) commission for every trade"
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
        params["qty"] = self.txtQuantityBuy.text ?? ""
        params["notional"] = ""
        params["time_in_force"] = self.txtValidityBuy.text ?? ""
        params["type"] = self.txtOrderTypeBuy.text ?? ""
        params["stop_price"] = self.txtTriggerBuy.text ?? ""
        params["stop_loss"] = ""
        params["limit_price"] = self.txtTargetBuy.text ?? ""
        params["trail_price"] = self.txtTrailingStoplossBuy.text ?? ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "false"
        
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
                            strongSelf.navigationController?.popViewController(animated: true)
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
        params["qty"] = self.txtQuantitySell.text ?? ""
        params["notional"] = ""
        params["time_in_force"] = self.txtValiditySell.text ?? ""
        params["type"] = self.txtOrderSell.text ?? ""
        params["stop_price"] = self.txtTriggerPrice1Sell.text ?? ""
        params["stop_loss"] = ""
        params["limit_price"] = self.txtTargetSell.text ?? ""
        params["trail_price"] = self.txtTrailingStoplossSell.text ?? ""
        params["trail_percent"] = ""
        params["extended_hours"] = ""
        params["client_order_id"] = ""
        params["order_class"] = ""
        params["take_profit"] = ""
        params["commission"] = ""
        params["fractional"] = "false"
        
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
                            strongSelf.navigationController?.popViewController(animated: true)
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
