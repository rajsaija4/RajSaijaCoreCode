//
//  NewMarketVc.swift
//  Prospuh
//
//  Created by RAJ J SAIJA on 26/09/22.
//

import UIKit
import DropDown
import SDWebImage
import SwiftyJSON


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

class NewMarketVc: BaseVC,UITextViewDelegate {
    
    @IBOutlet weak var btnEnterValue: UIButton!
    @IBOutlet weak var lblNoOfShares: UILabel!
    @IBOutlet weak var popUpScrollView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnBuySellOrder: UIButton!
    @IBOutlet weak var stackLimitPrice: UIStackView!
    @IBOutlet weak var stackExpiration: UIStackView!
    @IBOutlet weak var viewImageDialog: UIView!
    @IBOutlet weak var scrollSwitch: UISlider!
    @IBOutlet weak var txtPriceSwitch: UISwitch!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtSharePrice: UILabel!
    @IBOutlet weak var lblSharesPrice: UILabel!
    @IBOutlet weak var imgMainShare: UIImageView!
    @IBOutlet weak var lblMainShareName: UILabel!
    @IBOutlet weak var lblDialogCommission: UILabel!
    @IBOutlet weak var lblDialogExpiration: UILabel!
    @IBOutlet weak var lblDialogLimitPrice: UILabel!
    @IBOutlet weak var lblDialogCost: UILabel!
    @IBOutlet weak var lblDialogNumberOfShares: UILabel!
    @IBOutlet weak var lblDialogOrderType: UILabel!
    @IBOutlet weak var lblDialogBuyshareName: UILabel!
    @IBOutlet weak var lblDialogShareName: UILabel!
    @IBOutlet weak var imgDialog: UIImageView!
    @IBOutlet weak var viewScroll: UIScrollView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var mainScrollView: UIView!
    @IBOutlet weak var btnMarket: UIButton!
    @IBOutlet weak var viewMarketLimit: UIView!
    @IBOutlet weak var viewbtnlimit: UIView!
    @IBOutlet weak var btnLimit: UIButton!
    @IBOutlet weak var viewNumberOfShares: UIView!
    @IBOutlet weak var viewSummary: UIView!
    @IBOutlet weak var viewLimit: UIView!
    @IBOutlet weak var txtShareCount: UITextField!
    @IBOutlet weak var viewValidityBuy: UIView!
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var txtValidity: UITextField!
    var count = 0
    var isSelectedBuy:Bool = true
    var isFromModify:Bool = false
    var objOrderDetail = OrderObject.init([:])
    var objStockDetail = AssetsObject.init([:])
    var arrHoldingList: [PortfolioObject] = []
    
    var validityDropDown = DropDown()
    var commissionValue: String = ""
    var isFractionOrder:Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        callGetCommissionAPI()
        viewPopup.isHidden = true
        if isSelectedBuy {
            lblMainShareName.text = "Buy \(self.objStockDetail.symbol)"
            lblDialogBuyshareName.text = "Buy \(self.objStockDetail.symbol)"
            btnBuySellOrder.setTitle("Send Buy Order", for: .normal)

        }
        else {
            lblMainShareName.text = "Sell \(self.objStockDetail.symbol)"
            lblDialogBuyshareName.text = "Sell \(self.objStockDetail.symbol)"
            btnBuySellOrder.setTitle("Send Sell Order", for: .normal)
        }
        
        lblDialogShareName.text = "\(self.objStockDetail.name)"
        lblSharesPrice.text = "$\(convertThousand(value: objStockDetail.objSnapshot.objDailyBar.c))"
        
        if self.objStockDetail.image == "" {
            self.viewStock.backgroundColor = UIColor.black
            self.viewImageDialog.backgroundColor = UIColor.init(hex: 0x27B1FC)

            let dpName = self.objStockDetail.symbol.prefix(1)
            self.imgMainShare.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgMainShare.frame.size.width, imageHeight: self.imgMainShare.frame.size.height, name: "\(dpName)")
            
            self.imgDialog.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgDialog.frame.size.width, imageHeight: self.imgDialog.frame.size.height, name: "\(dpName)")
        } else {
            self.viewStock.backgroundColor = UIColor.white
            self.viewImageDialog.backgroundColor = UIColor.init(hex: 0x27B1FC)

            self.imgMainShare.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgMainShare.sd_setImage(with: URL(string: self.objStockDetail.image), placeholderImage: nil)
            
            self.imgDialog.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgDialog.sd_setImage(with: URL(string: self.objStockDetail.image), placeholderImage: nil)
        }
