//
//  ProfileCell.swift
//  projectName
//
//  companyName on 27/12/21.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblName.textColor = UIColor.labelTextColor
        self.lblDescription.textColor = UIColor.tblMarketDepthContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
