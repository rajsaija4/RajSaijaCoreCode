//


import UIKit
import SwiftyJSON
import SwiftValidators
import CountryPickerView
import LocalAuthentication

class SignupVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var lblNotification: UILabel!
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var btnSignup: UIButton!
    
    @IBOutlet weak var viewPopupNotification: UIView!
    @IBOutlet weak var viewPopupSuccess: UIView!
    
    var strCountryCode = ""
    var enablePushNotification:Bool = false

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
        self.countryPicker.delegate = self
        self.countryPicker.showCountryCodeInView = false
        self.countryPicker.showPhoneCodeInView = true
        self.countryPicker.showCountryNameInView = false
        self.countryPicker.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 16.0)!
        self.countryPicker.textColor = UIColor.init(hex: 0x333333)
        self.countryPicker.flagSpacingInView = 0.0
        let country = self.countryPicker.selectedCountry
        self.strCountryCode = country.phoneCode
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnSignup.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtFirstName.textColor = UIColor.textFieldTextColor
        self.txtLastName.textColor = UIColor.textFieldTextColor
        self.txtEmail.textColor = UIColor.textFieldTextColor
        self.txtPassword.textColor = UIColor.textFieldTextColor
        self.txtPhone.textColor = UIColor.textFieldTextColor
        self.lblNotification.textColor = UIColor.labelTextColor
        
        self.switchNotification.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        self.viewPopupNotification.isHidden = true
        self.viewPopupSuccess.isHidden = true
    }

    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShowPassClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtPassword.isSecureTextEntry = false
        } else {
            self.txtPassword.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnSelectCountryClick(_ sender: UIButton) {
        self.countryPicker.showCountriesList(from: self)
    }
    
    @IBAction func switchNotificationValueChanged(_ sender: UISwitch) {
        if sender.isOn {
            self.enablePushNotification = true
        } else {
            self.enablePushNotification = false
        }
    }
    
    @IBAction func btnClosePopupClick(_ sender: UIButton) {
        self.viewPopupNotification.isHidden = true
    }
    
    @IBAction func btnAllowClick(_ sender: UIButton) {
        self.switchNotification.isOn = true
        self.enablePushNotification = true
        self.viewPopupNotification.isHidden = true
    }
    
    @IBAction func btnSignupClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let phonetrimmedString = self.txtPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if self.txtFirstName.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Firstname is required")
        }
        else if self.txtLastName.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Lastname is required")
        }
        else if self.txtEmail.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Email is required")
        }
        else if !self.txtEmail.isValidEmail() {
            GlobalData.shared.showSystemToastMesage(message: "Email is invalid")
        }
        else if self.txtPassword.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Password is required")
        }
        else if !Validator.minLength(6).apply(self.txtPassword.text!) {
            GlobalData.shared.showSystemToastMesage(message: "Password should be 6 character long")
        }
        else if self.strCountryCode == "" {
            GlobalData.shared.showDarkStyleToastMesage(message: "Country code is required")
        }
        else if self.txtPhone.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Phone number is required")
        }
        else if !self.txtPhone.isValidPhone() {
            GlobalData.shared.showDarkStyleToastMesage(message: "Phone number is invalid")
        }
        else if !Validator.minLength(10).apply(phonetrimmedString) {
            GlobalData.shared.showDarkStyleToastMesage(message: "Phone number should be 10 character long")
        }
        else if self.enablePushNotification == false {
            self.viewPopupNotification.isHidden = false
        }
        else {
            self.btnSignup.isUserInteractionEnabled = false
            self.callSignupAPI()
        }
    }
}

//MARK: - COUNTRY PICKER DELEGATE METHOD -

extension SignupVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {

        debugPrint("Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)")
        self.strCountryCode = country.phoneCode
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension SignupVC: UITextFieldDelegate {
    
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

extension SignupVC {
    func callSignupAPI() {        
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var deviceToken: String = "123456"
        if defaults.value(forKey: "deviceToken") != nil {
            deviceToken = defaults.value(forKey: "deviceToken") as! String
        }
        
        var params: [String:Any] = [:]
        params["givenName"] = self.txtFirstName.text ?? ""
        params["familyName"] = self.txtLastName.text ?? ""
        params["email"] = self.txtEmail.text ?? ""
        params["password"] = self.txtPassword.text ?? ""
        params["contactCountryCode"] = self.strCountryCode
        params["contactNo"] = self.txtPhone.text ?? ""
        params["userType"] = "user"
        params["loginType"] = "user"
        params["deviceType"] = kDeviceType
        params["deviceToken"] = deviceToken
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.SIGNUP, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        let userDetail = response["data"] as! Dictionary<String, Any>
                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())
                        
                        if let data = try? JSONEncoder().encode(object) {
                            defaults.set(data, forKey: kLoggedInUserData)
                            defaults.set("\(userDetail["token"] ?? "")", forKey: kAuthToken)
                            defaults.set(strongSelf.enablePushNotification, forKey: kNotifcation)
                            defaults.synchronize()
                            
                            objUserDetail = object
                            
                            strongSelf.btnSignup.isUserInteractionEnabled = true
                            
                            strongSelf.viewPopupSuccess.isHidden = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                strongSelf.viewPopupSuccess.isHidden = true
                                
                                let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ProcessVC") as! ProcessVC
                                strongSelf.navigationController?.pushViewController(controller, animated: true)
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnSignup.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnSignup.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnSignup.isUserInteractionEnabled = true
        }
    }
}
