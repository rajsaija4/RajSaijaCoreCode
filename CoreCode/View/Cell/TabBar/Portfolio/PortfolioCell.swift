//
//  PortfolioCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 08/12/21.
//

import UIKit

class PortfolioCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblAvg: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblInvested: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblVariation: UILabel!
    @IBOutlet weak var lblLTPValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewContainer.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
        
        self.lblName.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
