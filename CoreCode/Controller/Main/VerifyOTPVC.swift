//
//  VerifyOTPVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 28/10/21.
//

import UIKit
import SwiftyJSON
import OTPFieldView

class VerifyOTPVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblVerifyOTP: UILabel!
    @IBOutlet weak var otpTextFieldView: OTPFieldView!
    @IBOutlet weak var btnVerify: UIButton!
    
    var strEmail: String = ""
    var strOTP: String = ""
    var isOtpEntered: Bool = false
        
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
            
            self.btnVerify.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.setupOTPView()
        
        self.lblVerifyOTP.textColor = UIColor.labelTextColor
    }
    
    //MARK: - HELPER -
    
    func setupOTPView() {
//        let fieldsCount = 4
//        let separatorSpace = 10
//        self.otpTextFieldView.fieldsCount = 4
//        self.otpTextFieldView.fieldBorderWidth = 2
////        self.otpTextFieldView.fieldFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 18.0)!
////        self.otpTextFieldView.defaultBackgroundColor = .clear
////        self.otpTextFieldView.filledBackgroundColor = .green
//        self.otpTextFieldView.defaultBorderColor = UIColor.blue
//        self.otpTextFieldView.filledBorderColor = UIColor.yellow
//        self.otpTextFieldView.cursorColor = UIColor.init(hex: 0xC6C9D1, a: 1.0)
//        self.otpTextFieldView.displayType = .underlinedBottom
//        self.otpTextFieldView.fieldSize = (((Constants.ScreenSize.SCREEN_WIDTH - 30.0) / CGFloat(fieldsCount)) - 12)// CGFloat((separatorSpace * (fieldsCount - 1))))
//        self.otpTextFieldView.separatorSpace = CGFloat(separatorSpace)
//        self.otpTextFieldView.shouldAllowIntermediateEditing = true
//        self.otpTextFieldView.delegate = self
//        self.otpTextFieldView.initializeUI()
        
        self.otpTextFieldView.fieldsCount = 4
        self.otpTextFieldView.fieldBorderWidth = 2
        self.otpTextFieldView.fieldFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 18.0)!
        //        self.otpTextFieldView.defaultBackgroundColor = .clear
        //        self.otpTextFieldView.filledBackgroundColor = .green
        self.otpTextFieldView.defaultBorderColor = UIColor.init(hex: 0xC6C9D1, a: 1.0)
        self.otpTextFieldView.filledBorderColor = Constants.Color.THEME_BLUE
        self.otpTextFieldView.cursorColor = UIColor.init(hex: 0xC6C9D1, a: 1.0)
        self.otpTextFieldView.displayType = .underlinedBottom
//        self.otpTextFieldView.secureEntry = true
        if Constants.DeviceType.IS_IPHONE_5 {
            self.otpTextFieldView.fieldSize = 30
            self.otpTextFieldView.separatorSpace = 10
        } else if Constants.DeviceType.IS_IPHONE_6 {
            self.otpTextFieldView.fieldSize = 35
            self.otpTextFieldView.separatorSpace = 30
        } else {
            self.otpTextFieldView.fieldSize = 40
            self.otpTextFieldView.separatorSpace = 30
        }
        self.otpTextFieldView.shouldAllowIntermediateEditing = true
        self.otpTextFieldView.delegate = self
        self.otpTextFieldView.initializeUI()
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnVerifyTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !self.isOtpEntered {
            GlobalData.shared.showSystemToastMesage(message: "Please provide code")
        } else {
            self.btnVerify.isUserInteractionEnabled = false
            self.callVerifyOTPAPI()
        }
    }
    
    @IBAction func btnResendTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        self.callResendVerificationCodeAPI()
    }
}

//MARK: - OTPFieldViewDelegate -

extension VerifyOTPVC: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        debugPrint("Has entered all OTP? \(hasEntered)")
        self.isOtpEntered = hasEntered
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        debugPrint("OTPString: \(otpString)")
        self.strOTP = otpString
    }
}

//MARK: - API CALL -

extension VerifyOTPVC {
    //RESEND CODE
    func callResendVerificationCodeAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["email"] = self.strEmail
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.FORGOT_PASSWORD, params: params, headers: nil, success: { (JSONResponse) -> Void in
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
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
    
    //VERIFY OTP
    func callVerifyOTPAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["email"] = self.strEmail
        params["otp"] = self.strOTP
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.VERIFY_OTP, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        strongSelf.btnVerify.isUserInteractionEnabled = true
                                                
                        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "CreateNewPassVC") as! CreateNewPassVC
                        controller.strEmail = strongSelf.strEmail
                        controller.strOTP = strongSelf.strOTP
                        strongSelf.navigationController?.pushViewController(controller, animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnVerify.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnVerify.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnVerify.isUserInteractionEnabled = true
        }
    }
}
