//
//  AnalystPickCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/11/21.
//

import UIKit

class AnalystPickCell: UICollectionViewCell {
    
    @IBOutlet weak var viewBackImage: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewBackImage.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))

    }
}
