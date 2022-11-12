//
//  TaxDocumentVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/12/21.
//

import UIKit
import SwiftyJSON

class TaxDocumentVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblTaxDocumentTitle: UILabel!
    @IBOutlet weak var lblTaxDocumentDesc: UILabel!
    
    @IBOutlet weak var lblDocumentTitle: UILabel!
    @IBOutlet weak var tblList: ContentSizedTableView!
    @IBOutlet weak var tblListHeightConstraint: NSLayoutConstraint!
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblListHeightConstraint.constant = self.tblList.contentSize.height
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
        self.lblTaxDocumentTitle.textColor = UIColor.labelTextColor
        self.lblTaxDocumentDesc.textColor = UIColor.labelTextColor
        
        self.lblDocumentTitle.textColor = UIColor.tblMarketDepthContent
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension TaxDocumentVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaxDocumentCell") as! TaxDocumentCell
        
        cell.lblTitle.text = "2021- O'Cof Securities 1099"
        cell.lblSubtitle.text = "[PDF] Corrected Aug 10, 2021"
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
        controller.isFrom = "Tax Document"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
