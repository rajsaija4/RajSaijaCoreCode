//
//  NationalityVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 01/11/21.
//

import UIKit
import DropDown
import SwiftyJSON

class NationalityVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var viewNationality: UIView!
    @IBOutlet weak var txtNationality: UITextField!
    @IBOutlet weak var viewCountry: UIView!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var btnConfirmation: UIButton!
    @IBOutlet weak var lblConfirmation: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
        
    var nationalityDropDown = DropDown()
    var countryDropDown = DropDown()
    
    var arrResult: [NationalityObject] = []
    
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
            
            self.btnContinue.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.txtNationality.textColor = UIColor.textFieldTextColor
        self.txtCountry.textColor = UIColor.textFieldTextColor
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblDescription.textColor = UIColor.labelTextColor
        self.lblConfirmation.textColor = UIColor.labelTextColor
        
        self.txtNationality.isUserInteractionEnabled = false
        self.txtCountry.isUserInteractionEnabled = false
        
        self.txtNationality.text = objUserDetail.nationality
        self.txtCountry.text = objUserDetail.countryOfResidency
        
        if self.txtNationality.text == "" || self.txtCountry.text == "" {
            self.btnConfirmation.isSelected = false
        } else {
            self.btnConfirmation.isSelected = true
        }
        
        self.callGetNationalityAPI()
    }
    
    //MARK: - HELPER -
    
    func setupNationalityDropDown() {
        self.nationalityDropDown = DropDown()
        let arrNationality = self.arrResult.map { $0.nationality }
        
        self.nationalityDropDown.backgroundColor = .white
        self.nationalityDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.nationalityDropDown.textColor = .black
        self.nationalityDropDown.selectedTextColor = .white
        
        self.nationalityDropDown.anchorView = self.viewNationality
        self.nationalityDropDown.bottomOffset = CGPoint(x: 0, y:((self.nationalityDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.nationalityDropDown.dataSource = arrNationality
        self.nationalityDropDown.direction = .bottom
        self.nationalityDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.nationalityDropDown.cellHeight = 42
        
        if self.txtNationality.text != "" {
            guard let index = arrNationality.firstIndex(of: self.txtNationality.text!) else { return }
            self.nationalityDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.nationalityDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtNationality.text = item
        }
    }
    
    func setupCountryDropDown() {
        self.countryDropDown = DropDown()
        let arrCountryResi = self.arrResult.map { $0.en_short_name }
        
        self.countryDropDown.backgroundColor = .white
        self.countryDropDown.selectionBackgroundColor = Constants.Color.THEME_GREEN
        self.countryDropDown.textColor = .black
        self.countryDropDown.selectedTextColor = .white
        
        self.countryDropDown.anchorView = self.viewCountry
        self.countryDropDown.bottomOffset = CGPoint(x: 0, y:((self.countryDropDown.anchorView?.plainView.bounds.height)! + 10))
        self.countryDropDown.dataSource = arrCountryResi
        self.countryDropDown.direction = .bottom
        self.countryDropDown.textFont = UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 15)!
        self.countryDropDown.cellHeight = 42
        
        if self.txtCountry.text != "" {
            guard let index = arrCountryResi.firstIndex(of: self.txtCountry.text!) else { return }
            self.countryDropDown.selectRow(index, scrollPosition: .top)
        }
        
        self.countryDropDown.selectionAction = { (index: Int, item: String) in
            debugPrint(item)
            self.txtCountry.text = item
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNationalityClick(_ sender: UIButton) {
        self.nationalityDropDown.show()
    }
    
    @IBAction func btnCountryClick(_ sender: UIButton) {
        self.countryDropDown.show()
    }
    
    @IBAction func btnConfirmationClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnContinueClick(_ sender: UIButton) {
        self.view.endEditing(true)
                
        if self.txtNationality.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Nationality is required")
        }
        else if self.txtCountry.isEmpty() == 1 {
            GlobalData.shared.showSystemToastMesage(message: "Country of residency is required")
        }
        else if self.btnConfirmation.isSelected == false {
            GlobalData.shared.showSystemToastMesage(message: "Accept Confirmation")
        }
        else {
            self.btnContinue.isUserInteractionEnabled = false
            self.callUpdateNationalityAPI()
        }
    }
}

//MARK: - API CALL -

extension NationalityVC {
    //GET NATIONALITY/COUNTRY REGION
    func callGetNationalityAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_NATIONALITY) { (JSONResponse) in
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            for i in 0..<payloadData.count {
                                let objData = NationalityObject.init(payloadData[i])
                                self.arrResult.append(objData)
                            }
                            
                            if self.arrResult.count > 0 {
                                self.setupNationalityDropDown()
                                self.setupCountryDropDown()
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //UPDATE NATIONALITY/COUNTRY REGION
    func callUpdateNationalityAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_NATIONALITY + "/" + objUserDetail._id
        
        var params: [String:Any] = [:]
        params["nationality"] = self.txtNationality.text ?? ""
        params["countryOfResidency"] = self.txtCountry.text ?? ""
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.btnContinue.isUserInteractionEnabled = true
                        
                        let userDetail = response["data"] as! Dictionary<String, Any>
                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())

                        if let data = try? JSONEncoder().encode(object) {
                            defaults.set(data, forKey: kLoggedInUserData)
                            defaults.synchronize()

                            objUserDetail = object
                            
                            NotificationCenter.default.post(name: Notification.Name(kUpdateNationality), object: nil)
                            strongSelf.navigationController?.popViewController(animated: true)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnContinue.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnContinue.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnContinue.isUserInteractionEnabled = true
        }
    }
}
