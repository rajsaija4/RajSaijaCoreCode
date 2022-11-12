//
//  ProfileVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 27/12/21.
//

import UIKit
import SideMenuSwift
import SwiftyJSON

struct ProfileOption {
    var image: UIImage
    var title: String
    var description: String
}

class ProfileVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMember: UILabel!
    
    @IBOutlet weak var tblList: ContentSizedTableView!
    @IBOutlet weak var tblListHeightConstraint: NSLayoutConstraint!
    
    var arrOptions = [
        ProfileOption(image: #imageLiteral(resourceName: "ic_account"), title: "Account", description: "Details, Security & Profile"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_statement"), title: "Statements & History", description: "Documents, Account Activity"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_orders"), title: "Orders", description: "Orders Pending, Executed, Closed"),
//        ProfileOption(image: #imageLiteral(resourceName: "ic_investing"), title: "Investing", description: "Balances"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_transfers"), title: "Transfers", description: "Deposits, Withdrawals"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_funds"), title: "Funds & Balances", description: "Balance, Manage Transfers & Banking"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_funds"), title: "Funds Transaction", description: "Add, Withdraw Fund History"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_bell"), title: "Notifications", description: "Lorem Ipsum Text"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_refer"), title: "Refer Friends", description: "Refer and Earn"),
        ProfileOption(image: #imageLiteral(resourceName: "ic_support"), title: "Support", description: "Browse FAQs or Contact Us"),
    ]
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblListHeightConstraint.constant = self.tblList.contentSize.height
        }
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
        
        self.lblName.textColor = UIColor.labelTextColor
        self.lblMember.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.callGetProfileAPI()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension ProfileVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileCell
        
        cell.imgView.image = self.arrOptions[indexPath.section].image
        cell.lblName.text = self.arrOptions[indexPath.section].title
        cell.lblDescription.text = self.arrOptions[indexPath.section].description
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "AccountVC") as! AccountVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 1 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "StatementHistoryVC") as! StatementHistoryVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 2 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "OrdersVC") as! OrdersVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
//        else if indexPath.section == 3 {
//            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "InvestingVC") as! InvestingVC
//            self.navigationController?.pushViewController(controller, animated: true)
//        }
        else if indexPath.section == 3 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "TransfersVC") as! TransfersVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 4 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "FundsBalancesVC") as! FundsBalancesVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 5 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "FundsTransactionVC") as! FundsTransactionVC
            controller.isSelectedAdd = true
            controller.isNeedToPopOnly = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 6 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else if indexPath.section == 7 {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "ReferFriendsVC") as! ReferFriendsVC
            controller.isFromMenu = false
            self.navigationController?.pushViewController(controller, animated: true)
        }
        else {
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "SupportVC") as! SupportVC
            controller.isFromMenu = false
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension ProfileVC {
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
                            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM yyyy")
                            
                            strongSelf.lblName.text = objUserDetail.givenName + " " + objUserDetail.familyName
                            strongSelf.lblMember.text = "Member Since \(finalDate ?? "")"
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
