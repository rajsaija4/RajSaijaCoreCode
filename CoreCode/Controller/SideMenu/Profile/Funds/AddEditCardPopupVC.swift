//
//  AddEditCardPopupVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 01/04/22.
//

import UIKit
import DropDown
import SwiftyJSON

class AddEditCardPopupVC: UIViewController {

    // MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var btnAcceptConditions: UIButton!
    @IBOutlet weak var viewPopupSell: UIView!
    @IBOutlet weak var viewSellBG: UIView!
    @IBOutlet weak var viewSellBGsub1: UIView!
    @IBOutlet weak var viewSellBGsub2: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var txtCardNo: NoPopUpTextField!
    @IBOutlet weak var txtExpiryDate: NoPopUpTextField!
    @IBOutlet weak var viewCVV: UIView!
    @IBOutlet weak var txtCVV: NoPopUpTextField!
    @IBOutlet weak var txtCardName: NoPopUpTextField!
    @IBOutlet weak var viewCardType: UIView!
    @IBOutlet weak var txtCardType: UITextField!
    @IBOutlet weak var btnCardType: UIButton!
    @IBOutlet weak var lblConditions: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    
    var strPage: String = ""
    var objCardDetail = CardObject.init([:])
    var strAmount:String = ""
    var cardTypeDropDown = DropDown()
    
    let maxCardNumber = 19
    let maxExpiryNumber = 4
    let maxCVV = 4
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewSellBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewSellBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewSellBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewContent.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnAdd.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtCardNo.setLeftPadding()
        self.txtExpiryDate.setLeftPadding()
        self.txtCVV.setLeftPadding()
        self.txtCardName.setLeftPadding()
        self.txtCardType.setLeftPadding()
        
        self.txtCardType.isUserInteractionEnabled = false
        
        if self.strPage == "Add" {
            self.txtCardNo.isUserInteractionEnabled = true
            self.txtExpiryDate.isUserInteractionEnabled = true
            self.txtCVV.isUserInteractionEnabled = false
            self.txtCardName.isUserInteractionEnabled = true
            self.btnCardType.isUserInteractionEnabled = true
            
            self.viewCVV.alpha = 0.4
            
            self.btnAdd.setTitle("Add", for: [])
            self.lblConditions.isHidden = true
            self.btnAcceptConditions.isHidden = true
        }
        else if self.strPage == "Edit" {
            self.txtCardNo.isUserInteractionEnabled = true
            self.txtExpiryDate.isUserInteractionEnabled = true
            self.txtCVV.isUserInteractionEnabled = false
            self.txtCardName.isUserInteractionEnabled = true
            self.btnCardType.isUserInteractionEnabled = true
            
            self.viewCVV.alpha = 0.4
            
            self.txtCardNo.text = self.objCardDetail.cardNumber.replacingOccurrences(of: " ", with: "")
            self.txtExpiryDate.text = self.objCardDetail.cardExpiry
            self.txtCardName.text = self.objCardDetail.cardHolderName
            self.txtCardType.text = self.objCardDetail.cardType
            self.btnAdd.setTitle("Update", for: [])
            self.lblConditions.isHidden = true
            self.btnAcceptConditions.isHidden = true

        }
        else {
            self.txtCardNo.isUserInteractionEnabled = false
            self.txtExpiryDate.isUserInteractionEnabled = false
            self.txtCVV.isUserInteractionEnabled = true
            self.txtCardName.isUserInteractionEnabled = false
            self.btnCardType.isUserInteractionEnabled = false
            
            self.viewCVV.alpha = 1.0
            
            self.txtCardNo.text = self.objCardDetail.cardNumber.replacingOccurrences(of: " ", with: "")
            self.txtExpiryDate.text = self.objCardDetail.cardExpiry
            self.txtCardName.text = self.objCardDetail.cardHolderName
            self.txtCardType.text = self.objCardDetail.cardType
            self.btnAdd.setTitle("Submit", for: [])
            self.lblConditions.isHidden = false
            self.btnAcceptConditions.isHidden = false

        }
        
