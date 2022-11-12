//
//  AccountVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 27/12/21.
//

import UIKit
import SwiftyJSON
import SwiftValidators
import Photos
import MobileCoreServices
import SDWebImage
import LocalAuthentication
import CountryPickerView

class AccountVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var viewGreenBG: UIView!
    @IBOutlet weak var viewAccInfo: UIView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSince: UILabel!
    
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var countryPicker: CountryPickerView!
    @IBOutlet weak var btnEditPhone: UIButton!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtNationality: UITextField!
    @IBOutlet weak var txtUploadedId: UITextField!
    @IBOutlet weak var txtChangePass: UITextField!
    @IBOutlet weak var txtSignout: UITextField!
    
    var strCountryCode = ""
    
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
        self.countryPicker.delegate = self
        self.countryPicker.showCountryCodeInView = false
        self.countryPicker.showPhoneCodeInView = true
        self.countryPicker.showCountryNameInView = false
        self.countryPicker.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 16.0)!
        self.countryPicker.textColor = UIColor.init(hex: 0x333333)
        self.countryPicker.flagSpacingInView = 0.0
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewGreenBG.roundCorners(corners: [.topLeft, .topRight], radius: 8)
            self.viewAccInfo.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8)
            self.viewAccInfo.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewProfile.layer.cornerRadius = self.viewProfile.layer.frame.size.width / 2
        }
        
        self.txtPhone.textColor = UIColor.textFieldTextColor
        self.txtEmail.textColor = UIColor.textFieldTextColor
        self.txtNationality.textColor = UIColor.textFieldTextColor
        self.txtUploadedId.textColor = UIColor.textFieldTextColor
        self.txtChangePass.textColor = UIColor.textFieldTextColor
        self.txtSignout.textColor = UIColor.textFieldTextColor

        self.txtEmail.alpha = 0.6
        self.txtEmail.isUserInteractionEnabled = false
        self.txtNationality.isUserInteractionEnabled = false
        self.txtUploadedId.isUserInteractionEnabled = false
        self.txtChangePass.isUserInteractionEnabled = false
        self.txtSignout.isUserInteractionEnabled = false
        
        self.countryPicker.isUserInteractionEnabled = false
        self.txtPhone.isUserInteractionEnabled = false
        self.btnEditPhone.setImage(UIImage(named: "ic_pen"), for: .normal)
        
        self.txtNationality.text = "Nationality"
        self.txtUploadedId.text = "Change Uploaded ID"
        self.txtChangePass.text = "Change Password"
        self.txtSignout.text = "Signout"
        
        self.callGetProfileAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnImageClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.showMediaPickerOptions()
    }
    
    @IBAction func btnEditPhoneClick(_ sender: UIButton) {
        if self.btnEditPhone.hasImage(named: "ic_pen", for: .normal) {
            self.btnEditPhone.setImage(UIImage(named: "ic_save"), for: .normal)
            self.countryPicker.isUserInteractionEnabled = true
            self.txtPhone.isUserInteractionEnabled = true
        } else {
            let phonetrimmedString = self.txtPhone.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if self.strCountryCode == "" {
                GlobalData.shared.showDarkStyleToastMesage(message: "Country code is required")
            }
            else if self.txtPhone.isEmpty() == 1 {
                GlobalData.shared.showDarkStyleToastMesage(message: "Phone number is required")
            }
            else if !self.txtPhone.isValidPhone() {
                GlobalData.shared.showDarkStyleToastMesage(message: "Phone number is invalid")
            }
            else if !Validator.minLength(10).apply(phonetrimmedString) {
                GlobalData.shared.showDarkStyleToastMesage(message: "Phone number should be 10 character long")
            }
            else {
                self.btnEditPhone.isUserInteractionEnabled = false
                self.callUpdatePhoneNumberAPI()
            }
        }
    }
    
    @IBAction func btnNationalityClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "NationalityVC") as! NationalityVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnUploadIdClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "UploadIdVC") as! UploadIdVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnChangePassClick(_ sender: UIButton) {
        self.view.endEditing(true)
        
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnSignoutClick(_ sender: UIButton) {
        self.view.endEditing(true)
        let alert = UIAlertController(title: "Are you sure you want to signout?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction) in
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
            appDelegate.logoutUser()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - COUNTRY PICKER DELEGATE METHOD -

extension AccountVC: CountryPickerViewDelegate {
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {

        debugPrint("Name: \(country.name) \nCode: \(country.code) \nPhone: \(country.phoneCode)")
        self.strCountryCode = country.phoneCode
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension AccountVC: UITextFieldDelegate {
    
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

//MARK: - SHOW MEDIA PICKER OPTIONS -

extension AccountVC {
    
    func showMediaPickerOptions() {
        let fromCameraAction = UIAlertAction(title: "Take from Camera", style: .default) { (_) in
            self.pickerAction(sourceType: .camera)
        }
        
        let fromPhotoLibraryAction = UIAlertAction(title: "Choose from Gallery", style: .default) { (_) in
            self.pickerAction(sourceType: .photoLibrary)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alert = UIAlertController(title: "Upload picture", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(fromCameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(fromPhotoLibraryAction)
        }
        alert.addAction(cancelAction)
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = self.view //sender
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.imgProfile.frame.origin.y - 60, width: 0, height: 0) //sender.bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }

        self.present(alert, animated: true, completion: nil)
    }
    
    func pickerAction(sourceType : UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = [kUTTypeImage as String]
            if sourceType == .camera {
                self.cameraAccessPermissionCheck(completion: { (success) in
                    if success {
                        self.present(picker, animated: true, completion: nil)
                    } else {
                        self.alertForPermissionChange(forFeature: "Camera", library: "Camera", action: "take")
                    }
                })
            }
            if sourceType == .photoLibrary {
                self.photosAccessPermissionCheck(completion: { (success) in
                    if success {
                        self.present(picker, animated: true, completion: nil)
                    } else {
                        self.alertForPermissionChange(forFeature: "Photos", library: "Photo Library", action: "select")
                    }
                })
            }
        }
    }
    
    func alertForPermissionChange(forFeature feature: String, library: String, action: String) {
        let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
            UIApplication.shared.openSettings()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Please enable camera access from Settings > reiwa.com > Camera to take photos
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "App"
        
        let title = "\"\(appName)\" " + "Would Like to Access the" + " \(library)"
        let message = "Please enable" + " \(library) " + "access from Settings" + " > \(appName) > \(feature) " + "to" + " \(action) " + "photos"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func cameraAccessPermissionCheck(completion: @escaping (Bool) -> Void) {
        let cameraMediaType = AVMediaType.video
        let cameraAutherisationState = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAutherisationState {
        case .authorized:
            completion(true)
        case .denied, .notDetermined, .restricted:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (granted) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            })
        @unknown default:
            break
        }
    }
    
    func photosAccessPermissionCheck(completion: @escaping (Bool)->Void) {
        let photosStatus = PHPhotoLibrary.authorizationStatus()
        switch photosStatus {
        case .authorized:
            completion(true)
        case .denied, .notDetermined, .restricted:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            })
        @unknown default:
            break
        }
    }
}

//MARK: - UIIMAGEPICKER CONTROLLER DELEGATE -

extension AccountVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        let image = info[.originalImage] as! UIImage
        let image = info[.editedImage] as! UIImage
        let data = image.jpegData(compressionQuality: 0.5)!
        self.imgProfile.image = image
        self.imgProfile.contentMode = .scaleAspectFill
        
        var name: String?
        if #available(iOS 11.0, *) {
            if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
                let assetResources = PHAssetResource.assetResources(for: asset)
                name = assetResources.first!.originalFilename
            }
        } else {
            if let imageURL = info[.referenceURL] as? URL {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
                let assetResources = PHAssetResource.assetResources(for: result.firstObject!)
                name = assetResources.first?.originalFilename
            }
        }
        
        let filename = "\(Int64(Date().timeIntervalSince1970 * 1000.0))_profileImage.jpg"
        let document = Document(
            uploadParameterKey: "profileImage",
            data: data,
            name: name ?? filename,
            fileName: filename,
            mimeType: "image/jpeg"
        )
        
        picker.dismiss(animated: true, completion: nil)
        
        self.callUpdateProfileImageAPI(files: [document])
    }
}

