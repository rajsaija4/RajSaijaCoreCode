//
//  FundTypeVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/03/22.
//

import UIKit

class FundTypeVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewCard: UIView!
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var viewBank: UIView!
    @IBOutlet weak var lblBank: UILabel!
    
    @IBOutlet weak var stackViewEmailUs: UIStackView!
    @IBOutlet weak var lblDepositDesc: UILabel!
    
    var isFromAdd:Bool = false
    var strAmount:String = ""
    
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
            
            self.viewCard.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.viewBank.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblCard.textColor = UIColor.labelTextColor
        self.lblBank.textColor = UIColor.labelTextColor
                
        self.lblDepositDesc.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "If you wish to deposit more than $3,000+ please email us at" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblDepositDesc.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: "deposit@prospuh.com", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblDepositDesc.font.pointSize + 1)!, strSecondColor: UIColor.init(hex: 0x27B1FC))
        
        if self.isFromAdd {
            self.lblTitle.text = "Add From"
            
            self.viewCard.isHidden = false
            self.viewBank.isHidden = true
            
            self.stackViewEmailUs.isHidden = false
        } else {
            self.lblTitle.text = "Withdraw To"
            
            self.viewCard.isHidden = true
            self.viewBank.isHidden = false
            
            self.stackViewEmailUs.isHidden = true
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCardClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "CardListVC") as! CardListVC
        controller.isFromAdd = self.isFromAdd
        controller.strAmount = self.strAmount
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBankClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "BankListVC") as! BankListVC
        controller.isFromAdd = self.isFromAdd
        controller.strAmount = self.strAmount
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
