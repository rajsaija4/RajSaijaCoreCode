//
//  TransferCell.swift
//  projectName
//
//  companyName on 04/01/22.
//

import UIKit

class TransferCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblName.textColor = UIColor.labelTextColor
        self.lblDate.textColor = UIColor.tblStatementContent
        self.lblAmount.textColor = UIColor.tblStatementContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
