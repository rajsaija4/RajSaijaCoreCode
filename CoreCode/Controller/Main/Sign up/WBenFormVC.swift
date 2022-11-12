//
//  WBenFormVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 02/11/21.
//

import UIKit
import SwiftyJSON

class WBenFormVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var lblOption1: UILabel!
    @IBOutlet weak var btnOption1: UIButton!
    @IBOutlet weak var lblOption2: UILabel!
    @IBOutlet weak var btnOption2: UIButton!
    @IBOutlet weak var lblOption3: UILabel!
    @IBOutlet weak var btnOption3: UIButton!
    @IBOutlet weak var lblOption4: UILabel!
    @IBOutlet weak var btnOption4: UIButton!
    
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
        self.lblDescription.textColor = UIColor.labelTextColor
        
        self.lblOption1.textColor = UIColor.labelTextColor
        self.lblOption2.textColor = UIColor.labelTextColor
        self.lblOption3.textColor = UIColor.labelTextColor
        self.lblOption4.textColor = UIColor.labelTextColor
        
        self.btnOption1.isSelected = objUserDetail.W8BENForm
        self.btnOption2.isSelected = objUserDetail.W8BENForm
        self.btnOption3.isSelected = objUserDetail.W8BENForm
        self.btnOption4.isSelected = objUserDetail.W8BENForm
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOption1Click(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnOption2Click(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnOption3Click(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnOption4Click(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        if self.btnOption1.isSelected == false || self.btnOption2.isSelected == false || self.btnOption3.isSelected == false || self.btnOption4.isSelected == false {
            GlobalData.shared.showSystemToastMesage(message: "Please check all box if you want to submit")
        }
        else {
            self.btnSubmit.isUserInteractionEnabled = false
            self.callUpdateW8BenFormAPI()
        }
    }
}

//MARK: - API CALL -

extension WBenFormVC {
    func callUpdateW8BenFormAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPDATE_W8BEN_FORM + "/" + objUserDetail._id
        
        var params: [String:Any] = [:]
        params["w8benform"] = true
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.btnSubmit.isUserInteractionEnabled = true
                        
                        objUserDetail.W8BENForm = true
                        //
                        do {
                            if let data = defaults.value(forKey: kLoggedInUserData) {
                                let userDetails = try JSONDecoder().decode(UserDetail.self, from: data as! Data)
                                userDetails.W8BENForm = true
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
                        
                        NotificationCenter.default.post(name: Notification.Name(kUpdateW8BenForm), object: nil)
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
