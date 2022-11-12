
import UIKit
import SwiftyJSON
import LocalAuthentication

class LoginVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var viewEmail: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewPassword: UIView!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var imgRemember: UIImageView!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnSignup: UIButton!
    @IBOutlet weak var lblRemembrMe: UILabel!
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var btnBiometric: UIButton!
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.txtEmail.text = "test222@yopmail.com"
//        self.txtPassword.text = "123456"
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        let attString = GlobalData.shared.convertStringtoAttributedText(strFirst: "Don't have an account?" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: (self.btnRegister.titleLabel?.font.pointSize)!)!, strFirstColor: UIColor.DontHaveAnAccount, strSecond: "Register", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: (self.btnRegister.titleLabel?.font.pointSize)!)!, strSecondColor: Constants.Color.THEME_GREEN)
        self.btnRegister.setAttributedTitle(attString, for: .normal)
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnLogin.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            self.btnSignup.createButtonShadow(BorderColor: UIColor.init(hex: 0x27B1FC, a: 0.35), ShadowColor: UIColor.init(hex: 0x27B1FC, a: 0.35))
        }
        
        self.txtEmail.textColor = UIColor.textFieldTextColor
        self.txtPassword.textColor = UIColor.textFieldTextColor
        self.lblRemembrMe.textColor = UIColor.labelTextColor
        
        self.imgRemember.image = UIImage.init(named: "ic_uncheck")
        
        if let isRemember = defaults.object(forKey: kRememberMe) as? Bool {
            if isRemember == true {
                self.txtEmail.text = defaults.string(forKey: kRememberEmail)
                self.txtPassword.text = defaults.string(forKey: kRememberPassword)
                self.imgRemember.image = UIImage.init(named: "ic_check")
            }
        }
        
        let currentType = LAContext().biometricType
        if currentType == .faceID {
            debugPrint("Login with Face ID")
        } else if currentType == .touchID {
            debugPrint("Login with Touch ID")
        }
        
        if defaults.bool(forKey: biometricLockEnabled) {
            self.btnBiometric.isHidden = false
        } else {
            self.btnBiometric.isHidden = true
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnShowPassClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtPassword.isSecureTextEntry = false
        } else {
            self.txtPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnRememberMeClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.imgRemember.image == UIImage.init(named: "ic_uncheck") {
            self.imgRemember.image = UIImage.init(named: "ic_check")
        } else {
            self.imgRemember.image = UIImage.init(named: "ic_uncheck")
        }
    }
    
    @IBAction func btnForgotPasswordClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnLoginClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.txtEmail.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Email is required")
        }
        else if !self.txtEmail.isValidEmail() {
            GlobalData.shared.showSystemToastMesage(message: "Email is invalid")
        }
        else if self.txtPassword.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Password is required")
        }
        else {
            self.btnLogin.isUserInteractionEnabled = false
            self.callLoginAPI(isManualLogin: true, email: self.txtEmail.text ?? "", password: self.txtPassword.text ?? "")
        }
    }
    
    @IBAction func btnSignupClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnRegisterClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SignupVC") as! SignupVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnFingerprintClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.authenticationWithTouchID()
    }
}

//MARK: - BIOMETRIC METHODS -

