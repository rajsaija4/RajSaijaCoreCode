//
e on 29/03/22.
//

import UIKit
import SwiftyJSON

class FundsBalancesVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblEquityTitle: UILabel!
    @IBOutlet weak var lblEquityValue: UILabel!
    @IBOutlet weak var lblEquityDesc: UILabel!
    
    @IBOutlet weak var lblBuyingTitle: UILabel!
    @IBOutlet weak var lblBuyingValue: UILabel!
    @IBOutlet weak var lblBuyingDesc: UILabel!
    
    @IBOutlet weak var lblUnsettledTitle: UILabel!
    @IBOutlet weak var lblUnsettledValue: UILabel!
    @IBOutlet weak var lblUnsettledDesc: UILabel!
    
    @IBOutlet weak var lblBankingTitle: UILabel!
    @IBOutlet weak var lblWithdrawalTitle: UILabel!
    @IBOutlet weak var lblWithdrawalValue: UILabel!
    
    @IBOutlet weak var btnAddFund: UIButton!
    @IBOutlet weak var btnWithdrawFund: UIButton!
    
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
            
            self.btnAddFund.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
            self.btnWithdrawFund.createButtonShadow(BorderColor: UIColor.init(hex: 0x27B1FC, a: 0.35), ShadowColor: UIColor.init(hex: 0x27B1FC, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblEquityTitle.textColor = UIColor.labelTextColor
        self.lblEquityValue.textColor = UIColor.labelTextColor
        self.lblEquityDesc.textColor = UIColor.tblStatementContent
        
        self.lblBuyingTitle.textColor = UIColor.labelTextColor
        self.lblBuyingValue.textColor = UIColor.labelTextColor
        self.lblBuyingDesc.textColor = UIColor.tblStatementContent
        
        self.lblUnsettledTitle.textColor = UIColor.labelTextColor
        self.lblUnsettledValue.textColor = UIColor.labelTextColor
        self.lblUnsettledDesc.textColor = UIColor.tblStatementContent
        
        self.lblBankingTitle.textColor = UIColor.labelTextColor
        self.lblWithdrawalTitle.textColor = UIColor.tblStatementContent
        self.lblWithdrawalValue.textColor = UIColor.labelTextColor
        
        //SET DATA
        let euityValue = (GlobalData.shared.objTradingAccount.equity as NSString).doubleValue
        let buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
        let withdrawableCash = (GlobalData.shared.objTradingAccount.cash_withdrawable as NSString).doubleValue
        
        self.lblEquityValue.text = "$" + convertThousand(value: euityValue)
        self.lblEquityDesc.text = "All the stock market investments made by you."
        
        self.lblBuyingValue.text = "$" + convertThousand(value: buyingPower)
        self.lblBuyingDesc.text = "The money you have available to buy securities."
        
        self.lblUnsettledValue.text = "$" + "0.0"
        self.lblUnsettledDesc.text = "They are funds that simply haven't cleared yet. As a good rule of thumb, unsettled funds in  will take between 3 and 5 business days to settle."
        
        self.lblWithdrawalValue.text = "$" + convertThousand(value: withdrawableCash)
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddFundClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundAmountVC") as! FundAmountVC
        controller.isFromMenu = false
        controller.isFromAdd = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnWithdrawFundClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundAmountVC") as! FundAmountVC
        controller.isFromMenu = false
        controller.isFromAdd = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
