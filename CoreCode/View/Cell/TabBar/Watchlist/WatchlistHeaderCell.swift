//
//  WatchlistHeaderCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 25/11/21.
//

import UIKit

class WatchlistHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.lblTitle.textColor = UIColor.labelTextColor
    }
}