        self.setupCardTypeDropDown()
    }
    
    //MARK: - HELPER -
    
    func setupCardTypeDropDown() {
        self.cardTypeDropDown = DropDown()
        let arrCardType = ["Debit Card", "Credit Card"]
        
        self.cardTypeDropDown.backgroundColor = .white
        self.cardTypeDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.cardTypeDropDown.textColor = .black
        self.cardTypeDropDown.selectedTextColor = .white
        
        self.cardTypeDropDown.anchorView = self.viewCardType
        self.cardTypeDropDown.bottomOffset = CGPoint(x: 0, y:((self.cardTypeDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.cardTypeDropDown.dataSource = arrCardType
        self.cardTypeDropDown.direction = .bottom
        self.cardTypeDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.cardTypeDropDown.cellHeight = 42
        
        if self.txtCardType.text != "" {
            guard let index = arrCardType.firstIndex(of: self.txtCardType.text!) else { return }
            self.cardTypeDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.cardTypeDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtCardType.text = item
        }
    }
    
    // MARK: - ACTIONS -
    
    @IBAction func onPressBtnAcceptClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    

    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnCardTypeClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.cardTypeDropDown.show()
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.strPage == "Add" {
            if self.txtCardNo.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card number is required")
            }
            if self.txtCardNo.text?.count ?? 0 < 16 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Enter valid card no")
            }
            else if self.txtExpiryDate.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Expiry date is required")
            }
            else if self.txtCardName.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card name is required")
            }
            else if self.txtCardType.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card type is required")
            }
            else {
                self.btnAdd.isUserInteractionEnabled = false
                self.callAddNewCardAPI()
            }
        }
        else if self.strPage == "Edit" {
            if self.txtCardNo.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card number is required")
            }
            if self.txtCardNo.text?.count ?? 0 < 16 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Enter valid card no")
            }
            else if self.txtExpiryDate.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Expiry date is required")
            }
            else if self.txtCardName.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card name is required")
            }
            else if self.txtCardType.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card type is required")
            }
            else {
                self.btnAdd.isUserInteractionEnabled = false
                self.callUpdateCardAPI()
            }
        }
        else {
            if self.txtCardNo.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card number is required")
            }
            else if self.txtExpiryDate.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Expiry date is required")
            }
            else if self.txtCVV.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "CVV is required")
            }
            else if self.txtCardName.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card name is required")
            }
            else if self.txtCardType.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Card type is required")
            }
            else if self.btnAcceptConditions.isSelected == false {
                GlobalData.shared.showDarkStyleToastMesage(message: "Please Accept Conditions")
            }
            else {
                self.btnAdd.isUserInteractionEnabled = false
                self.callAddFundAPI()
            }
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension AddEditCardPopupVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        //no dots allowed
        if string == "." {
            return false
        }

//        guard string.compactMap({ Int(String($0)) }).count ==
//                string.count else { return false }
//
//        let text = textField.text ?? ""
        
        if textField == self.txtCardNo {
            let newText: NSString = textField.text! as NSString
            let resultString = newText.replacingCharacters(in: range, with: string)
            if resultString.count > maxCardNumber {
                return false
            }
        }
        else if textField == self.txtExpiryDate {
            guard string.compactMap({ Int(String($0)) }).count ==
                    string.count else { return false }
            
            let text = textField.text ?? ""
            
            if string.count == 0 {
                textField.text = String(text.dropLast()).chunkFormatted(withChunkSize: 2, withSeparator: "/")//.chunkFormatted()
            }
            else {
                let newText = String((text + string).filter({ $0 != "/" }).prefix(maxExpiryNumber))
                textField.text = newText.chunkFormatted(withChunkSize: 2, withSeparator: "/")//.chunkFormatted()
            }
            return false
        }
        else if textField == self.txtCVV {
            let newText: NSString = textField.text! as NSString
            let resultString = newText.replacingCharacters(in: range, with: string)
            if resultString.count > maxCVV {
                return false
            }
        }
        return true
    }
}

//MARK: - API CALL -

extension AddEditCardPopupVC {
    //ADD CARD API
    func callAddNewCardAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["cardNumber"] = self.txtCardNo.text ?? ""
        params["cardExpiry"] = self.txtExpiryDate.text ?? ""
        params["cardHolderName"] = self.txtCardName.text ?? ""
        params["cardType"] = self.txtCardType.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_CARD, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            let objCard = CardObject.init(payload)
                            
                            strongSelf.btnAdd.isUserInteractionEnabled = true

                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            
                            var dict = [String: CardObject]()
                            dict["card"] = objCard
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kAddCardDetail), object: nil, userInfo: dict)
                            strongSelf.dismiss(animated: true, completion: nil)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnAdd.isUserInteractionEnabled = true
        }
    }
    
    //UPDATE CARD API
    func callUpdateCardAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["cardNumber"] = self.txtCardNo.text ?? ""
        params["cardExpiry"] = self.txtExpiryDate.text ?? ""
        params["cardHolderName"] = self.txtCardName.text ?? ""
        params["cardType"] = self.txtCardType.text ?? ""
        
        let strURL = Constants.URLS.GET_CARD + "/" + "\(self.objCardDetail._id)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPUTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            let objCard = CardObject.init(payload)
                            
                            strongSelf.btnAdd.isUserInteractionEnabled = true
                            
                            GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                            
                            var dict = [String: CardObject]()
                            dict["card"] = objCard
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUpdateCardDetail), object: nil, userInfo: dict)
                            strongSelf.dismiss(animated: true, completion: nil)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnAdd.isUserInteractionEnabled = true
        }
    }
    
    //ADD FUND API
    func callAddFundAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["cardNumber"] = self.txtCardNo.text ?? ""
        params["cardExpiry"] = self.txtExpiryDate.text ?? ""
        params["cvv"] = self.txtCVV.text ?? ""
        params["cardHolderName"] = self.txtCardName.text ?? ""
        params["cardType"] = self.txtCardType.text ?? ""
        params["amount"] = self.strAmount
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.ADD_FUND, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                        
                        GlobalData.shared.displayAlertWithOkAction(strongSelf, title: "Success", message: (response["message"] as! String), btnTitle: "Ok") { (isOK) in
                            if isOK {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "moveToFundTransaction"), object: nil)
                                strongSelf.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnAdd.isUserInteractionEnabled = true
        }
    }
}
