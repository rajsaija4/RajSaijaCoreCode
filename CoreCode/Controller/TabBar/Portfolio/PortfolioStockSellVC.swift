//
//  PortfolioStockSellVC.swift

import UIKit
import SwiftyJSON
import DropDown
import SDWebImage

class PortfolioStockSellVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var scrollViewSell: UIScrollView!
    @IBOutlet weak var viewContentSell: UIView!
    
    @IBOutlet weak var viewStockDetailSell: UIView!
    @IBOutlet weak var viewStockSell: UIView!
    @IBOutlet weak var imgStockSell: UIImageView!
    @IBOutlet weak var lblStockNameSell: UILabel!
    @IBOutlet weak var lblStockTypePriceSell: UILabel!
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
    
    @IBOutlet weak var viewFractionalShareSell: UIView!
    @IBOutlet weak var lblFractionalShareSell: UILabel!
    
    @IBOutlet weak var lblCommissionDescSell: UILabel!
    
    @IBOutlet weak var btnConfirmation: UIButton!
    @IBOutlet weak var lblConfirmation: UILabel!
    
    @IBOutlet weak var viewSwipeSell: UIView!
    @IBOutlet weak var imgSwipeSell: UIImageView!
    @IBOutlet weak var lblSwipeSell: UILabel!
    
    @IBOutlet weak var viewPopupSuccessSell: UIView!
    
    var objPortfolio: PortfolioObject!
    var objStockDetail = AssetsObject.init([:])
    
    var validitySellDropDown = DropDown()
    var swipeSellGesture = UISwipeGestureRecognizer()
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioStockSellVC.getBarData(notification:)), name: NSNotification.Name(kUpdatePortfolioBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(PortfolioStockSellVC.getTradesData(notification:)), name: NSNotification.Name(kUpdatePortfolioTrades), object: nil)
    }
    
    @objc func getBarData(notification: Notification) {
        debugPrint("=====Getting Portfolio Stock Sell Bar Data=====")
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
        debugPrint("=====Getting Portfolio Stock Sell Trades Data=====")
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
            
            self.viewContentSell.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
            self.viewContentSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewFractionalShareSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewSwipeSell.layer.cornerRadius = self.viewSwipeSell.frame.height / 2.0
            self.viewSwipeSell.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
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
        
        self.lblFractionalShareSell.textColor = UIColor.labelTextColor
        
        self.lblConfirmation.textColor = UIColor.taxExemptionAgreeTerms

        self.txtTypeSell.isUserInteractionEnabled = false
        self.txtValiditySell.isUserInteractionEnabled = false
        self.txtOrderSell.isUserInteractionEnabled = false
        self.txtPriceSell.isUserInteractionEnabled = false
        
        if self.objStockDetail.fractionable == true {
            self.viewFractionalShareSell.isHidden = false
        } else {
            self.viewFractionalShareSell.isHidden = true
        }
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right]
        
        for direction in directions {
            self.swipeSellGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeSellImage(_:)))
            self.imgSwipeSell.addGestureRecognizer(self.swipeSellGesture)
            self.swipeSellGesture.direction = direction
            self.imgSwipeSell.isUserInteractionEnabled = true
            self.imgSwipeSell.isMultipleTouchEnabled = true
        }
        
        self.viewPopupSuccessSell.isHidden = true
        
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
        
        self.callGetCommissionAPI()
        
        self.setupSellData()
        self.setMarketCloseData()
    }
    
    //MARK: - HELPER -
    
    func setupSellData() {
        //SET DATA
        if self.objStockDetail.image == "" {
            self.viewStockSell.backgroundColor = UIColor.init(hex: 0x27B1FC)
            
            let dpName = self.objStockDetail.symbol.prefix(1)
            self.imgStockSell.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgStockSell.frame.size.width, imageHeight: self.imgStockSell.frame.size.height, name: "\(dpName)")
        } else {
            self.viewStockSell.backgroundColor = UIColor.white
            
            self.imgStockSell.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgStockSell.sd_setImage(with: URL(string: self.objStockDetail.image), placeholderImage: nil)
        }
        
        self.lblStockNameSell.text = self.objStockDetail.symbol
        
        self.setupLiveData()
        
        self.txtTypeSell.text = "Sell"
        self.lblTriggerPrice2Sell.text = "5.00% OF LTP"
        self.txtValiditySell.text = "day"
        self.txtOrderSell.text = "market"
        
        if self.commissionValue != "" {
            self.lblCommissionDescSell.text = "projectName will charge $\(self.commissionValue) commission for every trade"
        }
        
        self.setupValiditySellDropDown()
    }
    
    func setupLiveData() {
        let qty = (self.objPortfolio.qty as NSString).doubleValue
        let lastDayPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
        let price = qty * lastDayPrice
        
        if lastDayPrice > 0 || lastDayPrice > 0.0 {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objPortfolio.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: "$" + String(format: "%.2f", lastDayPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x65AA3D))
        } else {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objPortfolio.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: "$" + String(format: "%.2f", lastDayPrice), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
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
        
        self.txtQuantitySell.text = "\(qty)" //String(format: "%.4f", qty)
        self.txtPriceSell.text = "\(price)" //String(format: "%.2f", price)
    }
    
    func setMarketCloseData() {
        if self.objStockDetail.plVariationValue > 0 {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: "$" + String(format: "%.2f", self.objStockDetail.current_price), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x65AA3D))
        } else {
            self.lblStockTypePriceSell.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strFirstColor: UIColor.black, strSecond: "$" + String(format: "%.2f", self.objStockDetail.current_price), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockTypePriceSell.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
        }
        
        if self.objStockDetail.plVariationPer > 0 {
            self.lblStockVariationSell.text = "+\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else if self.objStockDetail.plVariationPer < 0 {
            self.lblStockVariationSell.text = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else {
            self.lblStockVariationSell.text = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (0.00%)"
        }
        
        if self.objStockDetail.plVariationValue > 0 {
            self.lblStockVariationSell.textColor = UIColor.init(hex: 0x65AA3D)
        } else if self.objStockDetail.plVariationValue < 0 {
            self.lblStockVariationSell.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            self.lblStockVariationSell.textColor = UIColor.init(hex: 0x676767)
        }
    }
    
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
                        
                        self.callSellOrderAPI()
                    }
