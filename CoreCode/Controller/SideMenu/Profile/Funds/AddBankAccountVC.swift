//
//  AddBankAccountVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 07/04/22.
//

import UIKit
import DropDown
import SwiftyJSON

class AddBankAccountVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var txtBankName: ACFloatingTextfield!
    @IBOutlet weak var txtBankCode: ACFloatingTextfield!
    @IBOutlet weak var viewCodeType: UIView!
    @IBOutlet weak var lblCodeType: UILabel!
    @IBOutlet weak var txtCodeType: UITextField!
    @IBOutlet weak var txtAccNumber: ACFloatingTextfield!
    @IBOutlet weak var btnAdd: UIButton!
    
    var codeTypeDropDown = DropDown()
    
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
            
            self.btnAdd.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.txtBankName.textColor = UIColor.textFieldTextColor
        self.txtBankCode.textColor = UIColor.textFieldTextColor
        self.lblCodeType.textColor = UIColor.labelTextColor
        self.txtCodeType.textColor = UIColor.textFieldTextColor
        self.txtAccNumber.textColor = UIColor.textFieldTextColor
        
        self.txtCodeType.isUserInteractionEnabled = false
        
        self.setupCodeTypeDropDown()
    }
    
    //MARK: - HELPER -
    
    func setupCodeTypeDropDown() {
        self.codeTypeDropDown = DropDown()
        let arrCodeType = ["ABA", "BIC"]
        
        self.codeTypeDropDown.backgroundColor = .white
        self.codeTypeDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.codeTypeDropDown.textColor = .black
        self.codeTypeDropDown.selectedTextColor = .white
        
        self.codeTypeDropDown.anchorView = self.viewCodeType
        self.codeTypeDropDown.bottomOffset = CGPoint(x: 0, y:((self.codeTypeDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.codeTypeDropDown.dataSource = arrCodeType
        self.codeTypeDropDown.direction = .bottom
        self.codeTypeDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.codeTypeDropDown.cellHeight = 42
        
        if self.txtCodeType.text != "" {
            guard let index = arrCodeType.firstIndex(of: self.txtCodeType.text!) else { return }
            self.codeTypeDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.codeTypeDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtCodeType.text = item
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCodeTypeClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.codeTypeDropDown.show()
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if self.txtBankName.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Bank name is required")
        }
        else if self.txtBankCode.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Bank code is required")
        }
        else if self.txtCodeType.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Bank code type is required")
        }
        else if self.txtAccNumber.isEmpty() == 1 {
            GlobalData.shared.showDarkStyleToastMesage(message: "Bank account number is required")
        }
        else {
            self.btnAdd.isUserInteractionEnabled = false
            self.callAddBankDetailAPI()
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension AddBankAccountVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - API CALL -

extension AddBankAccountVC {
    //ADD BANK DETAIL API
    func callAddBankDetailAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["name"] = self.txtBankName.text ?? ""
        params["bankCode"] = self.txtBankCode.text ?? ""
        params["bankCodeType"] = self.txtCodeType.text ?? ""
        params["accountNumber"] = self.txtAccNumber.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_BANK, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true

                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnAdd.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnAdd.isUserInteractionEnabled = true
        }
    }
}
