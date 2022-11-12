//
//  FundTransactionCell.swift
//  projectName
//
//  companyName on 29/03/22.
//

import UIKit

class FundTransactionCell: UITableViewCell {

    @IBOutlet weak var stackviewHeader: UIStackView!
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var lblStatusTitle: UILabel!
    @IBOutlet weak var lblAmountTitle: UILabel!
    
    @IBOutlet weak var stackviewContent: UIStackView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblDateTitle.textColor = UIColor.labelTextColor
        self.lblStatusTitle.textColor = UIColor.labelTextColor
        self.lblAmountTitle.textColor = UIColor.labelTextColor
        
        self.lblDate.textColor = UIColor.tblMarketDepthContent
        self.lblAmount.textColor = UIColor.tblMarketDepthContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