//        popUpScrollView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 24)
//        scrollView.roundCorners(corners: [.bottomLeft,.bottomRight], radius: 24)
        mainScrollView.roundCorners(corners: [.topLeft,.topRight], radius: 24)
        if count == 0 {
            viewLimit.isHidden = true
            viewSummary.isHidden = false
            btnLimit.setTitleColor(UIColor(named: "newLimit"), for: .normal)
            viewMarketLimit.isHidden = false
            btnMarket.setTitleColor(UIColor(hexString: "81CF01"), for: .normal)
            viewbtnlimit.isHidden = true
            stackLimitPrice.isHidden = true
            stackExpiration.isHidden = true
        }
        else {
            viewSummary.isHidden = true
            viewLimit.isHidden = false
            btnMarket.setTitleColor(UIColor(named: "newLimit"), for: .normal)
            viewbtnlimit.isHidden = false
            btnLimit.setTitleColor(UIColor(hexString: "81CF01"), for: .normal)
            viewMarketLimit.isHidden = true
            stackLimitPrice.isHidden = false
            stackExpiration.isHidden = false
        }
        
        if btnEnterValue.isSelected {
            self.txtShareCount.text = "$\(Int(scrollSwitch.value))"
        }
        else {
            self.txtShareCount.text = "\(Int(scrollSwitch.value))"
        }
        
        txtSharePrice.text = "$\(convertThousand(value: (Double(txtShareCount.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c))"
        self.txtValidity.text = "day"
        setupValidityDropDown()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupBuySellSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
