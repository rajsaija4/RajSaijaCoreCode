//
//  BankCell.swift
//  projectName
//
//  companyName on 07/04/22.
//

import UIKit

class BankCell: UITableViewCell {

    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblAccNo: UILabel!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblAmount.textColor = UIColor.labelTextColor
        self.lblAccNo.textColor = UIColor.tblStatementContent
        self.lblDelete.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
