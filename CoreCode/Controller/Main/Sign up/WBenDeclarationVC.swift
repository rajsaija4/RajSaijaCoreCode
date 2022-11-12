//
//  WBenDeclarationVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 12/01/22.
//

import UIKit
import SwiftyJSON

class WBenDeclarationVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblLine1: UILabel!
    @IBOutlet weak var lblLine2: UILabel!
    @IBOutlet weak var lblLine3: UILabel!
    @IBOutlet weak var lblLine4: UILabel!
    @IBOutlet weak var lblLine5: UILabel!
    @IBOutlet weak var lblLine6: UILabel!
    @IBOutlet weak var lblLine7: UILabel!
    @IBOutlet weak var lblLine8: UILabel!
    @IBOutlet weak var lblLine9: UILabel!
    @IBOutlet weak var lblLine10: UILabel!
    
    @IBOutlet weak var lblAgreeTerms: UILabel!
    @IBOutlet weak var btnAgreeTerms: UIButton!
    
    @IBOutlet weak var btnSubmit: UIButton!
    
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
            
            self.btnSubmit.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblLine1.textColor = UIColor.labelTextColor
        self.lblLine2.textColor = UIColor.labelTextColor
        self.lblLine3.textColor = UIColor.labelTextColor
        self.lblLine4.textColor = UIColor.labelTextColor
        self.lblLine5.textColor = UIColor.labelTextColor
        self.lblLine6.textColor = UIColor.labelTextColor
        self.lblLine7.textColor = UIColor.labelTextColor
        self.lblLine8.textColor = UIColor.labelTextColor
        self.lblLine9.textColor = UIColor.labelTextColor
        self.lblLine10.textColor = UIColor.labelTextColor
        
        self.lblAgreeTerms.textColor = UIColor.taxExemptionAgreeTerms
        
        self.btnAgreeTerms.isSelected = objUserDetail.W8BENDeclaration
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAgreeTermsClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        if self.btnAgreeTerms.isSelected == false {
            GlobalData.shared.showSystemToastMesage(message: "Please check this box if you want to submit")
        }
        else {
            self.btnSubmit.isUserInteractionEnabled = false
            self.callUpdateW8BenDeclarationAPI()
        }
    }
}

//MARK: - API CALL -

extension WBenDeclarationVC {
    func callUpdateW8BenDeclarationAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_W8BEN_DECLARATION + "/" + objUserDetail._id
        
        var params: [String:Any] = [:]
        
        params["WBENDeclaration"] = true
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.btnSubmit.isUserInteractionEnabled = true
                        
                        objUserDetail.W8BENDeclaration = true
                        
                        //
                        do {
                            if let data = defaults.value(forKey: kLoggedInUserData) {
                                let userDetails = try JSONDecoder().decode(UserDetail.self, from: data as! Data)
                                userDetails.W8BENDeclaration = true
                                do {
                                    let data = try JSONEncoder().encode(userDetails)
                                    defaults.set(data, forKey: kLoggedInUserData)
                                } catch let error {
                                    print("Error encoding: \(error)")
                                }
                            }
                        } catch let error {
                            print("Error decoding: \(error)")
                        }
                        //
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateW8BenDeclaration), object: nil)
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        strongSelf.btnSubmit.isUserInteractionEnabled = true
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.btnSubmit.isUserInteractionEnabled = true
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
            self.btnSubmit.isUserInteractionEnabled = true
        }
    }
}
