//
//  AlertCell.swift
//  projectName
//
//  companyName on 22/11/21.
//

import UIKit

class AlertCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblOfName: UILabel!
    @IBOutlet weak var lblNote: UILabel!
    @IBOutlet weak var lblAmountIsTitle: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewContainer.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewStatus.roundCorners(corners: [.topLeft, .bottomRight], radius: 6)
        }
        self.lblValidity.textColor = UIColor.tblMarketDepthContent
        self.lblOfName.textColor = UIColor.labelTextColor
        self.lblNote.textColor = UIColor.tblMarketDepthContent
        self.lblAmountIsTitle.textColor = UIColor.tblMarketDepthContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // You need to change the border color here
        self.btnDelete.layer.borderColor = UIColor.appColor(.deleteAlertBorder)?.cgColor
        self.btnEdit.layer.borderColor = UIColor.appColor(.editAlertBorder)?.cgColor
    }
}
