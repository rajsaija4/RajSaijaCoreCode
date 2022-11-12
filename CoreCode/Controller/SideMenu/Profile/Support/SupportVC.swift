//
//  SupportVC.swift

import UIKit
import SideMenuSwift
import SwiftyJSON

class SupportVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblFAQ: UILabel!
    @IBOutlet weak var lblHelp: UILabel!
    @IBOutlet weak var lblContactUs: UILabel!
    
    var isFromMenu: Bool = false
    var resultData: [String : Any] = [:]
    
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
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblFAQ.textColor = UIColor.labelTextColor
        self.lblHelp.textColor = UIColor.labelTextColor
        self.lblContactUs.textColor = UIColor.labelTextColor
        
        if self.isFromMenu == true {
            self.btnMenu.isHidden = false
            self.btnBack.isHidden = true
        } else {
            self.btnMenu.isHidden = true
            self.btnBack.isHidden = false
        }
        
        self.callStaticPageAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFAQClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
        controller.strPage = "FAQs"
        controller.strPageLink = "\(self.resultData["faq"] ?? "")"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnHelpClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StaticPageVC") as! StaticPageVC
        controller.strPage = "Help & Support"
        controller.strPageLink = "\(self.resultData["help"] ?? "")"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnContactUsClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "ContactUsVC") as! ContactUsVC
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - API CALL -

extension SupportVC {
    func callStaticPageAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.SUPPORT) { (JSONResponse) in
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        let payloadData = response["data"] as! [String : Any]
                        self.resultData = payloadData
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
            GlobalData.shared.hideProgress()
            GlobalData.shared.showSystemToastMesage(message: kNetworkError)
        }
    }
}
