//

import UIKit
import SwiftValidators
import SwiftyJSON

class ChangePasswordVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -

    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
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
            
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtCurrentPass.textColor = UIColor.textFieldTextColor
        self.txtNewPass.textColor = UIColor.textFieldTextColor
        self.txtConfirmPass.textColor = UIColor.textFieldTextColor
        
        self.viewPopupSuccess.isHidden = true
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
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
            self.callUpdatePasswordAPI()
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
    func callUpdatePasswordAPI() {
        print("Update Password API")
        self.btnDone.isUserInteractionEnabled = true
        
        self.viewPopupSuccess.isHidden = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.viewPopupSuccess.isHidden = true
            self.navigationController?.popViewController(animated: true)
        }
    }
}
