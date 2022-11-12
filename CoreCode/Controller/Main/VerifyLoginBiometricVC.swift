//

import UIKit
import LocalAuthentication

class VerifyLoginBiometricVC: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    
    var isFromLaunch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.viewAlert.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
        
        self.viewAlert.isHidden = true
        
//        defaults.set(true, forKey: "isVerifyLoginActive")
//        defaults.synchronize()
        
        self.checkBiometric()
    }
    
    func checkBiometric() {
        self.authWithBiometric { (success) in
            if success == true {
//                AppDelegate.shared().startIdleTimer()
//                defaults.set(false, forKey: "isVerifyLoginActive")
//                defaults.synchronize()
                if self.isFromLaunch {
                    let leftMenuVC = GlobalData.sideMenuStoryBoard().instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                    let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                    let navController = UINavigationController.init(rootViewController: controller)
                    navController.setNavigationBarHidden(true, animated: true)
                    appDelegate.drawerController.contentViewController = navController
                    appDelegate.drawerController.menuViewController = leftMenuVC
                    appDelegate.window?.rootViewController = appDelegate.drawerController
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }

    // MARK: - BIOMETRIC AUTHENTICATION -
    
    func authWithBiometric(completion: @escaping (Bool) -> Void) {
        let context : LAContext = LAContext()
        let myLocalizedReasonString = "Please use your Passcode"//"Scan your finger"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        completion(true)
                    }
                } else {
                    if let error = evaluateError {
                        DispatchQueue.main.async {
                            self.showErrorMessageForLAErrorCode(errorCode: (error as NSError).code)
                        }
                    }
                }
            }
        } else {
            if let error = authError {
                DispatchQueue.main.async {
                    self.showErrorMessageForLAErrorCode(errorCode: (error as NSError).code)
                }
            }
        }
    }
    
    //BIOMETRIC AUTHENTICATION ERRORS
    func showErrorMessageForLAErrorCode(errorCode: Int) {
        switch errorCode {
        case LAError.appCancel.rawValue:
            debugPrint("Authentication was cancelled by application")
            
        case LAError.authenticationFailed.rawValue:
            debugPrint("The user failed to provide valid credentials")
            
        case LAError.invalidContext.rawValue:
            debugPrint("The context is invalid")
            
        case LAError.passcodeNotSet.rawValue:
            debugPrint("Passcode is not set on the device")
            
        case LAError.systemCancel.rawValue:
            debugPrint("Authentication was cancelled by the system")
            
        case LAError.biometryLockout.rawValue:
            debugPrint("Too many failed attempts.")
            GlobalData.shared.showDarkStyleToastMesage(message: "Too many failed attempts. Biometric is disabled.")
            
        case LAError.biometryNotAvailable.rawValue:
            debugPrint("TouchID is not available on the device")
            GlobalData.shared.showDarkStyleToastMesage(message: "No biometric features available on this device.")
            
        case LAError.biometryNotEnrolled.rawValue:
            debugPrint("TouchID is not enrolled on the device")
            GlobalData.shared.showDarkStyleToastMesage(message: "Biometric is not enrolled on the device.")
            
        case LAError.userCancel.rawValue:
            debugPrint("The user did cancel")
            
//            let alert = UIAlertController(title: "Alert", message: "Authentication is required", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
//                  self.checkBiometric()
//            }))
//            present(alert, animated: true, completion: nil)
            
            self.viewAlert.isHidden = false
            
        case LAError.userFallback.rawValue:
            debugPrint("The user chose to use the fallback")
            
        default:
            debugPrint("Did not find error code on LAError object")
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnOkClick(_ sender: UIButton) {
        self.viewAlert.isHidden = true
        self.checkBiometric()
    }
}
