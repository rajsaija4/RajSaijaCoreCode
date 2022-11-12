//
//  CardCell.swift
//  projectName
//
//  companyName on 30/03/22.
//

import UIKit

class CardCell: UITableViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgCardBG: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCardNo: UILabel!
    @IBOutlet weak var lblCardType: UILabel!
    @IBOutlet weak var lblExpiryDate: UILabel!
    @IBOutlet weak var lblEdit: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lblDelete: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnTick: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
//            self.viewContainer.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.imgCardBG.layer.masksToBounds = false
            self.imgCardBG.layer.shadowRadius = 1
            self.imgCardBG.layer.shadowOpacity = 0.6
            self.imgCardBG.layer.shadowColor = UIColor.init(hex: 0x000000, a: 0.2).cgColor
            self.imgCardBG.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
        self.lblEdit.textColor = UIColor.labelTextColor
        self.lblDelete.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
