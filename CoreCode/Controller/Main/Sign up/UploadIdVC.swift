//
//  UploadIdVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 01/11/21.
//

import UIKit
import Alamofire
import SDWebImage
import SwiftyJSON

class UploadIdVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    @IBOutlet weak var viewPassport: UIView!
    @IBOutlet weak var lblPassport: UILabel!
    @IBOutlet weak var viewPassportArrow: UIView!
    @IBOutlet weak var viewLicense: UIView!
    @IBOutlet weak var lblLicense: UILabel!
    @IBOutlet weak var viewLicenseArrow: UIView!
    @IBOutlet weak var viewVoterCard: UIView!
    @IBOutlet weak var lblVoterCard: UILabel!
    @IBOutlet weak var viewVoterCardArrow: UIView!
    @IBOutlet weak var viewInsurance: UIView!
    @IBOutlet weak var lblInsurance: UILabel!
    @IBOutlet weak var viewInsuranceArrow: UIView!
    
    var imgPassportFront = UIImageView()
    var imgPassportBack = UIImageView()
    var imgLicenceFront = UIImageView()
    var imgLicenceBack = UIImageView()
    var imgVoterFront = UIImageView()
    var imgVoterBack = UIImageView()
    var imgInsuranceFront = UIImageView()
    var imgInsuranceBack = UIImageView()
    
    var documentFiles: [Document] = []
    var selectedDocs: [String] = []
    
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    
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
            
            self.viewPassport.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.viewLicense.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.viewVoterCard.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.viewInsurance.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
                        
            self.btnContinue.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
                
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblDescription.textColor = UIColor.labelTextColor
        
        self.lblPassport.textColor = UIColor.labelTextColor
        self.lblLicense.textColor = UIColor.labelTextColor
        self.lblVoterCard.textColor = UIColor.labelTextColor
        self.lblInsurance.textColor = UIColor.labelTextColor
        
        self.startTimer()
        
        self.setupSelectedArrowView()
    }
    
    //MARK: - HELPER -
    
    func startTimer() {
        if self.isTimerRunning == false {
            GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
            self.runTimer()
        }
    }
    
    func runTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(UploadIdVC.updateTimer), userInfo: nil, repeats: true)
        
        self.isTimerRunning = true
    }
    
    @objc func updateTimer() {
        self.seconds += 1
        debugPrint(timeString(time: TimeInterval(self.seconds)))
        
        if self.seconds >= 3 {
            self.timer.invalidate()
            self.seconds = 0
            self.isTimerRunning = false
            GlobalData.shared.hideProgress()
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func setupSelectedArrowView() {
        if objUserDetail.documents == false {
            self.viewPassportArrow.backgroundColor = Constants.Color.THEME_GREEN
            self.viewLicenseArrow.backgroundColor = Constants.Color.THEME_GREEN
            self.viewVoterCardArrow.backgroundColor = Constants.Color.THEME_GREEN
            self.viewInsuranceArrow.backgroundColor = Constants.Color.THEME_GREEN
        }
        else {
            if objUserDetail.objPassportInfo.passportFront != "" && objUserDetail.objPassportInfo.passportBack != "" {
                self.imgPassportFront.sd_setImage(with: URL(string: objUserDetail.objPassportInfo.passportFront.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                self.imgPassportBack.sd_setImage(with: URL(string: objUserDetail.objPassportInfo.passportBack.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                
                self.selectedDocs.append("Passport")
                
                self.viewPassportArrow.backgroundColor = Constants.Color.THEME_BLUE
            } else {
                self.viewPassportArrow.backgroundColor = Constants.Color.THEME_GREEN
            }
            
            if objUserDetail.objLicenceInfo.drivingLicenseFront != "" && objUserDetail.objLicenceInfo.drivingLicenseBack != "" {
                self.imgLicenceFront.sd_setImage(with: URL(string: objUserDetail.objLicenceInfo.drivingLicenseFront.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                self.imgLicenceBack.sd_setImage(with: URL(string: objUserDetail.objLicenceInfo.drivingLicenseBack.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                
                self.selectedDocs.append("Driving license")
                
                self.viewLicenseArrow.backgroundColor = Constants.Color.THEME_BLUE
            } else {
                self.viewLicenseArrow.backgroundColor = Constants.Color.THEME_GREEN
            }
            
            if objUserDetail.objVoterCardInfo.voterCardFront != "" && objUserDetail.objVoterCardInfo.voterCardBack != "" {
                self.imgVoterFront.sd_setImage(with: URL(string: objUserDetail.objVoterCardInfo.voterCardFront.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                self.imgVoterBack.sd_setImage(with: URL(string: objUserDetail.objVoterCardInfo.voterCardBack.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                
                self.selectedDocs.append("Voter card")
                
                self.viewVoterCardArrow.backgroundColor = Constants.Color.THEME_BLUE
            } else {
                self.viewVoterCardArrow.backgroundColor = Constants.Color.THEME_GREEN
            }
            
            if objUserDetail.objInsuranceInfo.insuranceFront != "" && objUserDetail.objInsuranceInfo.insuranceBack != "" {
                self.imgInsuranceFront.sd_setImage(with: URL(string: objUserDetail.objInsuranceInfo.insuranceFront.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                self.imgInsuranceBack.sd_setImage(with: URL(string: objUserDetail.objInsuranceInfo.insuranceBack.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), placeholderImage: nil)
                
                self.selectedDocs.append("National insurance")
                
                self.viewInsuranceArrow.backgroundColor = Constants.Color.THEME_BLUE
            } else {
                self.viewInsuranceArrow.backgroundColor = Constants.Color.THEME_GREEN
            }
        }
    }
    
    func createDocumentFiles() {
        let userName = objUserDetail.givenName + " " + objUserDetail.familyName

        if self.imgPassportFront.image != nil && self.imgPassportBack.image != nil {
            guard let frontData = self.imgPassportFront.image?.jpegData(compressionQuality: 0.5)! else { return }
            let fullName = userName.replacingOccurrences(of: " ", with: "-")
            let frontName = "\(fullName)_passportFront.jpg"
            let frontDocument = Document(
                uploadParameterKey: "passportFront",
                data: frontData,
                name: frontName,
                fileName: frontName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(frontDocument)
            
            guard let backData = self.imgPassportBack.image?.jpegData(compressionQuality: 0.5)! else { return }
            let backName = "\(fullName)_passportBack.jpg"
            let backDocument = Document(
                uploadParameterKey: "passportBack",
                data: backData,
                name: backName,
                fileName: backName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(backDocument)
        }
        if self.imgLicenceFront.image != nil && self.imgLicenceBack.image != nil {
            guard let frontData = self.imgLicenceFront.image?.jpegData(compressionQuality: 0.5)! else { return }
            let fullName = userName.replacingOccurrences(of: " ", with: "-")
            let frontName = "\(fullName)_drivingLicenseFront.jpg"
            let frontDocument = Document(
                uploadParameterKey: "drivingLicenseFront",
                data: frontData,
                name: frontName,
                fileName: frontName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(frontDocument)
            
            guard let backData = self.imgLicenceBack.image?.jpegData(compressionQuality: 0.5)! else { return }
            let backName = "\(fullName)_drivingLicenseBack.jpg"
            let backDocument = Document(
                uploadParameterKey: "drivingLicenseBack",
                data: backData,
                name: backName,
                fileName: backName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(backDocument)
        }
        if self.imgVoterFront.image != nil && self.imgVoterBack.image != nil {
            guard let frontData = self.imgVoterFront.image?.jpegData(compressionQuality: 0.5)! else { return }
            let fullName = userName.replacingOccurrences(of: " ", with: "-")
            let frontName = "\(fullName)_voterCardFront.jpg"
            let frontDocument = Document(
                uploadParameterKey: "voterCardFront",
                data: frontData,
                name: frontName,
                fileName: frontName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(frontDocument)
            
            guard let backData = self.imgVoterBack.image?.jpegData(compressionQuality: 0.5)! else { return }
            let backName = "\(fullName)_voterCardBack.jpg"
            let backDocument = Document(
                uploadParameterKey: "voterCardBack",
                data: backData,
                name: backName,
                fileName: backName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(backDocument)
        }
        if self.imgInsuranceFront.image != nil && self.imgInsuranceBack.image != nil {
            guard let frontData = self.imgInsuranceFront.image?.jpegData(compressionQuality: 0.5)! else { return }
            let fullName = userName.replacingOccurrences(of: " ", with: "-")
            let frontName = "\(fullName)_insuranceFront.jpg"
            let frontDocument = Document(
                uploadParameterKey: "insuranceFront",
                data: frontData,
                name: frontName,
                fileName: frontName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(frontDocument)
            
            guard let backData = self.imgInsuranceBack.image?.jpegData(compressionQuality: 0.5)! else { return }
            let backName = "\(fullName)_insuranceBack.jpg"
            let backDocument = Document(
                uploadParameterKey: "insuranceBack",
                data: backData,
                name: backName,
                fileName: backName,
                mimeType: "image/jpeg"
            )
            self.documentFiles.append(backDocument)
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPassportClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SelectDocumentVC") as! SelectDocumentVC
        controller.strTitle = "Passport"
        controller.frontImage = self.imgPassportFront.image
        controller.backImage = self.imgPassportBack.image
        controller.completionBlock = {[weak self] (frontImage, backImage) in
            guard let strongSelf = self else { return }
            
            strongSelf.imgPassportFront.image = frontImage
            strongSelf.imgPassportBack.image = backImage
            
            if !strongSelf.selectedDocs.contains("Passport") {
                strongSelf.selectedDocs.append("Passport")
            }
            
            strongSelf.viewPassportArrow.backgroundColor = Constants.Color.THEME_BLUE
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnLicenseClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SelectDocumentVC") as! SelectDocumentVC
        controller.strTitle = "Driving license"
        controller.frontImage = self.imgLicenceFront.image
        controller.backImage = self.imgLicenceBack.image
        controller.completionBlock = {[weak self] (frontImage, backImage) in
            guard let strongSelf = self else { return }
            
            strongSelf.imgLicenceFront.image = frontImage
            strongSelf.imgLicenceBack.image = backImage
            
            if !strongSelf.selectedDocs.contains("Driving license") {
                strongSelf.selectedDocs.append("Driving license")
            }
            
            strongSelf.viewLicenseArrow.backgroundColor = Constants.Color.THEME_BLUE
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnVoterCardClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SelectDocumentVC") as! SelectDocumentVC
        controller.strTitle = "Voter card"
        controller.frontImage = self.imgVoterFront.image
        controller.backImage = self.imgVoterBack.image
        controller.completionBlock = {[weak self] (frontImage, backImage) in
            guard let strongSelf = self else { return }
            
            strongSelf.imgVoterFront.image = frontImage
            strongSelf.imgVoterBack.image = backImage
            
            if !strongSelf.selectedDocs.contains("Voter card") {
                strongSelf.selectedDocs.append("Voter card")
            }
            
            strongSelf.viewVoterCardArrow.backgroundColor = Constants.Color.THEME_BLUE
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnInsuranceClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "SelectDocumentVC") as! SelectDocumentVC
        controller.strTitle = "National insurance"
        controller.frontImage = self.imgInsuranceFront.image
        controller.backImage = self.imgInsuranceBack.image
        controller.completionBlock = {[weak self] (frontImage, backImage) in
            guard let strongSelf = self else { return }
            
            strongSelf.imgInsuranceFront.image = frontImage
            strongSelf.imgInsuranceBack.image = backImage
            
            if !strongSelf.selectedDocs.contains("National insurance") {
                strongSelf.selectedDocs.append("National insurance")
            }
            
            strongSelf.viewInsuranceArrow.backgroundColor = Constants.Color.THEME_BLUE
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnContinueClick(_ sender: UIButton) {
        if self.selectedDocs.count < 2 {
            GlobalData.shared.showSystemToastMesage(message: "Select any two document is required")
        } else {
            self.createDocumentFiles()

            self.btnContinue.isUserInteractionEnabled = false
            self.callUploadDocumentAPI()
        }
    }
}

//MARK: - API CALL -

extension UploadIdVC {
    func callUploadDocumentAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPLOAD_DOCUMENT + "/" + objUserDetail._id
        
        let params: [String:Any] = [:]
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.postWithUploadMultipleFiles(self.documentFiles, strURL: strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
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
                            
                            NotificationCenter.default.post(name: Notification.Name(kUpdateDocument), object: nil)
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
