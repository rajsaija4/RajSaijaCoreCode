//
//  OrderTypeVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 31/01/22.
//

import UIKit
import SwiftyJSON

typealias passOrderType = (_ orderType: String) ->()

struct OrderTypeOption {
    var image: UIImage
    var title: String
    var description: String
    var orderType: String
}

class OrderTypeVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var tblList: UITableView!
    
    var isFromBuy:Bool = false
    var completionBlock: passOrderType?
    var arrOptions: [OrderTypeOption] = []
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
//            self.viewContent.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
//            self.viewContent.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        if self.isFromBuy {
            self.arrOptions = [
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_transfer_prospuh"), title: "Buy in Dollars", description: "Lorem Ipsum is simply dummy text", orderType: "market"),
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_buy_share"), title: "Buy in Shares", description: "Lorem Ipsum is simply dummy text", orderType: "market"),
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_transfer_bank"), title: "Limit Order", description: "Lorem Ipsum is simply dummy text", orderType: "limit"),
                OrderTypeOption(image: #imageLiteral(resourceName: "trailing_stop_order"), title: "Trailing Stop Order", description: "Lorem Ipsum is simply dummy text", orderType: "trailing_stop"),
                OrderTypeOption(image: #imageLiteral(resourceName: "stop_order"), title: "Stop Order", description: "Lorem Ipsum is simply dummy text", orderType: "stop"),
                OrderTypeOption(image: #imageLiteral(resourceName: "stop_limit_order"), title: "Stop Limit Order", description: "Lorem Ipsum is simply dummy text", orderType: "stop_limit"),
            ]
        } else {
            self.arrOptions = [
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_transfer_prospuh"), title: "Sell in Dollars", description: "Lorem Ipsum is simply dummy text", orderType: "market"),
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_buy_share"), title: "Sell in Shares", description: "Lorem Ipsum is simply dummy text", orderType: "market"),
                OrderTypeOption(image: #imageLiteral(resourceName: "ic_transfer_bank"), title: "Limit Order", description: "Lorem Ipsum is simply dummy text", orderType: "limit"),
                OrderTypeOption(image: #imageLiteral(resourceName: "trailing_stop_order"), title: "Trailing Stop Order", description: "Lorem Ipsum is simply dummy text", orderType: "trailing_stop"),
                OrderTypeOption(image: #imageLiteral(resourceName: "stop_order"), title: "Stop Order", description: "Lorem Ipsum is simply dummy text", orderType: "stop"),
                OrderTypeOption(image: #imageLiteral(resourceName: "stop_limit_order"), title: "Stop Limit Order", description: "Lorem Ipsum is simply dummy text", orderType: "stop_limit"),
            ]
        }
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension OrderTypeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrOptions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTypeCell") as! OrderTypeCell
        
        cell.imgView.image = self.arrOptions[indexPath.section].image
        cell.lblName.text = self.arrOptions[indexPath.section].title
        cell.lblDescription.text = self.arrOptions[indexPath.section].description
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selOrderType = self.arrOptions[indexPath.section].orderType
        
        guard let cb = completionBlock else {return}
        cb(selOrderType)
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
