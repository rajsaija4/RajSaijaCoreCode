//
//  MarketStockCell.swift
//  projectName
//
//  companyName on 30/11/21.
//

import UIKit

class MarketStockCell: UICollectionViewCell {
    
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var viewPriceBG: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
