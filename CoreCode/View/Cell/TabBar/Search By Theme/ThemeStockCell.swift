//

import UIKit

class ThemeStockCell: UITableViewCell {
    
    @IBOutlet weak var lblSymbolDescription: UILabel!
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockType: UILabel!
    @IBOutlet weak var lblStockAmount: UILabel!
    @IBOutlet weak var lblStockVariation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DispatchQueue.main.async {
            self.viewStock.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            self.imgStock.layer.cornerRadius = self.imgStock.layer.frame.size.width/2
        }
        
        self.lblStockName.textColor = UIColor.labelTextColor
        self.lblStockType.textColor = UIColor.DontHaveAnAccount
        self.lblStockAmount.textColor = UIColor.labelTextColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
