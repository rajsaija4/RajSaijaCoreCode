//
//  NewsCell.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 18/11/21.
//

import UIKit

class NewsCell: UITableViewCell {

    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var imgNews: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewContainer.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.imgNews.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5)
        }
        self.lblTitle.textColor = UIColor.tblMarketDepthContent
        self.lblDescription.textColor = UIColor.labelTextColor
        self.lblDate.textColor = UIColor.btnChartColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
