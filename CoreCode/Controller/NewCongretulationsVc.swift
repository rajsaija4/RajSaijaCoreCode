
import UIKit
import SDWebImage

class NewCongretulationsVc: UIViewController {
    
    @IBOutlet weak var imgGif: UIImageView!
    @IBOutlet weak var lblOrderRecieve: UILabel!
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var lblStockPrice: UILabel!
    @IBOutlet weak var imgSymbol: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockCompany: UILabel!
    var objStockDetail = AssetsObject.init([:])
    var isSelectedBuy:Bool = true
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        
        imgGif.loadGif(name: "celebration_gif")
        lblStockName.text = "\(self.objStockDetail.name)"
        lblStockCompany.text = "\(self.objStockDetail.symbol)"
        if self.objStockDetail.image == "" {
            self.viewStock.backgroundColor = UIColor.black
            let dpName = self.objStockDetail.symbol.prefix(1)
            self.imgSymbol.image = GlobalData.shared.GenrateImageFromText(imageWidth: self.imgSymbol.frame.size.width, imageHeight: self.imgSymbol.frame.size.height, name: "\(dpName)")
            
        } else {
            self.viewStock.backgroundColor = UIColor.white
            self.imgSymbol.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgSymbol.sd_setImage(with: URL(string: self.objStockDetail.image), placeholderImage: nil)
        }
        
        if objStockDetail.current_price != 0.0 {
            self.lblStockPrice.text = "$\(objStockDetail.current_price)"
        }
        else {
            self.lblStockPrice.text = "$\(objStockDetail.objSnapshot.objDailyBar.c)"
        }
        
        if isSelectedBuy {
            lblOrderRecieve.text = "Buy Order Received !"
        }
        else {
            lblOrderRecieve.text = "Sell Order Received !"
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPressBtnBackToHome(_ sender: UIButton) {
        let controller = GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "TabBarVC") as! TabBarVC
        let navController = UINavigationController.init(rootViewController: controller)
        navController.setNavigationBarHidden(true, animated: true)
        appDelegate.drawerController.contentViewController = navController
        appDelegate.drawerController.hideMenu(animated: true, completion:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
