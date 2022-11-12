
import UIKit

class ThemeCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        self.viewCategory.layer.cornerRadius = self.viewCategory.layer.frame.size.width / 2
        self.lblTitle.textColor = UIColor.white
    }
}
