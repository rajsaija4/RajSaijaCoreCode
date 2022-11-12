//
//  MarketDepthCell.swift
//  projectName
//
//  companyName on 18/11/21.
//

import UIKit

class MarketDepthCell: UITableViewCell {

    @IBOutlet weak var stackviewHeader: UIStackView!
    @IBOutlet weak var lblBidQtyTitle: UILabel!
    @IBOutlet weak var lblBidPriceTitle: UILabel!
    @IBOutlet weak var lblOfferQtyTitle: UILabel!
    @IBOutlet weak var lblOfferPriceTitle: UILabel!
    
    @IBOutlet weak var stackviewContent: UIStackView!
    @IBOutlet weak var lblBidQty: UILabel!
    @IBOutlet weak var lblBidPrice: UILabel!
    @IBOutlet weak var lblOfferQty: UILabel!
    @IBOutlet weak var lblOfferPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        self.lblBidQtyTitle.textColor = UIColor.labelTextColor
        self.lblBidPriceTitle.textColor = UIColor.labelTextColor
        self.lblOfferQtyTitle.textColor = UIColor.labelTextColor
        self.lblOfferPriceTitle.textColor = UIColor.labelTextColor
        
        self.lblBidQty.textColor = UIColor.tblMarketDepthContent
        self.lblBidPrice.textColor = UIColor.tblMarketDepthContent
        self.lblOfferQty.textColor = UIColor.tblMarketDepthContent
        self.lblOfferPrice.textColor = UIColor.tblMarketDepthContent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