//        var objBars = Dictionary<String,AnyObject>()
//        objBars["symbol"] = self.objStockDetail.symbol as AnyObject
//        objBars["type"] = EMIT_TYPE_BARS as AnyObject
//        SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
        
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
//        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateBuySellBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateBuySellTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    func SetupAllSocketNotification() {
//        NotificationCenter.default.addObserver(self, selector: #selector(BuySellVC.getBuySellBarData(notification:)), name: NSNotification.Name(kUpdateBuySellBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewMarketVc.getBuySellTradesData(notification:)), name: NSNotification.Name(kUpdateBuySellTrades), object: nil)
    }
    
    @objc func getBuySellTradesData(notification: Notification) {
        debugPrint("=====Getting BuySell Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.objStockDetail.symbol {
                    self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    DispatchQueue.main.async {
                        self.lblSharesPrice.text = "$\(convertThousand(value: self.objStockDetail.current_price))"
                        self.txtSharePrice.text = "$\(convertThousand(value: (Double(self.txtShareCount.text ?? "0.0") ?? 0.0) * self.objStockDetail.current_price))"
                        self.lblDialogCost.text = "$\(convertThousand(value: (Double(self.txtShareCount.text ?? "0.0") ?? 0.0) * self.objStockDetail.current_price))"
                    }
                }
            }
        }
    }

    func setupValidityDropDown() {
        self.validityDropDown = DropDown()
        let arrValidity = ["day", "gtc", "opg", "cls", "ioc", "fok"]
        
        self.validityDropDown.backgroundColor = .white
        self.validityDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.validityDropDown.textColor = .black
        self.validityDropDown.selectedTextColor = .white
        
        self.validityDropDown.anchorView = self.viewValidityBuy
        self.validityDropDown.bottomOffset = CGPoint(x: 0, y:((self.validityDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.validityDropDown.dataSource = arrValidity
        self.validityDropDown.direction = .bottom
        self.validityDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.validityDropDown.cellHeight = 42
        
        if self.txtValidity.text != "" {
            guard let index = arrValidity.firstIndex(of: self.txtValidity.text!) else { return }
            self.validityDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.validityDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtValidity.text = item
        }
    }
    
    @IBAction func onDragSlideBar(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        if btnEnterValue.isSelected {
            txtShareCount.text = "$\(currentValue)"

        }
        else {
            txtShareCount.text = "\(currentValue)"

        }
        calculateQuentityPerPrice()
    }
    
    @IBAction func onClickExpiration(_ sender: UIButton) {
        self.validityDropDown.show()
    }
    
    
    @IBAction func txtShareAction(_ sender: UITextField) {
        if sender.text == "" {
            sender.text = "1"
//            txtSharePrice.text = "$\((Double(sender.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c)"
        }
//        else {
//            let num = Int(0)
//            let num2 = Int(Double(sender.text ?? "0.0") ?? 0.0)
//            if num2 > num {
//                txtSharePrice.text = "$\((Double(sender.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c)"
//            }
//            else {
//                sender.text = "1"
//                txtSharePrice.text = "$\((Double(sender.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c)"
//            }
//        }
        
        calculateQuentityPerPrice()
        
    }
        
    @IBAction func onPessBtnNoPad(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        isFractionOrder = sender.isSelected
        handleFractionToggle()
    }
    
    func handleFractionToggle() {
        if isFractionOrder {
            lblNoOfShares.text = "Value"
            self.txtShareCount.text = "$\(Int(scrollSwitch.value))"
            calculateQuentityPerPrice()
        }
        else {
            lblNoOfShares.text = "Number Of Shares"
            self.txtShareCount.text = "\(Int(scrollSwitch.value))"
            calculateQuentityPerPrice()
        }
    }
    
    func setupScrollToggel(){
        
    }
        
    func calculateQuentityPerPrice() {
        if isFractionOrder {
            var character = txtShareCount.text?.replacingOccurrences(of: "$", with: "")
            var doubleCharacter = Double(character?.removingWhitespaces() ?? "0.0")
            txtSharePrice.text = "\(convertThousand(value: (Double(doubleCharacter ?? 0.0) ?? 0.0) / objStockDetail.objSnapshot.objDailyBar.c))"
            
        }
        else {
            txtSharePrice.text = "$\(convertThousand(value: (Double(txtShareCount.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c))"
        }
    }
    
    @IBAction func onPressbtnMarket(_ sender: UIButton) {
        count = 0
        btnEnterValue.isHidden = false
        viewLimit.isHidden = true
        viewSummary.isHidden = false
        btnLimit.setTitleColor(UIColor(named: "newLimit"), for: .normal)
        viewMarketLimit.isHidden = false
        sender.setTitleColor(UIColor(hexString: "81CF01"), for: .normal)
        viewbtnlimit.isHidden = true
        stackLimitPrice.isHidden = true
        stackExpiration.isHidden = true
        handleFractionToggle()
                
    }
    
    @IBAction func onPressbtnLimit(_ sender: UIButton) {
        isFractionOrder = false
        btnEnterValue.isHidden = true
        count = 1
        viewSummary.isHidden = true
        viewLimit.isHidden = false
        btnMarket.setTitleColor(UIColor(named: "newLimit"), for: .normal)
        viewbtnlimit.isHidden = false
        sender.setTitleColor(UIColor(hexString: "81CF01"), for: .normal)
        viewMarketLimit.isHidden = true
        stackLimitPrice.isHidden = false
        stackExpiration.isHidden = false
        handleFractionToggle()
    }
    
    @IBAction func onExitTxtPrice(_ sender: UITextField) {
            let num = Double(0)
            let num2 = Double(sender.text ?? "0.0") ?? 0.0
            if num2 > num {
                
            }
            else {
                sender.text = ""
                GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Price Value More Then Zero")
            }
    }
    
    
    @IBAction func onClickMainClose(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClickOrderSummery(_ sender: UIButton) {
        guard txtShareCount.text != "" && txtShareCount.text != "0" else {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Valid Share Quentity")
            return
        }

        if isSelectedBuy {
            lblDialogOrderType.text = "Market Buy"
        }
        else {
            lblDialogOrderType.text = "Market Sell"
        }
        var character = txtShareCount.text?.replacingOccurrences(of: "$", with: "")
        var doubleCharacter = Double(character?.removingWhitespaces() ?? "0.0")

        lblDialogCost.text = "$\(convertThousand(value: (Double(doubleCharacter ?? 0.0) ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c))"
        lblDialogLimitPrice.text = "$\(txtPrice.text ?? "0")"
        lblDialogExpiration.text = txtValidity.text
        if isFractionOrder {
            lblDialogCost.text = "\(txtShareCount.text ?? "")"
            lblDialogNumberOfShares.text = "\(convertThousand(value: (Double(doubleCharacter  ?? 0.0) ?? 0.0) / objStockDetail.objSnapshot.objDailyBar.c))"

        }
        else {
            lblDialogNumberOfShares.text = txtShareCount.text
            var character = txtShareCount.text?.replacingOccurrences(of: "$", with: "")
            var doubleCharacter = Double(character?.removingWhitespaces() ?? "0.0")
            lblDialogCost.text = "$\(convertThousand(value: (Double(doubleCharacter ?? 0.0) ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c))"

        }
        viewPopup.isHidden = false
        viewScroll.alpha = 0.8
    }
    
    @IBAction func onClickReviewOrder(_ sender: UIButton) {
        guard txtShareCount.text != "" && txtShareCount.text != "0" else {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Valid Share Quentity")
            return
        }
        
        guard txtPrice.text != "" else {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Valid Limit Price")
            return
        }
            
        viewPopup.isHidden = false
        viewScroll.alpha = 0.8
        if isSelectedBuy {
            lblDialogOrderType.text = "Limited Buy"
        }
        else {
            lblDialogOrderType.text = "Limited Sell"
        }
        lblDialogNumberOfShares.text = txtShareCount.text
        lblDialogCost.text = "$\(convertThousand(value: (Double(txtShareCount.text ?? "0.0") ?? 0.0) * objStockDetail.objSnapshot.objDailyBar.c))"
        lblDialogLimitPrice.text = "$\(txtPrice.text ?? "0")"
        lblDialogExpiration.text = txtValidity.text
    }
    
    @IBAction func onClickClosePopup(_ sender: UIButton) {
        viewPopup.isHidden = true
        viewScroll.alpha = 0.8
    }
 
    @IBAction func onClickSendBuyOrder(_ sender: UIButton) {
        let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewSwipeVc") as! NewSwipeVc
        controller.isSelectedBuy = self.isSelectedBuy
        controller.isFromModify = self.isFromModify
        controller.objStockDetail = self.objStockDetail
        controller.objOrderDetail = self.objOrderDetail
        controller.arrHoldingList = self.arrHoldingList
        controller.count = self.count
        controller.shareCount = txtShareCount.text ?? "0"
        controller.limitPrice = txtPrice.text ?? "0.0"
        controller.expiration = lblDialogExpiration.text ?? ""
        controller.isFractionOrder = self.isFractionOrder
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: - API CALL -

extension NewMarketVc {
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
                            
                            strongSelf.lblDialogCommission.text = "$\(convertThousand(value: Double(strongSelf.commissionValue) ?? 0.0))"
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
