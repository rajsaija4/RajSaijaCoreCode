//
//  TaxDocumentCell.swift
//  projectName
//
//  companyName on 30/12/21.
//

import UIKit

class TaxDocumentCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblSubtitle.textColor = UIColor.tblStatementContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
