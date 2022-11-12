//
//  

import UIKit
import Photos
import MobileCoreServices

typealias passDocument = (_ frontImage :UIImage, _ backImage: UIImage) ->()

class SelectDocumentVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var imgFront: UIImageView!
    @IBOutlet weak var lblFront: UILabel!
    @IBOutlet weak var imgBack: UIImageView!
    @IBOutlet weak var lblBack: UILabel!
    @IBOutlet weak var btnDone: UIButton!
    
    var completionBlock: passDocument?
    var strTitle: String = ""
    var frontImage: UIImage? = nil
    var backImage: UIImage? = nil
    
    var isSelectFrontImage:Bool = false
    
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
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblFront.textColor = UIColor.labelTextColor
        self.lblBack.textColor = UIColor.labelTextColor
        
        self.lblTitle.text = self.strTitle
        self.lblNote.text = "Note: Make sure your \(self.strTitle) detail are clear to read, with no blur or glare"
        self.lblFront.text = "Front of \(self.strTitle)"
        self.lblBack.text = "Back of \(self.strTitle)"
        
        self.imgFront.image = self.frontImage
        self.imgBack.image = self.backImage
        
        let objGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageFrontClick(_:)))
        self.imgFront.addGestureRecognizer(objGesture)
        self.imgFront.isUserInteractionEnabled = true
        
        let objGesture1:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.imageBackClick(_:)))
        self.imgBack.addGestureRecognizer(objGesture1)
        self.imgBack.isUserInteractionEnabled = true
    }
    
    //MARK: - HELPER -
    
    @objc func imageFrontClick(_ sender:UITapGestureRecognizer) -> Void {
        self.isSelectFrontImage = true
        self.showMediaPickerOptions()
    }
    
    @objc func imageBackClick(_ sender:UITapGestureRecognizer) -> Void {
        self.isSelectFrontImage = false
        self.showMediaPickerOptions()
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if self.imgFront.image == nil {
            GlobalData.shared.showDarkStyleToastMesage(message: "Front picture is required")
        }
        else if self.imgBack.image == nil {
            GlobalData.shared.showDarkStyleToastMesage(message: "Back picture is required")
        }
        else {
            guard let cb = completionBlock else {return}
            cb(self.imgFront.image!, self.imgBack.image!)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - SHOW MEDIA PICKER OPTIONS -

extension SelectDocumentVC {
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
            if self.isSelectFrontImage == true {
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.imgFront.frame.origin.y - 60, width: 0, height: 0) //sender.bounds
            } else {
                alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.imgBack.frame.origin.y - 60, width: 0, height: 0) //sender.bounds
            }
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

extension SelectDocumentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[.originalImage] as! UIImage
//        let image = info[.editedImage] as! UIImage
        
        if self.isSelectFrontImage == true {
            self.imgFront.image = image
            self.imgFront.contentMode = .scaleAspectFill
        } else {
            self.imgBack.image = image
            self.imgBack.contentMode = .scaleAspectFill
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
}
