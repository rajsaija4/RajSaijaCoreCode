//
//  SplashVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit
import SwiftyJSON

class SplashVC: BaseVC {
    
    //MARK: - PROPERTIES & OUTLETS -
    
    var isDataAvailable: Bool = false
    
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
        self.getUtilityDataAPI()
    }
    
    //MARK: - HELPER -
    
    func setupRootController() {
        if self.isDataAvailable {
            if defaults.object(forKey: kAuthToken) != nil {
                if let data = defaults.value(forKey: kLoggedInUserData) as? Data,
                   let object = try? JSONDecoder().decode(UserDetail.self, from: data) {
                    
                    objUserDetail = object
                    
                    if objUserDetail.isVerified == true {
                        
                        if objUserDetail.active == true {
                            if defaults.bool(forKey: biometricLockEnabled) {
                                let vc = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "VerifyLoginBiometricVC") as! VerifyLoginBiometricVC
                                vc.isFromLaunch = true
                                UIApplication.topViewController()!.present(vc, animated: true, completion: nil)
                            } else {
                                let leftMenuVC = GlobalData.sideMenuStoryBoard().instantiateViewController(withIdentifier: "SideMenuVC") as! SideMenuVC
                                let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
                                let navController = UINavigationController.init(rootViewController: controller)
                                navController.setNavigationBarHidden(true, animated: true)
                                appDelegate.drawerController.contentViewController = navController
                                appDelegate.drawerController.menuViewController = leftMenuVC
                                appDelegate.window?.rootViewController = appDelegate.drawerController
                            }
                        }
                    }
                    
                    else {
                        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "ProcessVC") as! ProcessVC
                        controller.isfromLogin = true
                        let navController = UINavigationController.init(rootViewController: controller)
                        appDelegate.window?.rootViewController = navController
                    }
                }
                else {
                    let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let navController = UINavigationController.init(rootViewController: controller)
                    appDelegate.window?.rootViewController = navController
                }
            }
            else {
                let isOnBoradingScreenDisplay: Bool = defaults.bool(forKey: isOnBoradingScreenDisplayed)
                if !isOnBoradingScreenDisplay {
                    let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "OnboardingVC") as! OnboardingVC
                    let navController = UINavigationController.init(rootViewController: controller)
                    appDelegate.window?.rootViewController = navController
                }
                else {
                    let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let navController = UINavigationController.init(rootViewController: controller)
                    appDelegate.window?.rootViewController = navController
                    
                }
            }
        }
    }
}

//MARK: - API CALL -

extension SplashVC {
    func getUtilityDataAPI() {
        self.isDataAvailable = true
        self.setupRootController()
        /*
         if GlobalData.shared.checkInternet() == false {
         GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
         return
         }
         
         AFWrapper.shared.requestGETURL(Constants.URLS.GET_UTILITY) { (JSONResponse) in
         if JSONResponse != JSON.null {
         if let response = JSONResponse.rawValue as? [String : Any] {
         if response["status"] as! Int == successCode {
         let payloadData = response["data"] as! [String : Any]
         
         GlobalData.shared.objConfiguration = UtilityObject.init(payloadData)
         
         if let data = try? JSONEncoder().encode(GlobalData.shared.objConfiguration) {
         defaults.set(data, forKey:configurationData)
         defaults.synchronize()
         }
         
         self.isDataAvailable = true
         self.setupRootController()
         }
         //                    else if response["status"] as! Int == invalidTokenCode {
         //                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
         //                    }
         else {
         GlobalData.shared.showSystemToastMesage(message: (response["message"] as! String))
         }
         }
         }
         } failure: { (error) in
         GlobalData.shared.showSystemToastMesage(message: kNetworkError)
         }
         */
    }
}
