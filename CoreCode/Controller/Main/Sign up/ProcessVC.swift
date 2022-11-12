//
//  ProcessV
//

import UIKit
import SwiftValidators
import SwiftyJSON
import LocalAuthentication
import Alamofire
import Onfido

class ProcessVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var lblNavTitle: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var imgSignup: UIImageView!
    @IBOutlet weak var imgNationality: UIImageView!
    @IBOutlet weak var imgUploadId: UIImageView!
    @IBOutlet weak var imgBenForm: UIImageView!
    @IBOutlet weak var imgBenDeclaration: UIImageView!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    var isfromLogin:Bool = false
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
            
            self.viewContent.roundCorners(corners: [.topLeft], radius: 27)
            
            self.btnSubmit.createButtonShadow(BorderColor: UIColor.init(hex: 0xFFFFFF, a: 0.35), ShadowColor: UIColor.init(hex: 0xFFFFFF, a: 0.35))
        }
        
        self.lblNavTitle.textColor = UIColor.labelTextColor
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblDescription.textColor = UIColor.labelTextColor
        
        //SET DATA
        self.setupData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateNationality), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateDocument), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateW8BenForm), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateW8BenDeclaration), object: nil)
    }
    
    func setupData() {
        if isfromLogin {
            btnBack.isHidden = true
        }
        else {
            btnBack.isHidden = false
        }
        self.imgSignup.image = UIImage.init(named: "ic_tick_white")
        
        if (objUserDetail.nationality == "" && objUserDetail.countryOfResidency == "") {
            self.imgNationality.image = UIImage.init(named: "ic_untick_white")
        } else {
            self.imgNationality.image = UIImage.init(named: "ic_tick_white")
        }
        
        if objUserDetail.documents == false {
            self.imgUploadId.image = UIImage.init(named: "ic_untick_white")
        } else {
            self.imgUploadId.image = UIImage.init(named: "ic_tick_white")
        }
        
        if objUserDetail.W8BENForm == false {
            self.imgBenForm.image = UIImage.init(named: "ic_untick_white")
        } else {
            self.imgBenForm.image = UIImage.init(named: "ic_tick_white")
        }
        
        if objUserDetail.W8BENDeclaration == false {
            self.imgBenDeclaration.image = UIImage.init(named: "ic_untick_white")
        } else {
            self.imgBenDeclaration.image = UIImage.init(named: "ic_tick_white")
        }
    }
    
    //MARK: - HELPER -
    
    @objc func updateData() {
        self.setupData()
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnNationalityClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "NationalityVC") as! NationalityVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnUploadIdClick(_ sender: UIButton) {
        
        guard objUserDetail.alphacId.count > 0 else {
            GlobalData.shared.showDarkStyleToastMesage(message: "Please Try After Sometime Currently We Can't Process With Your Request")
            return
        }
        let id = objUserDetail.alphacId
        setupOnfido(id: id)
//                let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "UploadIdVC") as! UploadIdVC
//                self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBenFormClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "WBenFormVC") as! WBenFormVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBenDeclarationClick(_ sender: UIButton) {
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "WBenDeclarationVC") as! WBenDeclarationVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnSubmitClick(_ sender: UIButton) {
        if (objUserDetail.nationality == "" && objUserDetail.countryOfResidency == "") {
            GlobalData.shared.showSystemToastMesage(message: "Nationality is required")
        }
        else if objUserDetail.documents == false {
            GlobalData.shared.showSystemToastMesage(message: "Upload document is required")
        }
        else if objUserDetail.W8BENForm == false {
            GlobalData.shared.showSystemToastMesage(message: "Accept W-8Ben form terms")
        }
        else if objUserDetail.W8BENDeclaration == false {
            GlobalData.shared.showSystemToastMesage(message: "Accept W-8Ben declaration terms")
        }
        else {
            let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "BacktoLoginVC") as! BacktoLoginVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}


extension ProcessVC {
    
