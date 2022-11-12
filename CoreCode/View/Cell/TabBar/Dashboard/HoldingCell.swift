//
//  HoldingCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 10/11/21.
//

import UIKit

class HoldingCell: UITableViewCell {

    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockQty: UILabel!
    @IBOutlet weak var lblStockAmount: UILabel!
    @IBOutlet weak var lblStockVariation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewStock.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.imgStock.layer.cornerRadius = self.imgStock.layer.frame.size.width/2
        }
        
        self.lblStockName.textColor = UIColor.labelTextColor
        self.lblStockQty.textColor = UIColor.DontHaveAnAccount
        self.lblStockAmount.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
