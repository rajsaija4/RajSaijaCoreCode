//
//  StatementDetailVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 28/12/21.
//

import UIKit
import Foundation
import SwiftyJSON

class StatementDetailVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var btnStock: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStockName: UILabel!
    
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var lblStatusValue: UILabel!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblDateValue: UILabel!
    @IBOutlet weak var viewShareCount: UIView!
    @IBOutlet weak var lblShareCountTitle: UILabel!
    @IBOutlet weak var lblShareCountValue: UILabel!
    @IBOutlet weak var viewShareAmount: UIView!
    @IBOutlet weak var lblShareAmountTitle: UILabel!
    @IBOutlet weak var lblShareAmountValue: UILabel!
    @IBOutlet weak var lblTotalAmountTitle: UILabel!
    @IBOutlet weak var lblTotalAmountValue: UILabel!
    
    var strType: String = ""
    var objHistory = HistoryObject.init([:])
    var objTransfer = TransferObject.init([:])
    var objDividend = DividendObject.init([:])
    
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
        self.lblStockName.textColor = UIColor.tblStatementContent
        
        self.lblStatusTitle.textColor = UIColor.tblStatementContent
        self.lblStatusValue.textColor = UIColor.labelTextColor
        self.lblDateTitle.textColor = UIColor.tblStatementContent
        self.lblDateValue.textColor = UIColor.labelTextColor
        self.lblShareCountTitle.textColor = UIColor.tblStatementContent
        self.lblShareCountValue.textColor = UIColor.labelTextColor
        self.lblShareAmountTitle.textColor = UIColor.tblStatementContent
        self.lblShareAmountValue.textColor = UIColor.labelTextColor
        self.lblTotalAmountTitle.textColor = UIColor.tblStatementContent
        self.lblTotalAmountValue.textColor = UIColor.labelTextColor
        
        self.lblStatusTitle.text = "Status"
        self.lblDateTitle.text = "Scheduled Date"
        self.lblShareCountTitle.text = "Number Of Shares"
        self.lblShareAmountTitle.text = "Amount Per Share"
        self.lblTotalAmountTitle.text = "Total Amount"
        
        //SET DATA
        if self.strType == "History" {
            let date = self.objHistory.transaction_time.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
            
            let qty = (self.objHistory.qty as NSString).doubleValue
            let price = (self.objHistory.price as NSString).doubleValue
            let totalPrice = qty * price
            let roundedPrice = NSString(format: "%.2f", totalPrice)
            
            self.btnStock.setTitle("View \(self.objHistory.symbol)", for: [])
            
            self.lblTitle.text = "History"
            self.lblStockName.text = self.objHistory.symbol
            
            let status = self.objHistory.order_status.replacingOccurrences(of: "_", with: " ")
            
            //NOTE:- import Foundation and then use the capitalized property.
            self.lblStatusValue.text = status.capitalized
            self.lblDateValue.text = finalDate
            self.lblShareCountValue.text = self.objHistory.qty
            self.lblShareAmountValue.text = "$" + self.objHistory.price
            self.lblTotalAmountValue.text = "$" + "\(roundedPrice)"//"$" + "\(totalPrice)"
        }
        else if self.strType == "Transfer" {
            let date = self.objTransfer.created_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
                        
            self.lblTitle.text = "Transfer"
            if objTransfer.direction == "INCOMING" {
                self.lblStockName.text = "Deposit"
            } else {
                self.lblStockName.text = "Withdrawal"
            }
            
            let status = self.objTransfer.status.replacingOccurrences(of: "_", with: " ")
            
            self.lblStatusValue.text = status.capitalized
            self.lblDateValue.text = finalDate
            self.lblTotalAmountValue.text = "$" + self.objTransfer.amount
            
            self.btnStock.isHidden = true
            self.viewShareCount.isHidden = true
            self.viewShareAmount.isHidden = true
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnStockClick(_ sender: UIButton) {
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
        controller.strSymbol = self.objHistory.symbol
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
