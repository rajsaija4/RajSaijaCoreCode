//
//  SignInVC.swift
//  BYT
//
//  companyName on 11/10/21.
//

import UIKit
import SwiftyJSON

class SignInVC: UIViewController, UITextFieldDelegate {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - SETUP VIEW -
    
    @IBAction func txtEmail(_ sender: UITextField) {
        self.txtEmail.attributedPlaceholder = NSAttributedString(
            string: "Email"
        )
        self.emailView.borderColor = UIColor.init(hexString: "DFE0E5")
    }
    
    @IBAction func txtPassword(_ sender: UITextField) {
        self.txtPassword.attributedPlaceholder = NSAttributedString(
            string: "Password"
        )
        self.passwordView.borderColor = UIColor.init(hexString: "DFE0E5")
    }
    
    func setUpView() {
        DispatchQueue.main.async {
            self.emailView.layer.cornerRadius = self.emailView.frame.height / 2
            self.passwordView.layer.cornerRadius = self.passwordView.frame.height / 2
        }
    }
    
    // MARK: - ACTIONS -
    
    @IBAction func btnVisiblePassword(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func onPressbtnForgotPassword(_ sender: UIButton) {
        let vc = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPressbtnSignin(_ sender: UIButton) {
        if self.txtEmail.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Email address is required")
        }
        else if !self.txtEmail.isEmail() {
            GlobalData.shared.showDarkStyleToastMesage(message: "Email address is invalid")
        }
        else if self.txtPassword.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password is required")
        }
        else {
            callSignInAPI(email: txtEmail.text!, password: txtPassword.text!)
        }
    }
    
    @IBAction func onPressbtnSignUp(_ sender: UIButton) {
        let vc = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func onPressbtnFbLogin(_ sender: UIButton) {
        debugPrint("fb login press")
    }
    
    @IBAction func onPressbtnGoogleLogin(_ sender: UIButton) {
        debugPrint("google login press")
    }
    
    @IBAction func onPressbtnTweeterLogin(_ sender: UIButton) {
        debugPrint("twitter login press")
    }
    
    @IBAction func onPressbtnInstagramLogin(_ sender: UIButton) {
        debugPrint("instagram login press")
    }
}

//MARK: - API CALLING

extension SignInVC {
    func callSignInAPI(email: String, password: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayNoInternet()
            return
        }
        
        var deviceToken: String = "123456"
        if defaults.value(forKey: "deviceToken") != nil {
            deviceToken = defaults.value(forKey: "deviceToken") as! String
        }
        
        var params: [String:Any] = [:]
        params["email"] = email
        params["password"] = password
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        AFWrapper.shared.requestPOSTURL(Constants.URLS.SIGNIN, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if JSONResponse["status"].intValue == 1 {
                    //                GlobalData.shared.showDarkStyleToastMesage(message: JSONResponse["message"].stringValue)
                    let data = Registered(json: JSONResponse)
                    data.save()
                    if Registered.details.token.count > 0 {
                        defaults.set(Registered.details.token, forKey: kAuthToken)
                        strongSelf.setupTabBarController()
                    }
                }
                else {
                    GlobalData.shared.showDarkStyleToastMesage(message: JSONResponse["error"].stringValue)
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            debugPrint(error.localizedDescription)
        }
    }
    
    func setupTabBarController() {
        let vc = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navController = UINavigationController.init(rootViewController: vc)
        appDelegate.window?.rootViewController = navController
    }
}
