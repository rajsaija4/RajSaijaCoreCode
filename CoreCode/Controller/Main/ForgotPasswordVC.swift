//
//  ForgotPasswordVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 27/10/21.
//

import UIKit
import SwiftyJSON

class ForgotPasswordVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblForgotPass: UILabel!
    @IBOutlet weak var btnSendMail: UIButton!
    
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
            
            self.btnSendMail.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtEmail.textColor = UIColor.textFieldTextColor
        self.lblForgotPass.textColor = UIColor.labelTextColor
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendEmailClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.txtEmail.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Email is required")
        }
        else if !self.txtEmail.isValidEmail() {
            GlobalData.shared.showSystemToastMesage(message: "Email is invalid")
        }
        else {
            self.btnSendMail.isUserInteractionEnabled = false
            self.callForgotPasswordAPI()
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension ForgotPasswordVC: UITextFieldDelegate {
    
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

extension ForgotPasswordVC {
    
    func callForgotPasswordAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["email"] = self.txtEmail.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.FORGOT_PASSWORD, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        strongSelf.btnSendMail.isUserInteractionEnabled = true
                        
                        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "VerifyOTPVC") as! VerifyOTPVC
                        controller.strEmail = strongSelf.txtEmail.text ?? ""
                        strongSelf.navigationController?.pushViewController(controller, animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnSendMail.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnSendMail.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnSendMail.isUserInteractionEnabled = true
        }
    }
}
