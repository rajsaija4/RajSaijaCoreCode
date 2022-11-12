//
//  PopupPortfolioFilterVC.swift

import UIKit

protocol selectedFilterDelegate {
    func selectedFilter(sortBy: Int)
}

class PopupPortfolioFilterVC: UIViewController {
    
    // MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewPopupFilter: UIView!
    @IBOutlet weak var btnSortAlphabetic: UIButton!
    @IBOutlet weak var btnSortPercent: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    
    var sortBy:Int = -1
    
    var delegate : selectedFilterDelegate?
    
    // MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        self.setupSortButtons()
    }
    
    func setupSortButtons() {
        if self.sortBy == 0 {
            self.btnSortAlphabetic.backgroundColor = UIColor.init(hex: 0x81CF01, a: 1.0)
            self.btnSortPercent.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)

            self.btnSortAlphabetic.setTitleColor(UIColor.white, for: [])
            self.btnSortPercent.setTitleColor(UIColor.black, for: [])
        } else if self.sortBy == 1 {
            self.btnSortAlphabetic.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)
            self.btnSortPercent.backgroundColor = UIColor.init(hex: 0x81CF01, a: 1.0)

            self.btnSortAlphabetic.setTitleColor(UIColor.black, for: [])
            self.btnSortPercent.setTitleColor(UIColor.white, for: [])
        } else {
            self.btnSortAlphabetic.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)
            self.btnSortPercent.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)

            self.btnSortAlphabetic.setTitleColor(UIColor.black, for: [])
            self.btnSortPercent.setTitleColor(UIColor.black, for: [])
        }
    }
    
    //MARK: - HELPER -
    
    // MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func btnClearClick(_ sender: UIButton) {
        self.sortBy = -1
        
        self.btnSortAlphabetic.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)
        self.btnSortPercent.backgroundColor = UIColor.init(hex: 0x81CF01, a: 0.13)

        self.btnSortAlphabetic.setTitleColor(UIColor.black, for: [])
        self.btnSortPercent.setTitleColor(UIColor.black, for: [])
    }

    @IBAction func btnSortItemsClick(_ sender: UIButton) {
        if sender.tag == 1 {
            self.sortBy = 0
        } else if sender.tag == 2 {
            self.sortBy = 1
        }
        
        self.setupSortButtons()
    }

    @IBAction func btnDoneClick(_ sender: UIButton) {
        self.delegate?.selectedFilter(sortBy: self.sortBy)
        self.dismiss(animated: true, completion: nil)
    }
}
