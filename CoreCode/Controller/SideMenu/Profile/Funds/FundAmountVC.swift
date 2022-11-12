//
//  FundAmountVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/03/22.
//

import UIKit
import SwiftyJSON

class FundAmountVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewDetailsMoney: UIView!
    @IBOutlet weak var lblTotal: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCommision: UILabel!
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtAmount: NoPopUpTextField!
    @IBOutlet weak var lblCurrency: UILabel!
    //    @IBOutlet weak var lblCommission: UILabel!
    
    @IBOutlet weak var stackViewButtons: UIStackView!
    @IBOutlet weak var btnFirstAmount: UIButton!
    @IBOutlet weak var btnSecondAmount: UIButton!
    @IBOutlet weak var btnThirdAmount: UIButton!
    @IBOutlet weak var btnForthAmount: UIButton!
    @IBOutlet weak var lblLocalCurrencyValue: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    
    var isFromMenu: Bool = false
    var isFromAdd:Bool = false
    
    var currencyAmount: Double = 0.0
    var commissionValue: String = ""
    
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
            
            self.btnFirstAmount.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.btnSecondAmount.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.btnThirdAmount.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.btnForthAmount.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.btnNext.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.txtAmount.textColor = UIColor.textFieldTextColor
        self.lblCurrency.textColor = UIColor.labelTextColor
        self.lblLocalCurrencyValue.textColor = UIColor.tblMarketDepthContent
        
        if self.isFromMenu == true {
            self.btnMenu.isHidden = false
            self.btnBack.isHidden = true
        } else {
            self.btnMenu.isHidden = true
            self.btnBack.isHidden = false
        }
        
        self.lblCurrency.text = "USD"
        self.btnFirstAmount.setTitle("+$25", for: [])
        self.btnSecondAmount.setTitle("+$50", for: [])
        self.btnThirdAmount.setTitle("+$100", for: [])
        self.btnForthAmount.setTitle("+$200", for: [])
        
        self.lblLocalCurrencyValue.text = "\(objUserDetail.currency) : \(convertThousand(value: currencyAmount))"
        
        
        if self.isFromAdd {
            self.lblTitle.text = "Add Funds"
            
            self.viewDetailsMoney.isHidden = false
            self.stackViewButtons.isHidden = false
            self.lblLocalCurrencyValue.isHidden = false
        } else {
            self.lblTitle.text = "Withdraw Funds"
            
            self.viewDetailsMoney.isHidden = true
            self.stackViewButtons.isHidden = true
            self.lblLocalCurrencyValue.isHidden = true
        }
        
        self.callGetCommissionAPI()
        
        if self.commissionValue != "" {
            self.lblCommision.text = "$\(convertThousand(value: Double(self.commissionValue) ?? 0.0))"
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnStackviewAmountClick(_ sender: UIButton) {
        if sender.tag == 1 {
            self.txtAmount.text = self.btnFirstAmount.titleLabel?.text?.replacingOccurrences(of: "+$", with: "")
        } else if sender.tag == 2 {
            self.txtAmount.text = self.btnSecondAmount.titleLabel?.text?.replacingOccurrences(of: "+$", with: "")
        } else if sender.tag == 3 {
            self.txtAmount.text = self.btnThirdAmount.titleLabel?.text?.replacingOccurrences(of: "+$", with: "")
        } else {
            self.txtAmount.text = self.btnForthAmount.titleLabel?.text?.replacingOccurrences(of: "+$", with: "")
        }
        
        let total = (Double(txtAmount.text ?? "0.0") ?? 0.0) + (Double(commissionValue) ?? 0.0)
        self.callCurrencyConverterAPI(Amount: "\(total)" )
    }
    
    @IBAction func btnNextClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let total = (Double(txtAmount.text ?? "0.0") ?? 0.0) + (Double(commissionValue) ?? 0.0)
        let amount = "\(total)"
        var amountValue:Double = 0.0
        amountValue = (amount as NSString).doubleValue
        
        if self.txtAmount.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Amount is required")
        }
        else if amountValue < 0 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Amount should be greater than 0")
        }
        else {
            if isFromAdd {
                let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundTypeVC") as! FundTypeVC
                controller.isFromAdd = self.isFromAdd
                controller.strAmount = "\(total)"
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else {
                let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundTypeVC") as! FundTypeVC
                controller.isFromAdd = self.isFromAdd
                controller.strAmount = "\(txtAmount.text ?? "0")"
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension FundAmountVC: UITextFieldDelegate {
    
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
        if self.isFromAdd {
            if textField.text != "" && textField.text != "0"{
                let total = (Double(txtAmount.text ?? "0.0") ?? 0.0) + (Double(commissionValue) ?? 0.0)
                lblAmount.text = "$\(Double(textField.text ?? "0.0") ?? 0.0)"
                lblTotal.text = "$\(total)"
                self.callCurrencyConverterAPI(Amount: "\(total)")
            } else {
                self.currencyAmount = 0.0
                lblAmount.text = "$\(Double(textField.text ?? "0.0") ?? 0.0)"
                lblTotal.text = "$\((Double(0.0)))"
                self.lblLocalCurrencyValue.text = "\(objUserDetail.currency) : \(convertThousand(value: currencyAmount))"
            }
        }
    }
}

//MARK: - API CALL -

extension FundAmountVC {
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
                            strongSelf.commissionValue = "\(payload["addFundCommission"] ?? "")"
                            strongSelf.lblCommision.text = "$\(convertThousand(value: Double(strongSelf.commissionValue) ?? 0.0))"
                            //                            strongSelf.lblCommision.text = "$\(strongSelf.commissionValue)"
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
    
    //CURRENCY CONVERTER
    func callCurrencyConverterAPI(Amount amount: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["currency_from"] = "USD"
        params["currency_to"] = objUserDetail.currency
        params["amount"] = amount
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.CURRENCY_CONVERTER, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let amount = payloadData["converted_amount"] as? Double {
                                strongSelf.lblAmount.text = "$\(convertThousand(value: Double(strongSelf.txtAmount.text ?? "0.0") ?? 0.0))"
                                let totalAmount = (Double(strongSelf.txtAmount.text ?? "") ?? 0.0) + (Double(strongSelf.commissionValue) ?? 0.0)
                                strongSelf.lblTotal.text = "$\(totalAmount.calculator)"
                                strongSelf.currencyAmount = amount
                                strongSelf.lblLocalCurrencyValue.text = "\(objUserDetail.currency) : \(convertThousand(value: strongSelf.currencyAmount))"
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.lblAmount.text = "$\(convertThousand(value: Double(strongSelf.txtAmount.text ?? "0.0") ?? 0.0))"
                        let totalAmount = (Double(strongSelf.txtAmount.text ?? "") ?? 0.0) + (Double(strongSelf.commissionValue) ?? 0.0)
                        strongSelf.lblTotal.text = "$\(totalAmount.calculator)"
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
