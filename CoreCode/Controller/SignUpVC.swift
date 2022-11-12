//
//  SignUpVC.swift
//  BYT
//
//  Created by 21Twelve Interactive on 11/10/21.
//

import UIKit
import ContactsUI
import TagListView
import DatePicker
import PhoneNumberKit
import SwiftyJSON

class SignUpVC: UIViewController, TagListViewDelegate, UITextFieldDelegate {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var btnValidateNumber: UIButton!
    @IBOutlet weak var btnIsvalidNumber: UIButton!
    @IBOutlet weak var viewContact: UIView!
    @IBOutlet weak var txtContact: PhoneNumberTextField!
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var dateOfBirthView: UIView!
    @IBOutlet weak var diateryView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtDateofBirth: UITextField!
    @IBOutlet weak var txtDietaryRestrictions: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var tagListViewBottomConstraint: NSLayoutConstraint!
    let phoneNumberKit = PhoneNumberKit()
    var dateOfBirth = ""
    //    var maxMobileNumberLength:Int?
    var arrTagList:[String] = []
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - SETUP VIEW -
    
    func setUpView() {
        tagListView.delegate = self
        self.txtContact.withPrefix = true
        self.txtContact.withFlag = true
        self.txtContact.withExamplePlaceholder = true
        self.txtContact.withDefaultPickerUI = true
        self.tagListViewBottomConstraint.constant = 0
        DispatchQueue.main.async {
            if self.tagListView.subviews.count == 0 {
                self.diateryView.layer.cornerRadius = self.diateryView.frame.height / 2
            }
            self.emailView.layer.cornerRadius = self.emailView.frame.height / 2
            self.viewContact.layer.cornerRadius = self.emailView.frame.height / 2
            self.usernameView.layer.cornerRadius = self.usernameView.frame.height / 2
            self.dateOfBirthView.layer.cornerRadius = self.dateOfBirthView.frame.height / 2
            self.passwordView.layer.cornerRadius = self.passwordView.frame.height / 2
            self.confirmPasswordView.layer.cornerRadius = self.confirmPasswordView.frame.height / 2
        }
    }
    
    // MARK: -  ACTIONS
    