    func setupOnfido(id:String) {
        
        let tokenid = id
        let baseurl = "https://broker-api.sandbox.alpaca.markets/v1/accounts/\(tokenid)/onfido/sdk/tokens/"
        
        var headers:HTTPHeaders = HTTPHeaders([:])
        headers = ["Authorization":"Basic Q0sxMDAxM0RXT0xNWkJJRThJQVE6Y1RsQ3kzQnpJVGZaazcwSXNDWGNrRURTTHBIVTZzOXBaQjRUZlhnYQ=="]
        
        AF.request(baseurl,
                   method:.get,
                   parameters: nil,
                   encoding:URLEncoding.default,
                   headers:headers).responseString(completionHandler: { (responseString:DataResponse) in
            print(responseString) }).responseData { response in
                switch response.result {
                case .success(let data):
                    let data = JSON(data)
                    
                    let responseHandler: (OnfidoResponse) -> Void = { response in
                        
                        if case OnfidoResponse.error(let innerError) = response {
                            self.showErrorMessage(forError: innerError)
                        } else if case OnfidoResponse.success = response {
                            // SDK flow has been completed successfully. You may want to create a check in your backend at this point.
                            // Follow https://github.com/onfido/onfido-ios-sdk#2-creating-a-check to understand how to create a check
                            let alert = UIAlertController(title: "Success", message: "SDK flow has been completed successfully", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                                GlobalData.shared.showToastMessage(message: "api calling started for backend")
                                self.callUploadDocumentAPI()
                            })
                            alert.addAction(alertAction)
                            self.present(alert, animated: true)
                        } else if case OnfidoResponse.cancel = response {
                            let alert = UIAlertController(title: "Canceled", message: "Canceled by user", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
                            alert.addAction(alertAction)
                            self.present(alert, animated: true)
                        }
                    }
                    
                    let sdkToken: String = data["token"].stringValue
                    
                    let config = try! OnfidoConfig.builder()
                        .withSDKToken(sdkToken)
                        .withWelcomeStep()
                    //            .withDocumentStep(ofSelectableTypes: [.passport,.drivingLicence])
                        .withDocumentStep()
                    //            .withDocumentStep(ofType: .drivingLicence(config: DrivingLicenceConfiguration(country: "GBR")))
                        .withFaceStep(ofVariant: .photo(withConfiguration: nil))
                        .build()
                    
                    let onfidoFlow = OnfidoFlow(withConfiguration: config)
                        .with(responseHandler: responseHandler)
                    
                    do {
                        let onfidoRun = try onfidoFlow.run()
                        
                        var modalPresentationStyle: UIModalPresentationStyle = .fullScreen // due to iOS 13 you must specify .fullScreen as the default is now .pageSheet
                        
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            modalPresentationStyle = .formSheet // to present modally on iPads
                        }
                        
                        onfidoRun.modalPresentationStyle = modalPresentationStyle
                        self.present(onfidoRun, animated: true, completion: nil)
                    } catch {
                        self.showErrorMessage(forError: error)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        
    }
    
    private func showErrorMessage(forError error: Error) {
        let alert = UIAlertController(title: "Error", message: "Onfido SDK errored \(error)", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in })
        alert.addAction(alertAction)
        self.present(alert, animated: true)
    }
}

extension ProcessVC {
    
    func callUploadDocumentAPI() {
        
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.UPLOAD_DOCUMENT + "/" + objUserDetail._id
        
        var params: [String:Any] = [:]
        params["onfidoStatus"] = true
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(strURL, params: params) { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        let userDetail = response["data"] as! Dictionary<String, Any>
                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())
                        
                        if let data = try? JSONEncoder().encode(object) {
                            defaults.set(data, forKey: kLoggedInUserData)
                            defaults.synchronize()
                            
                            objUserDetail = object
                            
                            NotificationCenter.default.post(name: Notification.Name(kUpdateDocument), object: nil)
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
        } failure: { error in
            GlobalData.shared.hideProgress()
            print(error.localizedDescription)
        }
    }
}
