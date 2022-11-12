//
//  ContactUsVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 23/03/22.
//

import UIKit
import CountryPickerView
import SwiftyJSON

class ContactUsVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var txtMessage: KMPlaceholderTextView!
    @IBOutlet weak var btnSend: UIButton!
    
    var strCountryCode = ""
    
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
        self.countryPicker.showCountryCodeInView = false
        self.countryPicker.showPhoneCodeInView = true
        self.countryPicker.showCountryNameInView = false
        self.countryPicker.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 16.0)!
        self.countryPicker.textColor = UIColor.init(hex: 0x333333)
        self.countryPicker.flagSpacingInView = 0.0
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnSend.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtMessage.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0) //8,10,8,8
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.txtUserName.textColor = UIColor.textFieldTextColor
        self.txtEmail.textColor = UIColor.textFieldTextColor
        self.txtPhone.textColor = UIColor.textFieldTextColor
        self.txtMessage.textColor = UIColor.textViewTextColor
        
        self.txtUserName.isUserInteractionEnabled = false
        self.txtEmail.isUserInteractionEnabled = false
        self.txtPhone.isUserInteractionEnabled = false
        self.countryPicker.isUserInteractionEnabled = false
        
        self.txtUserName.alpha = 0.7
        self.txtEmail.alpha = 0.7
        self.txtPhone.alpha = 0.7
        self.countryPicker.alpha = 0.7
        
        //SET DATA
        self.txtUserName.text = objUserDetail.givenName + " " + objUserDetail.familyName
        self.txtEmail.text = objUserDetail.email
        self.txtPhone.text = objUserDetail.contactNo
        self.strCountryCode = objUserDetail.contactCountryCode
        
        //SET COUNTRY BASED ON DIAL CODE
        self.countryPicker.setCountryByPhoneCode(self.strCountryCode)
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.txtMessage.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Message is required")
        }
        else {
            self.btnSend.isUserInteractionEnabled = false
            self.callContactUsAPI()
        }
    }
}

//MARK: - UITEXTVIEW DELEGATE METHOD -

extension ContactUsVC: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textView.tintColor = UIColor.textViewTextColor
        return true
    }
    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//        let numberOfChars = newText.count
//
//        if numberOfChars <= 160 {
//            let remainingChars = 160 - numberOfChars
//            self.lblCharacterLeft.text = "You have another <\(remainingChars)> characters left"
//        }
//
//        return numberOfChars <= 160
//    }
}

//MARK: - API CALL -

extension ContactUsVC {
    func callContactUsAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["question"] = self.txtMessage.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.CONTACT_US, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.btnSend.isUserInteractionEnabled = true
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnSend.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnSend.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnSend.isUserInteractionEnabled = true
        }
    }
}