extension LoginVC {
    //OPEN BIOMETRIC AUTHENTICATION DIALOG WHEN USER DO LOGIN WITH TOUCH ID AND CALL LOGIN API IF AUTHENTICATED SUCCESSFULLY OTHERWISE DISPLAY ERROR
    func authenticationWithTouchID() {
        let context : LAContext = LAContext()
        let myLocalizedReasonString = "Please use your Passcode"//"Scan your finger"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        self.callLoginAPI(isManualLogin: false, email: defaults.value(forKey: userEmail) as! String, password: defaults.value(forKey: userPassword) as! String)
                    }
                } else {
                    if let error = evaluateError {
                        DispatchQueue.main.async {
                            self.showErrorMessageForLAErrorCode(errorCode: (error as NSError).code)
                        }
                    }
                }
            }
        } else {
            if let error = authError {
                DispatchQueue.main.async {
                    self.showErrorMessageForLAErrorCode(errorCode: (error as NSError).code)
                }
            }
        }
    }
    
    //BIOMETRIC AUTHENTICATION ERRORS
    func showErrorMessageForLAErrorCode(errorCode: Int) {
        switch errorCode {
        case LAError.appCancel.rawValue:
            debugPrint("Authentication was cancelled by application")
            
        case LAError.authenticationFailed.rawValue:
            debugPrint("The user failed to provide valid credentials")
            
        case LAError.invalidContext.rawValue:
            debugPrint("The context is invalid")
            
        case LAError.passcodeNotSet.rawValue:
            debugPrint("Passcode is not set on the device")
            
        case LAError.systemCancel.rawValue:
            debugPrint("Authentication was cancelled by the system")
            
        case LAError.biometryLockout.rawValue:
            debugPrint("Too many failed attempts.")
            GlobalData.shared.showSystemToastMesage(message: "Too many failed attempts. Biometric is disabled.")
            
        case LAError.biometryNotAvailable.rawValue:
            debugPrint("TouchID is not available on the device")
            GlobalData.shared.showSystemToastMesage(message: "No biometric features available on this device.")
            
        case LAError.biometryNotEnrolled.rawValue:
            debugPrint("TouchID is not enrolled on the device")
            GlobalData.shared.showSystemToastMesage(message: "Biometric is not enrolled on the device.")
            
        case LAError.userCancel.rawValue:
            debugPrint("The user did cancel")
            
        case LAError.userFallback.rawValue:
            debugPrint("The user chose to use the fallback")
            
        default:
            debugPrint("Did not find error code on LAError object")
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension LoginVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        } else if string == " " {
            if textField == self.txtEmail {
                return false
            }
        }
        return true
    }
}

//MARK: - API CALL -

extension LoginVC {
    func callLoginAPI(isManualLogin: Bool, email: String, password: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var deviceToken: String = "123456"
        if defaults.value(forKey: "deviceToken") != nil {
            deviceToken = defaults.value(forKey: "deviceToken") as! String
        }
        
        var params: [String:Any] = [:]
        params["email"] = email
        params["password"] = password
        params["userType"] = "user"
        params["loginType"] = "user"
        params["deviceType"] = kDeviceType
        params["deviceToken"] = deviceToken
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.LOGIN, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        
                        let userDetail = response["data"] as! Dictionary<String, Any>
                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())
                        
                        if let data = try? JSONEncoder().encode(object) {
                            
                            objUserDetail = object
                            
                            strongSelf.btnLogin.isUserInteractionEnabled = true
                            
                            if objUserDetail.isVerified == true {
                                if objUserDetail.active == true {
                                if isManualLogin == true {
                                    defaults.set(email, forKey: userEmail)
                                    defaults.set(password, forKey: userPassword)
                                }
                                defaults.set(data, forKey: kLoggedInUserData)
                                defaults.set("\(userDetail["token"] ?? "")", forKey: kAuthToken)
                                defaults.synchronize()
                                
                                GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                                
                                let leftMenuVC = GlobalData.sideMenuStoryBoard().instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                                let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                                let navController = UINavigationController.init(rootViewController: controller)
                                navController.setNavigationBarHidden(true, animated: true)
                                appDelegate.drawerController.contentViewController = navController
                                appDelegate.drawerController.menuViewController = leftMenuVC
                                appDelegate.window?.rootViewController = appDelegate.drawerController
                                }
                                else {
                                    GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                                }
                            }
                            
                            else {
                                let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ProcessVC") as! ProcessVC
                                strongSelf.navigationController?.pushViewController(controller, animated: true)
                                
                                //                                if (objUserDetail.nationality == "" && objUserDetail.countryOfResidency == "") || objUserDetail.documents == false || objUserDetail.W8BENForm == false || objUserDetail.W8BENDeclaration == false {
                                //                                    let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ProcessVC") as! ProcessVC
                                //                                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                                //                                } else {
                                //                                    GlobalData.shared.showSystemToastMesage(message: "Your account is not verified yet.\nyou will receive an email once verified by admin")
                                //                                }
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnLogin.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnLogin.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnLogin.isUserInteractionEnabled = true
        }
    }
}
