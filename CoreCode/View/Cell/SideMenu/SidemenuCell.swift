//
//  SidemenuCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 09/11/21.
//

import UIKit

class SidemenuCell: UITableViewCell {

    @IBOutlet weak var vwContent: UIView!
    @IBOutlet weak var imgVwOption: UIImageView!
    @IBOutlet weak var lblOption: UILabel!
    @IBOutlet weak var customSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.customSwitch.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
