//
//  BoardingCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class BoardingCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var imgGIF: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var imgBackgroundTopConstraint: NSLayoutConstraint?
    @IBOutlet weak var lblDescriptionBottomConstraint: NSLayoutConstraint?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Constants.DeviceType.IS_IPHONE_X {
            self.imgBackgroundTopConstraint?.constant = -100
            self.lblDescriptionBottomConstraint?.constant = -85
        } else if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
            self.imgBackgroundTopConstraint?.constant = -135
            self.lblDescriptionBottomConstraint?.constant = -100
        } else if Constants.DeviceType.IS_IPHONE_12_PRO {
            self.imgBackgroundTopConstraint?.constant = -125
            self.lblDescriptionBottomConstraint?.constant = -90
        } else if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
            self.imgBackgroundTopConstraint?.constant = -140
            self.lblDescriptionBottomConstraint?.constant = -115
        } else {
            self.imgBackgroundTopConstraint?.constant = -100
            self.lblDescriptionBottomConstraint?.constant = -60
        }
    }
}
