
import UIKit
import SwiftyJSON
import SwiftValidators

class CreateNewPassVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var lblCreatePass: UILabel!
    @IBOutlet weak var btnResetPass: UIButton!
    
    var strEmail: String = ""
    var strOTP: String = ""
    
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
            
            self.btnResetPass.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtPass.textColor = UIColor.textFieldTextColor
        self.txtConfirmPass.textColor = UIColor.textFieldTextColor
        self.lblCreatePass.textColor = UIColor.labelTextColor
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
            self.txtPass.isSecureTextEntry = false
        } else {
            self.txtPass.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnShowConfirmPassClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtConfirmPass.isSecureTextEntry = false
        } else {
            self.txtConfirmPass.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnResetPassClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.txtPass.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Password is required")
        }
        else if !Validator.minLength(6).apply(self.txtPass.text!) {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password should be 6 character long")
        }
        else if self.txtConfirmPass.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Confirm password is required")
        }
        else if self.txtPass.text != self.txtConfirmPass.text {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password and confirm password is not same")
        }
        else {
            self.btnResetPass.isUserInteractionEnabled = false
            self.callResetPasswordAPI()
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension CreateNewPassVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        return true
    }
}

//MARK: - API CALL -

extension CreateNewPassVC {
    //RESET PASSWORD
    func callResetPasswordAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["email"] = self.strEmail
        params["password"] = self.txtPass.text ?? ""
        params["otp"] = self.strOTP
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.CREATE_NEW_PASSWORD, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        strongSelf.btnResetPass.isUserInteractionEnabled = true
                                                
                        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                        let navController = UINavigationController.init(rootViewController: controller)
                        appDelegate.window?.rootViewController = navController
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnResetPass.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnResetPass.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnResetPass.isUserInteractionEnabled = true
        }
    }
}