//                    else if sender.direction == .left {
//                        self.imgSwipeSell.frame = CGRect(x: 8, y: self.imgSwipeSell.frame.origin.y , width: self.imgSwipeSell.frame.size.width, height: self.imgSwipeSell.frame.size.height)
//
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            self.lblSwipeSell.isHidden = false
//                        }
//                    }
                    /*else if sender.direction == .up {
                        self.imageView.frame = CGRect(x: self.view.frame.size.width - self.imageView.frame.size.width, y: 0 , width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
                    }
                    else if sender.direction == .down {
                        self.imageView.frame = CGRect(x: self.view.frame.size.width - self.imageView.frame.size.width, y: self.view.frame.size.height - self.imageView.frame.height , width: self.imageView.frame.size.width, height: self.imageView.frame.size.height)
                    }*/
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
                        
                        self.callSellOrderAPI()
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
                        
                        self.callSellOrderAPI()
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
                        
                        self.callSellOrderAPI()
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
                        
                        self.callSellOrderAPI()
                    }
                    self.imgSwipeSell.layoutIfNeeded()
                    self.imgSwipeSell.setNeedsDisplay()
                }
            }
        }
    }
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.navigationController?.popToViewController(ofClass: PortfolioVC.self, animated: true)
    }
    
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
    
    @IBAction func btnSellFractionalShareClick(_ sender: UIButton) {
        if self.txtValiditySell.text != "day" {
            GlobalData.shared.showSystemToastMesage(message: "Please select validity 'day' for fractional orders")
        } else if self.txtOrderSell.text != "market" {
            GlobalData.shared.showSystemToastMesage(message: "Please select order type 'market' for fractional orders")
        } else {
            let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "BuySellFractionalShareVC") as! BuySellFractionalShareVC
            controller.isFromPortfolio = true
            controller.isFromBuy = false
            controller.objPortfolio = self.objPortfolio
            controller.objStockDetail = self.objStockDetail
            controller.isFromEdit = false
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension PortfolioStockSellVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text: NSString = textField.text! as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if textField == self.txtQuantitySell {
            let qty = (resultString as NSString).doubleValue
            let lastDayPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
            let price = qty * lastDayPrice
            
            self.txtPriceSell.text = String(format: "%.2f", price)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtQuantitySell {
            guard let inputValue = Double(self.txtQuantitySell.text ?? "") else { return }
            let originalQTY = (self.objPortfolio.qty as NSString).doubleValue
            
            if inputValue > originalQTY {
                GlobalData.shared.showDarkStyleToastMesage(message: "You don't have enough quantity to sell")
                self.txtQuantitySell.text = ""
                self.txtPriceSell.text = ""
            }
        }
    }
}

//MARK: - API CALL -

extension PortfolioStockSellVC {
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
                            
                            strongSelf.lblCommissionDescSell.text = "projectName will charge $\(strongSelf.commissionValue) commission for every trade"
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
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_ORDER, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.viewPopupSuccessSell.isHidden = false
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdatePortfolio), object: nil)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.imgSwipeSell.frame = CGRect(x: 8, y: strongSelf.imgSwipeSell.frame.origin.y , width: strongSelf.imgSwipeSell.frame.size.width, height: strongSelf.imgSwipeSell.frame.size.height)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            strongSelf.lblSwipeSell.isHidden = false
                        }
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
