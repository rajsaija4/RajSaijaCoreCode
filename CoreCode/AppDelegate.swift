

import UIKit
import UserNotifications
import IQKeyboardManagerSwift
import SideMenuSwift
import SwiftyJSON

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let drawerController = SideMenuController()
    
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    class func shared() -> (AppDelegate) {
        let sharedinstance = UIApplication.shared.delegate as! AppDelegate
        return sharedinstance
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.layoutIfNeededOnUpdate = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysShow
        IQKeyboardManager.shared.toolbarTintColor = UIColor.textFieldTextColor
        IQKeyboardManager.shared.placeholderColor = UIColor.iqKeyboardToolbarPlaceholder
        IQKeyboardManager.shared.toolbarPreviousNextAllowedClasses.append(UIView.self)
        
        SideMenuController.preferences.basic.menuWidth = (UIScreen.main.bounds.width * 0.8)
        SideMenuController.preferences.basic.statusBarBehavior = .none
        SideMenuController.preferences.basic.position = .above
        SideMenuController.preferences.basic.direction = .left
        SideMenuController.preferences.basic.enablePanGesture = true
        SideMenuController.preferences.basic.supportedOrientations = .portrait
        SideMenuController.preferences.basic.shouldRespectLanguageDirection = true
        SideMenuController.preferences.animation.shadowAlpha = 0.8
        SideMenuController.preferences.animation.shadowColor = UIColor.init(hex: 0x333333, a: 1.0)
        
        self.setApperance()
        
        GlobalData.shared.customizationSVProgressHUD()
        
        self.registerForPushNotifications()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupDashboardSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        if defaults.object(forKey: kAuthToken) != nil || defaults.object(forKey: kAuthToken) as? String != "" {
            if defaults.bool(forKey: biometricLockEnabled) {
                if !UIApplication.topViewController()!.isKind(of: VerifyLoginBiometricVC.self) {
                    let vc = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "VerifyLoginBiometricVC") as! VerifyLoginBiometricVC
                    //                    vc.modalPresentationStyle = .overFullScreen
                    UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                }
                
                //                if UIApplication.topViewController()!.isKind(of: VerifyLoginBiometricVC.self) {
                //                    UIApplication.topViewController()?.dismiss(animated: false, completion: {
                //                        let vc = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "VerifyLoginBiometricVC") as! VerifyLoginBiometricVC
                //                        vc.modalPresentationStyle = .overFullScreen
                //                        UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                //                    })
                //                }
            }
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.overrideApplicationThemeStyle()
        UIApplication.shared.applicationIconBadgeNumber = 0
        if defaults.object(forKey: kAuthToken) != nil {
            callGetProfileAPI()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
    }
    
    func setApperance() {
        UITabBar.appearance().itemWidth = (window?.frame.size.width)! / 5
        UITabBar.appearance().barTintColor = Constants.Color.TAB_BARTINT
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 9)!, NSAttributedString.Key.foregroundColor: Constants.Color.TAB_NORMAL], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 9)!, NSAttributedString.Key.foregroundColor: Constants.Color.TAB_SELECTED], for: .selected)
    }
    
    func logoutUser() {
        DispatchQueue.main.async {
            objUserDetail = UserDetail()
            
            defaults.set(false, forKey: biometricLockEnabled)
            defaults.set(nil, forKey: kAuthToken)
            defaults.removeObject(forKey: kAuthToken)
            defaults.removeObject(forKey: kLoggedInUserData)
            defaults.synchronize()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let navController = UINavigationController.init(rootViewController: controller)
                appDelegate.window?.rootViewController = navController
            }
        }
    }
}

// MARK: - PUSH NOTIFICATION CODE -

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            debugPrint("Permission granted: \(granted)")
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        defaults.set(token, forKey: "deviceToken")
        defaults.synchronize()
        debugPrint("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        debugPrint("Failed to register for remote notifications with error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("The Push Notification: \(userInfo)")
        let state = application.applicationState
        
        switch state {
            
        case .inactive:
            debugPrint("Inactive")
            
        case .background:
            debugPrint("Background")
            // update badge count here
            application.applicationIconBadgeNumber = application.applicationIconBadgeNumber + 1
            
        case .active:
            debugPrint("Active")
            
        @unknown default:
            debugPrint("default")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
        debugPrint("The Push Notification: \(response.notification.request.content.userInfo)")
        debugPrint("When app is in background and tapped notification")
        
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            debugPrint("The userinfo is : ==> \(userInfo)")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let title:String = notification.request.content.title
        if title == "Your account is deactivated by admin" {
            appDelegate.logoutUser()
        }
        else {
            debugPrint("account is active")
        }
        
        if let userInfo = notification.request.content.userInfo as? [String: Any] {
            debugPrint("The userinfo is : ==> \(userInfo)")
            debugPrint("When app is in foreground")
            debugPrint("Pushnotification count is -----")
            
            let state = UIApplication.shared.applicationState
            
            if state == .active {
                completionHandler(.alert)
            } else {
                completionHandler(.alert)
            }
        } else {
            completionHandler(.alert)
        }
    }
}

// MARK: - THEME STYLE -

extension AppDelegate {
    func overrideApplicationThemeStyle() {
        if #available(iOS 13.0, *) {
            let isDarkMode = defaults.string(forKey: kIsDarkModeEnable)
            
            //            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = isDarkMode == "dark" ? .dark : .light
            window?.overrideUserInterfaceStyle = isDarkMode == "dark" ? .dark : .light
        } else {
            window?.overrideUserInterfaceStyle = .light
        }
    }
}


//MARK: - API CALL -

extension AppDelegate {
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
                        if object.active == false {
                            appDelegate.logoutUser()
                        }
                        else {
                            debugPrint("app is active")
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
}
