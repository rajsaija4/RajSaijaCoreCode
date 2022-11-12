//
//  ThingsCell.swift
//  projectName
//
//  companyName on 01/12/21.
//

import UIKit

class ThingsCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        let view = UIView()
        view.backgroundColor = UIColor.cellSelectionColor
        selectedBackgroundView = view
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
