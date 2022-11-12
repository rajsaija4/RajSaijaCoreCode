//
//  ChangePasswordVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 28/12/21.
//

import UIKit
import SwiftValidators
import SwiftyJSON

class ChangePasswordVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var txtCurrentPass: UITextField!
    @IBOutlet weak var txtNewPass: UITextField!
    @IBOutlet weak var txtConfirmPass: UITextField!
    @IBOutlet weak var btnDone: UIButton!
    
    @IBOutlet weak var viewPopupSuccess: UIView!
    
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
            
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtCurrentPass.textColor = UIColor.textFieldTextColor
        self.txtNewPass.textColor = UIColor.textFieldTextColor
        self.txtConfirmPass.textColor = UIColor.textFieldTextColor
        
        self.viewPopupSuccess.isHidden = true
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnShowCurrentPassClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtCurrentPass.isSecureTextEntry = false
        } else {
            self.txtCurrentPass.isSecureTextEntry = true
        }
    }
    
    @IBAction func btnShowNewPassClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.txtNewPass.isSecureTextEntry = false
        } else {
            self.txtNewPass.isSecureTextEntry = true
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
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        self.view.endEditing(true)
                
        if self.txtCurrentPass.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Current password is required")
        }
        else if self.txtNewPass.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "New password is required")
        }
        else if !Validator.minLength(6).apply(self.txtNewPass.text!) {
            GlobalData.shared.showDarkStyleToastMesage(message: "New password should be 6 character long")
        }
        else if self.txtConfirmPass.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Confirm password is required")
        }
        else if self.txtNewPass.text != self.txtConfirmPass.text {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password and confirm password is not same")
        }
        else {
            self.btnDone.isUserInteractionEnabled = false
            self.callChangePasswordAPI()
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension ChangePasswordVC: UITextFieldDelegate {
    
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

extension ChangePasswordVC {
    func callChangePasswordAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["oldPassword"] = self.txtCurrentPass.text ?? ""
        params["password"] = self.txtNewPass.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.CHANGE_PASSWORD, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.btnDone.isUserInteractionEnabled = true
                        
                        strongSelf.viewPopupSuccess.isHidden = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            strongSelf.viewPopupSuccess.isHidden = true
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnDone.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnDone.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnDone.isUserInteractionEnabled = true
        }
    }
}
