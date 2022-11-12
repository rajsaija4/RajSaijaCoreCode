//
//  ReportCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 09/02/22.
//

import UIKit

class ReportCell: UITableViewCell {

    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblVariationAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.lblName.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
