//
//  OrdersCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 05/01/22.
//

import UIKit

class OrdersCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblQty: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblType: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblMarket: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewContainer.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewStatus.roundCorners(corners: [.topLeft, .bottomRight], radius: 6)
        }
        
        self.lblStatus.textColor = UIColor.white
        self.lblName.textColor = UIColor.labelTextColor
        self.lblType.textColor = UIColor.tblMarketDepthContent
        self.lblPrice.textColor = UIColor.labelTextColor
        self.lblMarket.textColor = UIColor.init(hex: 0xA7A7A7, a: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
