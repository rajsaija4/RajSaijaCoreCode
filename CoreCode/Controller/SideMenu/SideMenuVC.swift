//
//  SideMenuVC.swift

import UIKit
import SideMenuSwift
import SDWebImage
import LocalAuthentication

struct SideMenuOption {
    var image: UIImage
    var title: String
}

class SideMenuVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    //HEADER
    @IBOutlet weak var viewHeaderBG: UIView!
    @IBOutlet weak var viewHeaderBGsub1: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var tblVW: UITableView!
    @IBOutlet weak var viewSignout: UIView!
    @IBOutlet weak var imgUserTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewSignoutBottomConstraint: NSLayoutConstraint!
    
    var arrOptions = [SideMenuOption]()
    
    var notification:Bool = false
    var hasTouchID = Bool()
    var hasFaceID = Bool()
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.viewHeaderBG.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 22)
            self.viewHeaderBGsub1.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 22)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.setupViewDetail()
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            if UIDevice.current.hasNotch {
                self.imgUserTopConstraint.constant = 40
                self.viewSignoutBottomConstraint.constant = 20
            } else {
                self.imgUserTopConstraint.constant = 25
                self.viewSignoutBottomConstraint.constant = 0
            }
        }
        
        if objUserDetail.profileImage != "" {
            self.imgUser.sd_imageIndicator = SDWebImageActivityIndicator.white
            self.imgUser.sd_setImage(with: URL(string: objUserDetail.profileImage.trim()), placeholderImage: nil)
        } else {
            self.imgUser.image = UIImage.init(named: "ic_user")
        }
        self.lblUserName.text = objUserDetail.givenName + " " + objUserDetail.familyName
        
        self.imgUser.layer.cornerRadius = self.imgUser.layer.frame.size.width / 2
        self.imgUser.clipsToBounds = true
        
        self.arrOptions = [
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_dashboard"), title: "Dashboard"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_account"), title: "Profile"),
//            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_bell"), title: "Notification"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_refer"), title: "Refer Friends"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_deposit"), title: "Deposit"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_theme"), title: "Dark Mode"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_biometric"), title: "Biometric"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_alert"), title: "Alert List"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_suport"), title: "Support"),
            SideMenuOption(image: #imageLiteral(resourceName: "ic_menu_signout"), title: "Signout"),
        ]
        
        if let isRemember = defaults.object(forKey: kNotifcation) as? Bool {
            if isRemember == true {
                self.notification = true
            }
        }
        
        self.tblVW.register(UINib(nibName: "SidemenuCell", bundle: nil), forCellReuseIdentifier: "SidemenuCell")
        self.tblVW.reloadData()
        
        var error: NSError?
        self.hasTouchID = LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        self.hasFaceID = LAContext().canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &error)
    }
    
    //MARK: - HELPER -
    
    func authenticationWithTouchID() {
        let context : LAContext = LAContext()
        let myLocalizedReasonString = "Please use your Passcode"//"Scan your finger"
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: myLocalizedReasonString) { success, evaluateError in
                if success {
                    DispatchQueue.main.async {
                        defaults.set(true, forKey: biometricLockEnabled)
                        defaults.synchronize()
                        
                        let indexPosition = IndexPath(row: 6, section: 0)
                        self.tblVW.reloadRows(at: [indexPosition], with: .none)
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
    
    func showErrorMessageForLAErrorCode(errorCode: Int) {
        if let cell = self.tblVW.cellForRow(at: IndexPath(row: 6, section: 0)) as? SidemenuCell {
            if cell.lblOption.text == "Biometric" {
                cell.customSwitch.isOn = false
            }
        }
        
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
            
        case LAError.userFallback.rawValue:
            debugPrint("The user chose to use the fallback")
            
        default:
            debugPrint("Did not find error code on LAError object")
        }
    }
    
    //MARK: - ACTION -
}

//MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension SideMenuVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SidemenuCell") as! SidemenuCell
        
        cell.imgVwOption.image = self.arrOptions[indexPath.row].image
        cell.lblOption.text = self.arrOptions[indexPath.row].title
        
        if cell.lblOption.text == "Notification" {
            cell.customSwitch.isHidden = false
            
            if self.notification == true {
                cell.customSwitch.isOn = true
            } else {
                cell.customSwitch.isOn = false
            }
        }
        else if cell.lblOption.text == "Dark Mode" {
            cell.customSwitch.isHidden = false
            
            let isDarkMode = defaults.string(forKey: kIsDarkModeEnable)
            cell.customSwitch.isOn = isDarkMode == "dark" ? true : false
        }
        else if cell.lblOption.text == "Biometric" {
            cell.customSwitch.isOn = defaults.bool(forKey: biometricLockEnabled)
            
            if !self.hasTouchID && !self.hasFaceID {
                cell.customSwitch.isOn = false
                defaults.set(false, forKey: biometricLockEnabled)
                defaults.synchronize()
            }
            
            cell.customSwitch.isHidden = false
        }
        else {
            cell.customSwitch.isHidden = true
        }
        
        cell.customSwitch.tag = indexPath.row
        cell.customSwitch.addTarget(self, action: #selector(customSwitchClick), for: .valueChanged)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let name = self.arrOptions[indexPath.row].title
        
        if name == "Dashboard" {
            let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
            let navController = UINavigationController.init(rootViewController: controller)
            navController.setNavigationBarHidden(true, animated: true)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Profile" {
            let controller = GlobalData.sideMenuStoryBoard().instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Notification" {
            debugPrint("Notification Click")
        }
        else if name == "Refer Friends" {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "ReferFriendsVC") as! ReferFriendsVC
            controller.isFromMenu = true
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Deposit" {
            let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundAmountVC") as! FundAmountVC
            controller.isFromMenu = true
            controller.isFromAdd = true
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Dark Mode" {
            debugPrint("Dark Mode Click")
        }
        else if name == "Biometric" {
            debugPrint("Biometric Click")
        }
        else if name == "Alert List" {
            let controller = GlobalData.sideMenuStoryBoard().instantiateViewController(withIdentifier: "AlertListVC") as! AlertListVC
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Support" {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            controller.isFromMenu = true
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.drawerController.contentViewController = navController
            appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        }
        else if name == "Signout" {
            let alert = UIAlertController(title: "Are you sure you want to signout?", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action: UIAlertAction) in
                appDelegate.drawerController.hideMenu(animated: true, completion:nil)
                appDelegate.logoutUser()
            }))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func customSwitchClick(_ sender: UISwitch) {
        let name = self.arrOptions[sender.tag].title
        
        if name == "Notification" {
            if sender.isOn {
                self.notification = true
            } else {
                self.notification = false
            }
            defaults.set(self.notification, forKey: kNotifcation)
            defaults.synchronize()
            
            let indexPosition = IndexPath(row: sender.tag, section: 0)
            self.tblVW.reloadRows(at: [indexPosition], with: .none)
        }
        else if name == "Dark Mode" {
            if sender.isOn {
                defaults.set("dark", forKey: kIsDarkModeEnable)
            } else {
                defaults.set("light", forKey: kIsDarkModeEnable)
            }
            
            appDelegate.overrideApplicationThemeStyle()
            
            let indexPosition = IndexPath(row: sender.tag, section: 0)
            self.tblVW.reloadRows(at: [indexPosition], with: .none)
        }
        else if name == "Biometric" {
            if sender.isOn {
                self.authenticationWithTouchID()
            } else {
                defaults.set(false, forKey: biometricLockEnabled)
                defaults.synchronize()
                
                let indexPosition = IndexPath(row: sender.tag, section: 0)
                self.tblVW.reloadRows(at: [indexPosition], with: .none)
            }
        }
    }
}
