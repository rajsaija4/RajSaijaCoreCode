//
//  SetAlertVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 19/11/21.
//

import UIKit
import SideMenuSwift
import DropDown
import SwiftyJSON

class SetAlertVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewStockDetail: UIView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockCompany: UILabel!
    @IBOutlet weak var lblStockPrice: UILabel!
    @IBOutlet weak var lblStockVariation: UILabel!
    
    @IBOutlet weak var lblAlertMeTitle: UILabel!
    @IBOutlet weak var viewAlertMe: UIView!
    @IBOutlet weak var txtAlertMe: UITextField!
    
    @IBOutlet weak var lblOfTitle: UILabel!
    @IBOutlet weak var viewOf: UIView!
    @IBOutlet weak var txtOf: UITextField!
    
    @IBOutlet weak var lblIsTitle: UILabel!
    @IBOutlet weak var viewIs: UIView!
    @IBOutlet weak var txtIs: UITextField!
    
    @IBOutlet weak var lblStock: UILabel!
    
    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var txtAmount: NoPopUpTextField!
    
    @IBOutlet weak var lblTriggerTitle: UILabel!
    @IBOutlet weak var viewTrigger: UIView!
    @IBOutlet weak var txtTrigger: UITextField!
    
    @IBOutlet weak var lblAgree: UILabel!
    @IBOutlet weak var btnCreate: UIButton!
    
    var alertMeDropDown = DropDown()
    var isDropDown = DropDown()
    
    var strAlertFlag: String = ""
    
    var isFromEdit:Bool = false
    var objStockDetail = AssetsObject.init([:])
    var objEditAlert = AlertObject.init([:])
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupAlertSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        var strSymbol:String = ""
        
        if self.isFromEdit == false {
            strSymbol = self.objStockDetail.symbol
        } else {
            strSymbol = self.objEditAlert.alertSharesymbol
        }
        
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
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateAlertBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateAlertTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }

    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(SetAlertVC.getAlertBarData(notification:)), name: NSNotification.Name(kUpdateAlertBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SetAlertVC.getAlertTradesData(notification:)), name: NSNotification.Name(kUpdateAlertTrades), object: nil)
    }
    
    @objc func getAlertBarData(notification: Notification) {
        debugPrint("=====Getting Alert Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if self.isFromEdit == false {
                if symbol == self.objStockDetail.symbol {
                    self.objStockDetail.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.objStockDetail.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.objStockDetail.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            } else {
                if symbol == self.objEditAlert.alertSharesymbol {
                    self.objEditAlert.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.objEditAlert.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.objEditAlert.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.objEditAlert.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.objEditAlert.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.objEditAlert.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                }
            }
        }
    }
    
    @objc func getAlertTradesData(notification: Notification) {
        debugPrint("=====Getting Alert Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if self.isFromEdit == false {
                    if symbol == self.objStockDetail.symbol {
                        self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        self.objStockDetail.plVariationValue = self.objStockDetail.current_price - self.objStockDetail.prev_close_price//closePrice //self.objStockDetail.current_price - self.objStockDetail.openPrice
                        self.objStockDetail.plVariationPer = (self.objStockDetail.plVariationValue * 100) / self.objStockDetail.prev_close_price//closePrice
                        
                        DispatchQueue.main.async {
                            self.setupLiveData()
                        }
                    }
                } else {
                    if symbol == self.objEditAlert.alertSharesymbol {
                        self.objEditAlert.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                        self.objEditAlert.plVariationValue = self.objEditAlert.current_price - self.objEditAlert.prev_close_price//closePrice //self.objEditAlert.current_price - self.objEditAlert.openPrice
                        self.objEditAlert.plVariationPer = (self.objEditAlert.plVariationValue * 100) / self.objEditAlert.prev_close_price//closePrice
                        
                        DispatchQueue.main.async {
                            self.setupLiveData()
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
            
            self.btnCreate.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblAlertMeTitle.textColor = UIColor.labelTextColor
        self.txtAlertMe.textColor = UIColor.textFieldTextColor
        
        self.lblOfTitle.textColor = UIColor.labelTextColor
        self.txtOf.textColor = UIColor.textFieldTextColor
        
        self.lblIsTitle.textColor = UIColor.labelTextColor
        self.txtIs.textColor = UIColor.textFieldTextColor
        
        self.txtAlertMe.isUserInteractionEnabled = false
        self.txtOf.isUserInteractionEnabled = false
        self.txtIs.isUserInteractionEnabled = false
        
        self.lblStock.textColor = UIColor.tblMarketDepthContent
        
        self.txtAmount.textColor = UIColor.textFieldTextColor
        
        self.lblTriggerTitle.textColor = UIColor.labelTextColor
        self.txtTrigger.textColor = UIColor.textFieldTextColor
        
        self.lblAgree.textColor = UIColor.taxExemptionAgreeTerms
        
//        var strSymbol:String = ""
        
        if self.isFromEdit == false {
            self.btnCreate.setTitle("Create", for: [])
//            strSymbol = self.objStockDetail.symbol
        } else {
            self.btnCreate.setTitle("Update", for: [])
//            strSymbol = self.objEditAlert.alertSharesymbol
        }
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupAlertSocketEvents()
//        SocketIOManager.shared.socket?.connect()
//
//        var objBars = Dictionary<String,AnyObject>()
//        objBars["symbol"] = strSymbol as AnyObject
//        objBars["type"] = EMIT_TYPE_BARS as AnyObject
//        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            var objTrades = Dictionary<String,AnyObject>()
//            objTrades["symbol"] = strSymbol as AnyObject
//            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//        }
        
        //SET DATA
        if self.isFromEdit == false {
            self.lblStockName.text = self.objStockDetail.symbol
            self.lblStockCompany.text = self.objStockDetail.name
            
            self.setupLiveData()
            
            self.txtAlertMe.text = "Buy"
            self.txtOf.text = self.objStockDetail.symbol
            self.txtIs.text = "GREATER THAN EQUAL TO (>=)"
                    
            if self.txtIs.text == "GREATER THAN EQUAL TO (>=)" {
                self.strAlertFlag = "Greater than equal"
            } else {
                self.strAlertFlag = "Less than equal"
            }
        } else {
            self.lblStockName.text = self.objEditAlert.alertSharesymbol
            self.lblStockCompany.text = self.objEditAlert.alertShareName
            
            self.setupLiveData()
            
            self.txtAlertMe.text = self.objEditAlert.alertSide
            self.txtOf.text = self.objEditAlert.alertSharesymbol
            self.strAlertFlag = self.objEditAlert.alertFlag
            
            if self.strAlertFlag == "Greater than equal" {
                self.txtIs.text = "GREATER THAN EQUAL TO (>=)"
            } else {
                self.txtIs.text = "LESS THAN EQUAL TO (<=)"
            }
            
            self.txtAmount.text = self.objEditAlert.alertPrice
            self.txtTrigger.text = self.objEditAlert.alertName
        }
        
        self.lblAgree.text = "I agree Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been."

        self.setupAlertMeDropDown()
        self.setupIsDropDown()
    }
    
    //SET LIVE DATA
    func setupLiveData() {
        if self.isFromEdit == false {
            self.lblStockPrice.text = "$" + String(format: "%.2f", self.objStockDetail.current_price)
            
            var strVariation: String = ""
            
            if self.objStockDetail.plVariationPer > 0 {
                strVariation = "+\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
            } else if self.objStockDetail.plVariationPer < 0 {
                strVariation = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
            } else {
                strVariation = "\(String(format: "%.2f", self.objStockDetail.plVariationValue)) (0.00%)"
            }
            
            if self.objStockDetail.plVariationValue > 0 {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x81CF01))
            } else if self.objStockDetail.plVariationValue < 0 {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
            } else {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objStockDetail.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x676767))
            }
        } else {
            self.lblStockPrice.text = "$" + String(format: "%.2f", self.objEditAlert.current_price)
            
            var strVariation: String = ""
            
            if self.objEditAlert.plVariationPer > 0 {
                strVariation = "+\(String(format: "%.2f", self.objEditAlert.plVariationValue)) (+\(String(format: "%.2f", self.objEditAlert.plVariationPer))%)"
            } else if self.objEditAlert.plVariationPer < 0 {
                strVariation = "\(String(format: "%.2f", self.objEditAlert.plVariationValue)) (\(String(format: "%.2f", self.objEditAlert.plVariationPer))%)"
            } else {
                strVariation = "\(String(format: "%.2f", self.objEditAlert.plVariationValue)) (0.00%)"
            }
            
            if self.objEditAlert.plVariationValue > 0 {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objEditAlert.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x81CF01))
            } else if self.objEditAlert.plVariationValue < 0 {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objEditAlert.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0xFE3D2F))
            } else {
                self.lblStockVariation.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: self.objEditAlert.exchange + "  ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strFirstColor: UIColor.black, strSecond: strVariation, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblStockVariation.font.pointSize)!, strSecondColor: UIColor.init(hex: 0x676767))
            }
        }
    }
    
    //MARK: - HELPER -
    
    func setupAlertMeDropDown() {
        self.alertMeDropDown = DropDown()
        let arrAlertMe = ["Buy", "Sell"]
        
        self.alertMeDropDown.backgroundColor = .white
        self.alertMeDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.alertMeDropDown.textColor = .black
        self.alertMeDropDown.selectedTextColor = .white
        
        self.alertMeDropDown.anchorView = self.viewAlertMe
        self.alertMeDropDown.bottomOffset = CGPoint(x: 0, y:((self.alertMeDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.alertMeDropDown.dataSource = arrAlertMe
        self.alertMeDropDown.direction = .bottom
        self.alertMeDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.alertMeDropDown.cellHeight = 42
        
        if self.txtAlertMe.text != "" {
            guard let index = arrAlertMe.firstIndex(of: self.txtAlertMe.text!) else { return }
            self.alertMeDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.alertMeDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtAlertMe.text = item
        }
    }
    
    func setupIsDropDown() {
        self.isDropDown = DropDown()
        let arrIs = ["GREATER THAN EQUAL TO (>=)", "LESS THAN EQUAL TO (<=)"]
        
        self.isDropDown.backgroundColor = .white
        self.isDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.isDropDown.textColor = .black
        self.isDropDown.selectedTextColor = .white
        
        self.isDropDown.anchorView = self.viewIs
        self.isDropDown.bottomOffset = CGPoint(x: 0, y:((self.isDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.isDropDown.dataSource = arrIs
        self.isDropDown.direction = .bottom
        self.isDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.isDropDown.cellHeight = 42
        
        if self.txtIs.text != "" {
            guard let index = arrIs.firstIndex(of: self.txtIs.text!) else { return }
            self.isDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.isDropDown.selectionAction = { (index: Int, item: String) in
            self.txtIs.text = item
            
            if self.txtIs.text == "GREATER THAN EQUAL TO (>=)" {
                self.strAlertFlag = "Greater than equal"
            } else {
                self.strAlertFlag = "Less than equal"
            }
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAlertMeClick(_ sender: UIButton) {
        self.alertMeDropDown.show()
    }
    
    @IBAction func btnIsClick(_ sender: UIButton) {
        self.isDropDown.show()
    }
    
    @IBAction func btnEditClick(_ sender: UIButton) {
        self.view.endEditing(true)
    }
    
    @IBAction func btnCreateClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let amount = self.txtAmount.text ?? ""
        var amountValue:Double = 0.0
        amountValue = (amount as NSString).doubleValue
        
        if self.txtAlertMe.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Alert type is required")
        }
        else if self.txtOf.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Stock name is required")
        }
        else if self.strAlertFlag == "" {
            GlobalData.shared.showSystemToastMesage(message: "Alert flag is required")
        }
        else if self.txtAmount.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Alert price is required")
        }
        else if amountValue < 0 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Alert price should be greater than 0")
        }
        else if self.txtTrigger.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Alert name is required")
        }
        else {
            if self.isFromEdit == false {
                self.btnCreate.isUserInteractionEnabled = false
                self.callCreateAlertAPI()
            } else {
                self.btnCreate.isUserInteractionEnabled = false
                self.callUpdateAlertAPI()
            }
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension SetAlertVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        let text: NSString = textField.text! as NSString
        let resultString = text.replacingCharacters(in: range, with: string)
        
        if textField == self.txtAmount {
            let textArray = resultString.components(separatedBy: ".")
            
            if textArray.count == 2 {
                let lastString = textArray.last
                if lastString!.count > 2 { //Check number of decimal places
                    return false
                }
            }
            if textArray.count > 2 { //Allow only one "."
                return false
            }
        }
        
        return true
    }
}

//MARK: - API CALL -

extension SetAlertVC {
    //CREATE ALERT
    func callCreateAlertAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["alertShareSymbol"] = self.objStockDetail.symbol
        params["alertName"] = self.txtTrigger.text ?? ""
        params["alertSide"] = self.txtAlertMe.text ?? ""
        params["alertFlag"] = self.strAlertFlag
        params["alertPrice"] = self.txtAmount.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_ALERT, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        strongSelf.btnCreate.isUserInteractionEnabled = true
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnCreate.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnCreate.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnCreate.isUserInteractionEnabled = true
        }
    }
    
    //UPDATE ALERT
    func callUpdateAlertAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_ALERT + "/" + self.objEditAlert._id
        
        var params: [String:Any] = [:]
        params["alertShareSymbol"] = self.objEditAlert.alertSharesymbol
        params["alertName"] = self.txtTrigger.text ?? ""
        params["alertSide"] = self.txtAlertMe.text ?? ""
        params["alertFlag"] = self.strAlertFlag
        params["alertPrice"] = self.txtAmount.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPATCHURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let alert = response["data"] as? Dictionary<String, Any> {
                            let objAlert = AlertObject.init(alert)
                                                        
                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            
                            strongSelf.btnCreate.isUserInteractionEnabled = true

                            var dict = [String: AlertObject]()
                            dict["data"] = objAlert
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateAlert), object: nil, userInfo: dict)
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnCreate.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnCreate.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnCreate.isUserInteractionEnabled = true
        }
    }
}