//MARK: - API CALL -

extension AccountVC {
    //GET PROFILE API
    func callGetProfileAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }

        let params: [String:Any] = [:]

        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)

        AFWrapper.shared.requestPOSTURL(Constants.URLS.GET_PROFILE, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }

            GlobalData.shared.hideProgress()

            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {

                        let userDetail = response["data"] as! Dictionary<String, Any>
                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())

                        if let data = try? JSONEncoder().encode(object) {
                            defaults.set(data, forKey: kLoggedInUserData)
                            defaults.synchronize()

                            objUserDetail = object
                            
                            let date = objUserDetail.createdAt.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
                            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
                            
                            strongSelf.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                            strongSelf.imgProfile.sd_setImage(with: URL(string: objUserDetail.profileImage.trim()), placeholderImage: UIImage.init(named: "user_placeholder"))
                            
                            strongSelf.lblName.text = objUserDetail.givenName + " " + objUserDetail.familyName
                            strongSelf.lblSince.text = "Since \(finalDate ?? "")"
                            
                            strongSelf.strCountryCode = objUserDetail.contactCountryCode
                            strongSelf.txtPhone.text = objUserDetail.contactNo
                            strongSelf.txtEmail.text = objUserDetail.email
                            
                            //SET COUNTRY BASED ON DIAL CODE
                            strongSelf.countryPicker.setCountryByPhoneCode(strongSelf.strCountryCode)
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
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //UPDATE PROFILE IMAGE API
    func callUpdateProfileImageAPI(files: [Document] = []) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let params: [String:Any] = [:]
        
        let strURL = Constants.URLS.UPDATE_PROFILE_IMAGE + "/" + objUserDetail._id
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.postWithUploadMultipleFiles(files, strURL: strURL, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.callGetProfileAPI()
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //UPDATE PHONE NUMBER API
    func callUpdatePhoneNumberAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        var params: [String:Any] = [:]
        params["contactCountryCode"] = self.strCountryCode
        params["contactNo"] = self.txtPhone.text ?? ""
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestPOSTURL(Constants.URLS.UPDATE_CONTACT_INFO, params: params, headers: nil, success: { [weak self] (JSONResponse) -> Void in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        
                        strongSelf.btnEditPhone.isUserInteractionEnabled = true
                        strongSelf.btnEditPhone.setImage(UIImage(named: "ic_pen"), for: .normal)
                        
                        strongSelf.countryPicker.isUserInteractionEnabled = false
                        strongSelf.txtPhone.isUserInteractionEnabled = false
                        
                        strongSelf.callGetProfileAPI()
                        
//                        let userDetail = response["data"] as! Dictionary<String, Any>
//                        let object: UserDetail = UserDetail.initWith(dict: userDetail.removeNull())
//
//                        if let data = try? JSONEncoder().encode(object) {
//                            defaults.set(data, forKey: kLoggedInUserData)
//                            defaults.synchronize()
//
//                            objUserDetail = object
//                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        }) { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