    @IBAction func onEnterValueChanged(_ sender: PhoneNumberTextField) {
        sender.withExamplePlaceholder = true
        if sender.isValidNumber == false {
            btnValidateNumber.isSelected = false
        }
        else {
            btnValidateNumber.isSelected = true
        }
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        guard let textFieldText = txtContact.text,
    //              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
    //            return false
    //        }
    //        let substringToReplace = textFieldText[rangeOfTextToReplace]
    //        let count = textFieldText.count - substringToReplace.count + string.count
    //        return count <= maxMobileNumberLength ?? 1000
    //    }
    
    @IBAction func onPressbtnSIgnUp(_ sender: UIButton) {
        
//        if self.txtUserName.isEmpty() == 1 {
//            GlobalData.shared.showDarkStyleToastMesage(message: "Name is required")
//        }
        if self.txtEmail.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Email address is required")
        }
        else if !self.txtEmail.isEmail() {
            GlobalData.shared.showDarkStyleToastMesage(message: "Email address is invalid")
        }
        else if self.btnValidateNumber.isSelected == false {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Valid Number")
        }
        else if self.txtDateofBirth.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Date of Birth is required")
        }
        else if self.txtContact.isValidNumber == false {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Enter Valid Number")
        }
        else if self.txtPassword.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password is required")
        }
        else if txtPassword.text?.count ?? 0 < 6 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password should be 6 character long")
        }
        else if self.txtConfirmPassword.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Confirm password is required")
        }
        else if self.txtPassword.text != self.txtConfirmPassword.text {
            GlobalData.shared.showDarkStyleToastMesage(message: "Password and confirm password is not same")
        }
        else {
            callSignUpAPI(name: txtUserName.text ?? "", email: txtEmail.text!, mobile: txtContact.text!, password: txtPassword.text!, diet: arrTagList, dob: dateOfBirth)
        }
    }
    
    @IBAction func onPressPasswordVisible(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func onPressRetypePasswordVisible(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        txtConfirmPassword.isSecureTextEntry = !sender.isSelected
    }
    
    @IBAction func onPressbtnSignIn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onPressDateOfBirthbtnTap(_ sender: UIButton) {
        self.txtDateofBirth.attributedPlaceholder = NSAttributedString(
            string: "Date of Birth"
        )
        self.dateOfBirthView.borderColor = UIColor.init(hexString: "DFE0E5")
        let picker = DatePicker()
        let minDate = DatePickerHelper.shared.dateFrom(day: 18, month: 08, year: 1960)!
        picker.setup(beginWith: Date(), min:minDate, max: Date()) { (selected, date) in
            if selected, let selectedDate = date {
                debugPrint(selectedDate.string())
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM d, yyyy"
                let date = dateFormatter.date(from: selectedDate.string())
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let resultString = dateFormatter.string(from: date!)
                self.dateOfBirth = resultString
                dateFormatter.dateFormat = "dd MMM yyyy"
                let viewString = dateFormatter.string(from: date!)
                self.txtDateofBirth.text = viewString
            } else {
                debugPrint("Cancelled")
            }
        }
        
        picker.show(in: self)
    }
    
    @IBAction func onPressbtnFbLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressTextField(_ sender: UITextField) {
        if sender.tag == 0 {
            self.txtUserName.attributedPlaceholder = NSAttributedString(
                string: "User Name"
            )
            self.usernameView.borderColor = UIColor.init(hexString: "DFE0E5")
        }
        else if sender.tag == 1 {
            self.txtEmail.attributedPlaceholder = NSAttributedString(
                string: "Email"
            )
            self.emailView.borderColor = UIColor.init(hexString: "DFE0E5")
        }
        else if sender.tag == 2 {
            self.txtDateofBirth.attributedPlaceholder = NSAttributedString(
                string: "Date of Birth"
            )
            self.dateOfBirthView.borderColor = UIColor.init(hexString: "DFE0E5")
        }
        else {
            self.txtPassword.attributedPlaceholder = NSAttributedString(
                string: "Password"
            )
            self.passwordView.borderColor = UIColor.init(hexString: "DFE0E5")
        }
    }
    
    @IBAction func onPressbtnGoogleLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressbtnTweeterLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressbtnInstaLogin(_ sender: UIButton) {
        
    }
    
    @IBAction func onPressbtnAddDiet(_ sender: UIButton) {
        if txtDietaryRestrictions.text?.count ?? 0 > 0 {
            self.tagListViewBottomConstraint.constant = 16
            tagListView.addTag(txtDietaryRestrictions.text!)
            arrTagList.append(txtDietaryRestrictions.text!)
            debugPrint(arrTagList)
            txtDietaryRestrictions.text = nil
            debugPrint(tagListView.frame.size.height)
        }
    }
    
    //MARK: - TAGVIEW DELEGATE
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        arrTagList.removeAll {$0 == title}
        debugPrint(arrTagList)
        if tagListView.subviews.count > 0 {
            self.tagListViewBottomConstraint.constant = 16
        }
        else {
            self.tagListViewBottomConstraint.constant = 0
        }
    }
}


//MARK: - API CALLING -

extension SignUpVC {
    
    func callSignUpAPI(name: String, email: String, mobile: String, password: String, diet:[String], dob:String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayNoInternet()
            return
        }
        
        var deviceToken: String = "123456"
        if defaults.value(forKey: "deviceToken") != nil {
            deviceToken = defaults.value(forKey: "deviceToken") as! String
        }
        
        let dietArray = try! JSON(diet)
        
        var params: [String:Any] = [:]
        params["name"] = name
        params["email"] = email
        params["mobile"] = mobile
        params["password"] = password
        params["diet"] = diet
        params["dob"] = dob
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestJsonPOSTURL(Constants.URLS.SIGNUP, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            if JSONResponse != JSON.null {
                if JSONResponse["status"].intValue == 1 {
                    //                    GlobalData.shared.showDarkStyleToastMesage(message: JSONResponse["message"].stringValue)
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
