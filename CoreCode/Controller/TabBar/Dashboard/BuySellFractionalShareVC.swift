//
//  BuySellFractionalShareVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 31/01/22.
//

import UIKit
import SwiftyJSON

class BuySellFractionalShareVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblFractionalShare: UILabel!
    @IBOutlet weak var txtAmount: NoPopUpTextField!
    @IBOutlet weak var lblAvailableBal: UILabel!
    @IBOutlet weak var btnReview: UIButton!
    
    var isFromPortfolio:Bool = false
    var isFromBuy:Bool = false
    var objPortfolio: PortfolioObject!
    var objStockDetail = AssetsObject.init([:])
        
    var arrHoldingList: [PortfolioObject] = []
    
    var isFromEdit:Bool = false
    var objOrderDetail = OrderObject.init([:])
    
    var availableBalance: Double = 0.0

    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewContent.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
            self.viewContent.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.btnReview.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblFractionalShare.textColor = UIColor.tblMarketDepthContent
        self.txtAmount.textColor = UIColor.textFieldTextColor
        self.lblAvailableBal.textColor = UIColor.tblMarketDepthContent
        
        if self.isFromBuy {
            self.lblStockName.textColor = UIColor.init(hex: 0xED1C24)
            self.lblStockName.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblStockName.font.pointSize)
            
            //SET DATA
            let buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue.clean
            self.availableBalance = (buyingPower as NSString).doubleValue
                        
            self.lblStockName.text = self.objStockDetail.symbol
            self.lblFractionalShare.text = "Fractional Shares"
            self.lblAvailableBal.text = "$\(self.availableBalance) available to buy \(self.objStockDetail.symbol)"
        } else {
            self.lblStockName.textColor = UIColor.labelTextColor
            self.lblStockName.font = UIFont.init(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: self.lblStockName.font.pointSize - 8)

            //SET DATA
            if self.isFromPortfolio == false {
                if let objPort = self.arrHoldingList.filter({ $0.symbol == self.objStockDetail.symbol}).first {
                    let qty = (objPort.qty as NSString).doubleValue
                    let balance = qty * self.objStockDetail.current_price
                    let strBal = balance.clean
                    self.availableBalance = (strBal as NSString).doubleValue //qty * lastDayPrice
                } else {
                    let buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue.clean
                    self.availableBalance = (buyingPower as NSString).doubleValue
                }
            } else {
                let qty = (self.objPortfolio.qty as NSString).doubleValue
                let lastDayPrice = (self.objPortfolio.lastday_price as NSString).doubleValue
                let balance = qty * lastDayPrice
                let strBal = balance.clean
                self.availableBalance = (strBal as NSString).doubleValue //qty * lastDayPrice
            }
            
            self.lblStockName.text = "Limit Price"
            self.lblFractionalShare.text = "Specify the minimum amount you're willing to receive per share of F."
            self.lblAvailableBal.text = "$\(String(format: "%.2f", self.availableBalance)) available to sell \(self.objStockDetail.symbol)"
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnReviewClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let amount = self.txtAmount.text ?? ""
        var amountValue:Double = 0.0
        amountValue = (amount as NSString).doubleValue
        
        if self.txtAmount.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Amount is required")
        }
        else if amountValue < 0 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Amount should be greater than 0")
        }
        else {
            guard let inputValue = Double(self.txtAmount.text ?? "") else { return }
            
            if inputValue > self.availableBalance {
                GlobalData.shared.showDarkStyleToastMesage(message: "Available balance is not enough")
            } else {
                let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "FractionalShareVC") as! FractionalShareVC
                controller.isFromPortfolio = self.isFromPortfolio
                controller.isFromBuy = self.isFromBuy
                controller.strAmount = self.txtAmount.text ?? ""
                controller.objPortfolio = self.objPortfolio
                controller.objStockDetail = self.objStockDetail
                controller.arrHoldingList = self.arrHoldingList
                controller.isFromEdit = self.isFromEdit
                controller.objOrderDetail = self.objOrderDetail
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension BuySellFractionalShareVC: UITextFieldDelegate {
    
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtAmount {
            guard let inputValue = Double(self.txtAmount.text ?? "") else { return }
            
            if inputValue > self.availableBalance {
                GlobalData.shared.showDarkStyleToastMesage(message: "Available balance is not enough")
            }
        }
    }
}
