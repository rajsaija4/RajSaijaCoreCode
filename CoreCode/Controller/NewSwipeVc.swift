//

import UIKit
import SwiftyJSON
import SDWebImage

class NewSwipeVc: UIViewController {
    
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var lblPriceShare: UILabel!
    @IBOutlet weak var lblBuyShareName: UILabel!
    @IBOutlet weak var lblShareName: UILabel!
    @IBOutlet weak var imgShare: UIImageView!
    @IBOutlet weak var viewSwipeBuy: UIView!
    @IBOutlet weak var imgSwipeBuy: UIImageView!
    @IBOutlet weak var lblSwipeBuy: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var viewSubMain: UIView!
    var swipeBuyGesture = UISwipeGestureRecognizer()
    var isSelectedBuy:Bool = true
    var isFromModify:Bool = false
    var objOrderDetail = OrderObject.init([:])
    var objStockDetail = AssetsObject.init([:])
    var arrHoldingList: [PortfolioObject] = []
    var shareCount = String()
    var count = Int()
    var limitPrice = String()
    var expiration = String()
    var buyingPower = 0.0
    var isFractionOrder = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setupViewDetail()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupBuySellSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var objTrades = Dictionary<String,AnyObject>()
            objTrades["symbol"] = self.objStockDetail.symbol as AnyObject
            objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
        }
        
        self.SetupAllSocketNotification()
        
    }
    
    func SetupAllSocketNotification() {
        //        NotificationCenter.default.addObserver(self, selector: #selector(ModifyOrderVC.getModifyBuySellBarData(notification:)), name: NSNotification.Name(kUpdateModifyBuySellBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewSwipeVc.getModifyBuySellTradesData(notification:)), name: NSNotification.Name(kUpdateModifyBuySellTrades), object: nil)
    }
    
    @objc func getModifyBuySellTradesData(notification: Notification) {
        debugPrint("=====Getting Modify BuySell Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objStockDetail.symbol {
                    self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    DispatchQueue.main.async {
                        self.lblPriceShare.text = "$\(convertThousand(value: self.objStockDetail.current_price))"
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateModifyBuySellTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    @IBAction func onClickBackbtnTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupViewDetail() {
        self.buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
        
        if isSelectedBuy {
            lblShareName.text = "\(self.objStockDetail.name)"
            lblBuyShareName.text = "Buy \(self.objStockDetail.symbol)"
            lblSwipeBuy.text = "Swipe to Sell"
            
        }
        else {
            lblShareName.text = "\(self.objStockDetail.name)"
            lblBuyShareName.text = "Sell \(self.objStockDetail.symbol)"
            lblSwipeBuy.text = "Swipe to Sell"
            
        }
        
        if self.objStockDetail.image == "" {
            self.viewStock.backgroundColor = UIColor.black
            let dpName = self.objStockDetail.symbol.prefix(1)
            self.imgShare.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgShare.frame.size.width, imageHeight: self.imgShare.frame.size.height, name: "\(dpName)")
            
        } else {
            self.viewStock.backgroundColor = UIColor.white
            self.imgShare.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgShare.sd_setImage(with: URL(string: self.objStockDetail.image), placeholderImage: nil)
        }
        
        lblPriceShare.text = "$\(convertThousand(value: objStockDetail.objSnapshot.objDailyBar.c))"
        
        
        DispatchQueue.main.async {
            self.viewMain.roundCorners(corners: [.topRight,.topLeft], radius: 27)
            self.viewSubMain.roundCorners(corners: [.topRight,.topLeft], radius: 27)
            self.viewSwipeBuy.layer.cornerRadius = self.viewSwipeBuy.frame.height / 2.0
            self.viewSwipeBuy.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            
            let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right]
            
            for direction in directions {
                self.swipeBuyGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeBuyImage(_:)))
                self.imgSwipeBuy.addGestureRecognizer(self.swipeBuyGesture)
                self.swipeBuyGesture.direction = direction
                self.imgSwipeBuy.isUserInteractionEnabled = true
                self.imgSwipeBuy.isMultipleTouchEnabled = true
            }
            
            
        }
    }
    
    @objc func didSwipeBuyImage(_ sender : UISwipeGestureRecognizer) {
        self.view.endEditing(true)
        
        if isFromModify {
            UIView.animate(withDuration: 1.0) {
                if sender.direction == .right {
                    self.lblSwipeBuy.isHidden = true
                    self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                    
                    self.finalUpdateApiCall()
                }
                self.imgSwipeBuy.layoutIfNeeded()
                self.imgSwipeBuy.setNeedsDisplay()
            }
        }
        else {
            UIView.animate(withDuration: 1.0) {
                if sender.direction == .right {
                    self.lblSwipeBuy.isHidden = true
                    self.imgSwipeBuy.frame = CGRect(x: self.viewSwipeBuy.frame.size.width - self.imgSwipeBuy.frame.size.width - 8, y: self.imgSwipeBuy.frame.origin.y , width: self.imgSwipeBuy.frame.size.width, height: self.imgSwipeBuy.frame.size.height)
                    
                    self.finalApiCall()
                }
                self.imgSwipeBuy.layoutIfNeeded()
                self.imgSwipeBuy.setNeedsDisplay()
            }
        }
    }
}
    extension NewSwipeVc {
        
        func finalApiCall() {
            var orderSide = "buy"
            if isSelectedBuy {
                orderSide = "buy"
            }
            else {
                orderSide = "sell"
            }
            var market = "market"
            if count == 1 {
                market = "limit"
            }
            
            var params: [String:Any] = [:]
            
            if isFractionOrder {
                params["symbol"] = self.objStockDetail.symbol
                params["side"] = orderSide
                params["qty"] = ""
                params["notional"] = shareCount
                params["time_in_force"] = expiration
                params["type"] = market
                params["stop_price"] = ""
                params["stop_loss"] = ""
                params["limit_price"] = limitPrice
                params["trail_price"] = ""
                params["trail_percent"] = ""
                params["extended_hours"] = ""
                params["client_order_id"] = ""
                params["order_class"] = ""
                params["take_profit"] = ""
                params["commission"] = ""
                params["fractional"] = "true"
                
            }
            else {
                params["symbol"] = self.objStockDetail.symbol
                params["side"] = orderSide
                params["qty"] = shareCount
                params["notional"] = ""
                params["time_in_force"] = expiration
                params["type"] = market
                params["stop_price"] = ""
                params["stop_loss"] = ""
                params["limit_price"] = limitPrice
                params["trail_price"] = ""
                params["trail_percent"] = ""
                params["extended_hours"] = ""
                params["client_order_id"] = ""
                params["order_class"] = ""
                params["take_profit"] = ""
                params["commission"] = ""
                params["fractional"] = "false"
            }
            
            GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
            
            AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_ORDER, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
                guard let strongSelf = self else { return }
                
                GlobalData.shared.hideProgress()
                
                if JSONResponse != JSON.null {
                    if let response = JSONResponse.rawValue as? [String : Any] {
                        if response["status"] as! Int == successCode {
                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                            let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewCongretulationsVc") as! NewCongretulationsVc
                            controller.objStockDetail = self!.objStockDetail
                            if self!.isSelectedBuy {
                                controller.isSelectedBuy = true
                            }
                            else {
                                controller.isSelectedBuy = false
                                
                            }
                            self?.navigationController?.pushViewController(controller, animated: true)
                            
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
        
        
        func finalUpdateApiCall() {
            var orderSide = "buy"
            if isSelectedBuy {
                orderSide = "buy"
            }
            else {
                orderSide = "sell"
            }
            var market = "market"
            if count == 1 {
                market = "limit"
            }
            
            var params: [String:Any] = [:]
            
            if isFractionOrder {
                params["symbol"] = self.objStockDetail.symbol
                params["side"] = orderSide
                params["qty"] = ""
                params["notional"] = shareCount
                params["time_in_force"] = expiration
                params["type"] = market
                params["stop_price"] = ""
                params["stop_loss"] = ""
                params["limit_price"] = limitPrice
                params["trail_price"] = ""
                params["trail_percent"] = ""
                params["extended_hours"] = ""
                params["client_order_id"] = ""
                params["order_class"] = ""
                params["take_profit"] = ""
                params["commission"] = ""
                params["fractional"] = "true"
                
            }
            else {
                params["symbol"] = self.objStockDetail.symbol
                params["side"] = orderSide
                params["qty"] = shareCount
                params["notional"] = ""
                params["time_in_force"] = expiration
                params["type"] = market
                params["stop_price"] = ""
                params["stop_loss"] = ""
                params["limit_price"] = limitPrice
                params["trail_price"] = ""
                params["trail_percent"] = ""
                params["extended_hours"] = ""
                params["client_order_id"] = ""
                params["order_class"] = ""
                params["take_profit"] = ""
                params["commission"] = ""
                params["fractional"] = "false"
            }
            
            GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
            
            let strURL = Constants.URLS.UPDATE_ORDER + "/" + "\(self.objOrderDetail.id)"
            
            AFWrapper.shared.requestPATCHURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
                guard let strongSelf = self else { return }
                
                GlobalData.shared.hideProgress()
                
                if JSONResponse != JSON.null {
                    if let response = JSONResponse.rawValue as? [String : Any] {
                        if response["status"] as! Int == successCode {
                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            NotificationCenter.default.post(name: Notification.Name(kUpdateTradingAccount), object: nil)
                            let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewCongretulationsVc") as! NewCongretulationsVc
                            controller.objStockDetail = self!.objStockDetail
                            if self!.isSelectedBuy {
                                controller.isSelectedBuy = true
                            }
                            else {
                                controller.isSelectedBuy = false
                                
                            }
                            self?.navigationController?.pushViewController(controller, animated: true)
                            
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

