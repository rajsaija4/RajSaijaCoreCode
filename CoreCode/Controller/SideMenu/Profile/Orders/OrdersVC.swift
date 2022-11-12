//
//  OrdersVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 30/12/21.
//

import UIKit
import SwiftyJSON

class OrdersVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblPending: UILabel!
    @IBOutlet weak var lblPendingCount: UILabel!
    @IBOutlet weak var viewLinePending: UIView!
    
    @IBOutlet weak var lblExecuted: UILabel!
    @IBOutlet weak var lblExecutedCount: UILabel!
    @IBOutlet weak var viewLineExecuted: UIView!
    
    @IBOutlet weak var lblClosed: UILabel!
    @IBOutlet weak var lblClosedCount: UILabel!
    @IBOutlet weak var viewLineClosed: UIView!
    
    //PENDING VIEW
    @IBOutlet weak var viewPending: UIView!
    @IBOutlet weak var searchBarPending: UISearchBar!
    @IBOutlet weak var tblPendingList: UITableView!
    @IBOutlet weak var lblNoPending: UILabel!
    
    //EXECUTED VIEW
    @IBOutlet weak var viewExecuted: UIView!
    @IBOutlet weak var searchBarExecuted: UISearchBar!
    @IBOutlet weak var tblExecutedList: UITableView!
    @IBOutlet weak var lblNoExecuted: UILabel!
    
    //CLOSED VIEW
    @IBOutlet weak var viewClosed: UIView!
    @IBOutlet weak var searchBarClosed: UISearchBar!
    @IBOutlet weak var tblClosedList: UITableView!
    @IBOutlet weak var lblNoClosed: UILabel!
    
    @IBOutlet weak var viewNoOrder: UIView!
    @IBOutlet weak var imgNoOrder: UIImageView!
    @IBOutlet weak var lblNoOrder: UILabel!
    
    //*****//
    var selectedIndex: Int = 0
    
    var arrPending: [OrderObject] = []
    var arrSearchPending: [OrderObject] = []
    var searchActivePending: Bool = false
    
    var arrExecuted: [OrderObject] = []
    var arrSearchExecuted: [OrderObject] = []
    var searchActiveExecuted: Bool = false
    
    var arrClosed: [OrderObject] = []
    var arrSearchClosed: [OrderObject] = []
    var searchActiveClosed: Bool = false
    
    var arrHoldingList: [PortfolioObject] = []
    
    var isModifiedOrder:Bool = false
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateData), name: NSNotification.Name(rawValue: kUpdateOrder), object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToEditOrder(_:)), name: NSNotification.Name(rawValue: "moveToEditOrder"), object: nil)
        
        //ADDED NOTIFICATION OBSERVER TO NOTIFY ON KEYBOARD SHOW/HIDE
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        if self.isModifiedOrder == true {
            self.isModifiedOrder = false
            self.updateData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        self.searchBarPending.showsCancelButton = false
        self.searchBarExecuted.showsCancelButton = false
        self.searchBarClosed.showsCancelButton = false
        self.searchBarPending.delegate = self
        self.searchBarExecuted.delegate = self
        self.searchBarClosed.delegate = self
        
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.lblPendingCount.layer.cornerRadius = self.lblPendingCount.layer.frame.height / 2.0
            self.lblExecutedCount.layer.cornerRadius = self.lblExecutedCount.layer.frame.height / 2.0
            self.lblClosedCount.layer.cornerRadius = self.lblClosedCount.layer.frame.height / 2.0
            
            self.searchBarPending.setupSearchBar(background: .clear, inputText: UIColor.textFieldTextColor, placeholderText: UIColor.tblMarketDepthContent, image: UIColor.tblMarketDepthContent)
            self.searchBarPending.setImage(UIImage(), for: .search, state: .normal)
            self.searchBarPending.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
            
            self.searchBarExecuted.setupSearchBar(background: .clear, inputText: UIColor.textFieldTextColor, placeholderText: UIColor.tblMarketDepthContent, image: UIColor.tblMarketDepthContent)
            self.searchBarExecuted.setImage(UIImage(), for: .search, state: .normal)
            self.searchBarExecuted.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
            
            self.searchBarClosed.setupSearchBar(background: .clear, inputText: UIColor.textFieldTextColor, placeholderText: UIColor.tblMarketDepthContent, image: UIColor.tblMarketDepthContent)
            self.searchBarClosed.setImage(UIImage(), for: .search, state: .normal)
            self.searchBarClosed.setPositionAdjustment(UIOffset(horizontal: -10, vertical: 0), for: .search)
        }
                
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblPending.textColor = UIColor.labelTextColor
        self.lblExecuted.textColor = UIColor.labelTextColor
        self.lblClosed.textColor = UIColor.labelTextColor
        
        self.lblNoOrder.textColor = UIColor.tblMarketDepthContent
        
        self.lblNoPending.textColor = UIColor.labelTextColor
        self.lblNoExecuted.textColor = UIColor.labelTextColor
        self.lblNoClosed.textColor = UIColor.labelTextColor
        
        self.tblPendingList.showsVerticalScrollIndicator = false
        self.tblPendingList.tableFooterView = UIView()
        
        self.tblExecutedList.showsVerticalScrollIndicator = false
        self.tblExecutedList.tableFooterView = UIView()
        
        self.tblClosedList.showsVerticalScrollIndicator = false
        self.tblClosedList.tableFooterView = UIView()
        
        self.lblNoPending.isHidden = true
        self.lblNoExecuted.isHidden = true
        self.lblNoClosed.isHidden = true
        
        self.callGetPortfolioAPI()
        self.callGetOrderListAPI()
    }
    
    //MARK: - HELPER -
    
    @objc private func moveToEditOrder(_ notification: NSNotification) {
        
        
        if let objData = notification.userInfo as? [String: Any] {
            var objOrderDetail: OrderObject!
            var objStockDetail: AssetsObject!
            
            if let order = objData["order"] as? OrderObject {
                objOrderDetail = order
            }
            if let assets = objData["assets"] as? AssetsObject {
                objStockDetail = assets
            }
            
            var isFromBuy:Bool = false
            if objOrderDetail.side == "buy" {
                isFromBuy = true
            } else {
                isFromBuy = false
            }
            
            self.isModifiedOrder = true
            
//            if objOrderDetail.fractional == "false" {
                let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewMarketVc") as! NewMarketVc
                controller.isFromModify = true
                controller.isSelectedBuy = isFromBuy
                controller.objOrderDetail = objOrderDetail
                controller.objStockDetail = objStockDetail
                controller.arrHoldingList = self.arrHoldingList
                self.navigationController?.pushViewController(controller, animated: true)
//            }
//            else {
//                let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "BuySellFractionalShareVC") as! BuySellFractionalShareVC
//                controller.isFromPortfolio = false
//                controller.isFromBuy = isFromBuy
//                controller.objStockDetail = objStockDetail
//                controller.arrHoldingList = self.arrHoldingList
//                controller.isFromEdit = true
//                controller.objOrderDetail = objOrderDetail
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
        }
//        if let objData = notification.userInfo as? [String: Any] {
//            var objOrderDetail: OrderObject!
//            var objStockDetail: AssetsObject!
//
//            if let order = objData["order"] as? OrderObject {
//                objOrderDetail = order
//            }
//            if let assets = objData["assets"] as? AssetsObject {
//                objStockDetail = assets
//            }
//
//            var isFromBuy:Bool = false
//            if objOrderDetail.side == "buy" {
//                isFromBuy = true
//            } else {
//                isFromBuy = false
//            }
//
//            self.isModifiedOrder = true
//
//            if objOrderDetail.fractional == "false" {
//                let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "ModifyOrderVC") as! ModifyOrderVC
//                controller.isSelectedBuy = isFromBuy
//                controller.objOrderDetail = objOrderDetail
//                controller.objStockDetail = objStockDetail
//                controller.arrHoldingList = self.arrHoldingList
//                self.navigationController?.pushViewController(controller, animated: true)
//            } else {
//                let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "BuySellFractionalShareVC") as! BuySellFractionalShareVC
//                controller.isFromPortfolio = false
//                controller.isFromBuy = isFromBuy
//                controller.objStockDetail = objStockDetail
//                controller.arrHoldingList = self.arrHoldingList
//                controller.isFromEdit = true
//                controller.objOrderDetail = objOrderDetail
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
//        }
    }
    
    //TO AVOIDE DATA GOES BEHIND TABLEVIEW WE SET TABLEVIEW BOTTOM OFFSET TO KEYBOARD HEIGHT SO THAT TABLEVIEW LAST RECORD DISPLAY ABOVE KEYBOARD
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            if self.selectedIndex == 0 {//PENDING
                self.tblPendingList.setBottomInset(to: keyboardHeight)
            } else if self.selectedIndex == 1 {//EXECUTED
                self.tblExecutedList.setBottomInset(to: keyboardHeight)
            } else {//CLOSED
                self.tblClosedList.setBottomInset(to: keyboardHeight)
            }
        }
    }

    //RESET TABLEVIEW BOTTOM OFFSET TO 0 ON KEYBOARD HIDES
    @objc func keyboardWillHide(notification: Notification) {
        if self.selectedIndex == 0 {//PENDING
            self.tblPendingList.setBottomInset(to: 0.0)
        } else if self.selectedIndex == 1 {//EXECUTED
            self.tblExecutedList.setBottomInset(to: 0.0)
        } else {//CLOSED
            self.tblClosedList.setBottomInset(to: 0.0)
        }
    }
    
    @objc func updateData() {
        self.selectedIndex = 0
        self.arrPending.removeAll()
        self.arrExecuted.removeAll()
        self.arrClosed.removeAll()
        self.lblPendingCount.isHidden = false
        self.lblExecutedCount.isHidden = false
        self.lblClosedCount.isHidden = false
        
        self.arrSearchPending.removeAll()
        self.arrSearchExecuted.removeAll()
        self.arrSearchClosed.removeAll()

        self.searchActivePending = false
        self.searchActiveExecuted = false
        self.searchActiveClosed = false
        
        self.searchBarPending.text = ""
        self.searchBarExecuted.text = ""
        self.searchBarClosed.text = ""
        
        self.callGetOrderListAPI()
    }
    
    func setupSegmentView() {
        if self.selectedIndex == 0 {
            self.viewLinePending.isHidden = false
            self.viewLineExecuted.isHidden = true
            self.viewLineClosed.isHidden = true
            
            self.lblPending.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblPending.font.pointSize)
            self.lblExecuted.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblExecuted.font.pointSize)
            self.lblClosed.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblClosed.font.pointSize)
            
            self.setupNoOderData()

            if self.searchActivePending {
                self.viewNoOrder.isHidden = true
                self.viewPending.isHidden = false
                if self.arrSearchPending.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewPending.isHidden = false
                    self.lblNoPending.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewPending.isHidden = true
                    self.lblNoPending.isHidden = false
                }
            } else {
                self.searchBarPending.text = ""
                
                if self.arrPending.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewPending.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewPending.isHidden = true
                }
                self.lblNoPending.isHidden = true
            }
            
            self.viewExecuted.isHidden = true
            self.viewClosed.isHidden = true
            
            GlobalData.shared.reloadTableView(tableView: self.tblPendingList)
        } else if self.selectedIndex == 1 {
            self.viewLinePending.isHidden = true
            self.viewLineExecuted.isHidden = false
            self.viewLineClosed.isHidden = true
            
            self.lblPending.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblPending.font.pointSize)
            self.lblExecuted.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblExecuted.font.pointSize)
            self.lblClosed.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblClosed.font.pointSize)
            
            self.setupNoOderData()

            if self.searchActiveExecuted {
                self.viewNoOrder.isHidden = true
                self.viewExecuted.isHidden = false
                if self.arrSearchExecuted.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewExecuted.isHidden = false
                    self.lblNoExecuted.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewExecuted.isHidden = true
                    self.lblNoExecuted.isHidden = false
                }
            } else {
                self.searchBarExecuted.text = ""
                
                if self.arrExecuted.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewExecuted.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewExecuted.isHidden = true
                }
                self.lblNoExecuted.isHidden = true
            }
            
            self.viewPending.isHidden = true
            self.viewClosed.isHidden = true
            
            GlobalData.shared.reloadTableView(tableView: self.tblExecutedList)
        } else {
            self.viewLinePending.isHidden = true
            self.viewLineExecuted.isHidden = true
            self.viewLineClosed.isHidden = false
            
            self.lblPending.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblPending.font.pointSize)
            self.lblExecuted.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: self.lblExecuted.font.pointSize)
            self.lblClosed.font = UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: self.lblClosed.font.pointSize)
            
            self.setupNoOderData()

            if self.searchActiveClosed {
                self.viewNoOrder.isHidden = true
                self.viewClosed.isHidden = false
                if self.arrSearchClosed.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewClosed.isHidden = false
                    self.lblNoClosed.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewClosed.isHidden = true
                    self.lblNoClosed.isHidden = false
                }
            } else {
                self.searchBarClosed.text = ""
                
                if self.arrClosed.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewClosed.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewClosed.isHidden = true
                }
                self.lblNoClosed.isHidden = true
            }
            
            self.viewPending.isHidden = true
            self.viewExecuted.isHidden = true
            
            GlobalData.shared.reloadTableView(tableView: self.tblClosedList)
        }
    }
    
    func setupNoOderData() {
        if self.selectedIndex == 0 {//PENDING
            self.imgNoOrder.image = UIImage.init(named: "ic_no_pending")
            self.lblNoOrder.text = "You don't have any pending orders"
        } else if self.selectedIndex == 1 {//EXECUTED
            self.imgNoOrder.image = UIImage.init(named: "ic_no_executed")
            self.lblNoOrder.text = "You don't have any executed orders"
        } else {//CLOSED
            self.imgNoOrder.image = UIImage.init(named: "ic_no_closed")
            self.lblNoOrder.text = "You don't have any closed orders"
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSegmentClick(_ sender: UIButton) {
        if sender.tag == 1 {
            if self.selectedIndex != 0 {
                self.lblPendingCount.isHidden = true
                self.selectedIndex = 0
                self.setupSegmentView()
            }
        } else if sender.tag == 2 {
            if self.selectedIndex != 1 {
                self.lblExecutedCount.isHidden = true
                self.selectedIndex = 1
                self.setupSegmentView()
            }
        } else {
            if self.selectedIndex != 2 {
                self.lblClosedCount.isHidden = true
                self.selectedIndex = 2
                self.setupSegmentView()
            }
        }
    }
    
    //PENDING VIEW
    @IBAction func btnMicrophonePendingClick(_ sender: UIButton) {
        debugPrint("Microphone Pending Click")
    }
    
    @IBAction func btnMicrophoneExecutedClick(_ sender: UIButton) {
        debugPrint("Microphone Executed Click")
    }
    
    @IBAction func btnMicrophoneClosedClick(_ sender: UIButton) {
        debugPrint("Microphone Closed Click")
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension OrdersVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tblPendingList {
            if self.searchActivePending {
                return self.arrSearchPending.count
            } else {
                return self.arrPending.count
            }
        } else if tableView == self.tblExecutedList {
            if self.searchActiveExecuted {
                return self.arrSearchExecuted.count
            } else {
                return self.arrExecuted.count
            }
        } else {
            if self.searchActiveClosed {
                return self.arrSearchClosed.count
            } else {
                return self.arrClosed.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblPendingList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath) as! OrdersCell
            
            var objData: OrderObject!
            
            if self.searchActivePending {
                objData = self.arrSearchPending[indexPath.section]
            } else {
                objData = self.arrPending[indexPath.section]
            }
                        
            if objData.side == "buy" {
                cell.lblStatus.text = "BUY"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01)
            } else {
                cell.lblStatus.text = "SELL"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0xFE3D2F)
            }
            
            cell.lblName.text = objData.symbol
            cell.lblType.text = ""
            cell.lblMarket.text = objData.order_type
            
            if objData.order_type == "market" {
                if objData.notional == "" {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                } else {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Price:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.notional == "" ? "" : "$" + objData.notional, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                }
                cell.lblPrice.text = objData.filled_avg_price == "" ? "" : "$" + convertThousand(value: Double(objData.filled_avg_price) ?? 0.0)
            }
            else if objData.order_type == "limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
            }
            else if objData.order_type == "stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
            }
            else if objData.order_type == "stop_limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let limitPrice = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nLimit price: \(limitPrice)"
            }
            else if objData.order_type == "trailing_stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let trailPrice = objData.trail_price == "" ? "" : "$" + convertThousand(value: Double(objData.trail_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nTrail price: \(trailPrice)"
            }
            
            cell.selectionStyle = .none
            return cell
        } else if tableView == self.tblExecutedList {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath) as! OrdersCell
            
            var objData: OrderObject!
            
            if self.searchActiveExecuted {
                objData = self.arrSearchExecuted[indexPath.section]
            } else {
                objData = self.arrExecuted[indexPath.section]
            }
                        
            if objData.side == "buy" {
                cell.lblStatus.text = "BUY"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01)
            } else {
                cell.lblStatus.text = "SELL"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0xFE3D2F)
            }
            
            cell.lblName.text = objData.symbol
            cell.lblType.text = ""
            cell.lblMarket.text = objData.order_type
            
            if objData.order_type == "market" {
                if objData.notional == "" {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                } else {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Price:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.notional == "" ? "" : "$" + objData.notional, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                }
                cell.lblPrice.text = objData.filled_avg_price == "" ? "" : "$" + convertThousand(value: Double(objData.filled_avg_price) ?? 0.0)
            }
            else if objData.order_type == "limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
            }
            else if objData.order_type == "stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
            }
            else if objData.order_type == "stop_limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let limitPrice = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nLimit price: \(limitPrice)"
            }
            else if objData.order_type == "trailing_stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let trailPrice = objData.trail_price == "" ? "" : "$" + convertThousand(value: Double(objData.trail_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nTrail price: \(trailPrice)"
            }
            
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersCell", for: indexPath) as! OrdersCell
            
            var objData: OrderObject!
            
            if self.searchActiveClosed {
                objData = self.arrSearchClosed[indexPath.section]
            } else {
                objData = self.arrClosed[indexPath.section]
            }
                        
            if objData.side == "buy" {
                cell.lblStatus.text = "BUY"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0x81CF01)
            } else {
                cell.lblStatus.text = "SELL"
                cell.viewStatus.backgroundColor = UIColor.init(hex: 0xFE3D2F)
            }
            
            cell.lblName.text = objData.symbol
            cell.lblType.text = ""
            cell.lblMarket.text = objData.order_type
            
            if objData.order_type == "market" {
                if objData.notional == "" {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                } else {
                    cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Price:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.notional == "" ? "" : "$" + objData.notional, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                }
                cell.lblPrice.text = objData.filled_avg_price == "" ? "" : "$" + convertThousand(value: Double(objData.filled_avg_price) ?? 0.0)
            }
            else if objData.order_type == "limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
            }
            else if objData.order_type == "stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                cell.lblPrice.text = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
            }
            else if objData.order_type == "stop_limit" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let limitPrice = objData.limit_price == "" ? "" : "$" + convertThousand(value: Double(objData.limit_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nLimit price: \(limitPrice)"
            }
            else if objData.order_type == "trailing_stop" {
                cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.tblPortfolioContent, strSecond: objData.qty, strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.labelTextColor)
                let stopPrice = objData.stop_price == "" ? "" : "$" + convertThousand(value: Double(objData.stop_price) ?? 0.0)
                let trailPrice = objData.trail_price == "" ? "" : "$" + convertThousand(value: Double(objData.trail_price) ?? 0.0)
                cell.lblPrice.text = "Stop price: \(stopPrice)\nTrail price: \(trailPrice)"
            }
            
            let isDarkMode = defaults.string(forKey: kIsDarkModeEnable)
            if isDarkMode == "dark" {
                cell.viewContainer.alpha = 0.7
            }
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.tblPendingList {
            var objDict: OrderObject!
            
            if self.searchActivePending {
                objDict = self.arrSearchPending[indexPath.section]
            }
            else {
                if self.searchBarPending.text?.count ?? "".count <= 0 {
                    self.searchActivePending = false
                    objDict = self.arrPending[indexPath.section]
                }
                else {
                    self.searchActivePending = true
                    objDict = self.arrSearchPending[indexPath.section]
                }
            }
            
            self.searchBarPending.resignFirstResponder()
            self.searchBarPending.showsCancelButton = false
            
            let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "PopupModifyStockVC") as! PopupModifyStockVC
            controller.objOrderDetail = objDict
            controller.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(controller, animated: true, completion: nil)
        } else if tableView == self.tblExecutedList {
            debugPrint("Table Executed Click")
        } else {
            debugPrint("Table Closed Click")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - UISEARCHBAR DELEGATE METHOD -

extension OrdersVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if self.selectedIndex == 0 {//PENDING
            if(searchBar.text != "") {
                self.searchActivePending = true
            }
        } else if self.selectedIndex == 1 {//EXECUTED
            if(searchBar.text != "") {
                self.searchActiveExecuted = true
            }
        } else {//CLOSED
            if(searchBar.text != "") {
                self.searchActiveClosed = true
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if self.selectedIndex == 0 {//PENDING
            self.searchActivePending = false
            searchBar.text = nil
            searchBar.resignFirstResponder()
            self.tblPendingList.resignFirstResponder()
            self.searchBarPending.showsCancelButton = false
            self.tblPendingList.reloadData()
        }
        else if self.selectedIndex == 1 {//EXECUTED
            self.searchActiveExecuted = false
            searchBar.text = nil
            searchBar.resignFirstResponder()
            self.tblExecutedList.resignFirstResponder()
            self.searchBarExecuted.showsCancelButton = false
            self.tblExecutedList.reloadData()
        }
        else {//CLOSED
            self.searchActiveClosed = false
            searchBar.text = nil
            searchBar.resignFirstResponder()
            self.tblClosedList.resignFirstResponder()
            self.searchBarClosed.showsCancelButton = false
            self.tblClosedList.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if self.selectedIndex == 0 {//PENDING
            self.searchActivePending = false
            self.searchBarPending.resignFirstResponder()
            self.searchBarPending.showsCancelButton = false
        }
        else if self.selectedIndex == 1 {//EXECUTED
            self.searchActiveExecuted = false
            self.searchBarExecuted.resignFirstResponder()
            self.searchBarExecuted.showsCancelButton = false
        }
        else {//CLOSED
            self.searchActiveClosed = false
            self.searchBarClosed.resignFirstResponder()
            self.searchBarClosed.showsCancelButton = false
        }
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if self.selectedIndex == 0 {//PENDING
            self.searchActivePending = false
            
            if searchBar.text?.count ?? "".count <= 0 {
                if self.arrPending.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewPending.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewPending.isHidden = true
                }
                self.lblNoPending.isHidden = true
            }
            else {
                if self.arrSearchPending.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewPending.isHidden = false
                    self.lblNoPending.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewPending.isHidden = true
                    self.lblNoPending.isHidden = false
                }
            }
        }
        else if self.selectedIndex == 1 {//EXECUTED
            self.searchActiveExecuted = false
            
            if searchBar.text?.count ?? "".count <= 0 {
                if self.arrExecuted.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewExecuted.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewExecuted.isHidden = true
                }
                self.lblNoExecuted.isHidden = true
            }
            else {
                if self.arrSearchExecuted.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewExecuted.isHidden = false
                    self.lblNoExecuted.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewExecuted.isHidden = true
                    self.lblNoExecuted.isHidden = false
                }
            }
        }
        else {//CLOSED
            self.searchActiveClosed = false
            
            if searchBar.text?.count ?? "".count <= 0 {
                if self.arrClosed.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewClosed.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewClosed.isHidden = true
                }
                self.lblNoClosed.isHidden = true
            }
            else {
                if self.arrSearchClosed.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewClosed.isHidden = false
                    self.lblNoClosed.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewClosed.isHidden = true
                    self.lblNoClosed.isHidden = false
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.selectedIndex == 0 {//PENDING
            self.searchBarPending.showsCancelButton = true
            if(searchText != "") {
                self.searchActivePending = true
                if (self.arrPending.count) > 0 {
                    self.arrSearchPending = self.arrPending.filter() {
                    let symbolExchange = ("\(($0 as OrderObject).symbol.lowercased())")// \(($0 as OrderObject).exchange.lowercased())
                        return symbolExchange.contains(searchText.lowercased())
                    }
                }
            } else {
                self.searchActivePending = false
            }
            
            if self.searchActivePending {
                if self.arrSearchPending.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewPending.isHidden = false
                    self.lblNoPending.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewPending.isHidden = true
                    self.lblNoPending.isHidden = false
                }
            } else {
                if self.arrPending.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewPending.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewPending.isHidden = true
                }
                self.lblNoPending.isHidden = true
            }
            
            self.tblPendingList.reloadData()
        }
        else if self.selectedIndex == 1 {//EXECUTED
            self.searchBarExecuted.showsCancelButton = true
            if(searchText != "") {
                self.searchActiveExecuted = true
                if (self.arrExecuted.count) > 0 {
                    self.arrSearchExecuted = self.arrExecuted.filter() {
                    let symbolExchange = ("\(($0 as OrderObject).symbol.lowercased())")// \(($0 as OrderObject).exchange.lowercased())
                        return symbolExchange.contains(searchText.lowercased())
                    }
                }
            } else {
                self.searchActiveExecuted = false
            }
            
            if self.searchActiveExecuted {
                if self.arrSearchExecuted.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewExecuted.isHidden = false
                    self.lblNoExecuted.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewExecuted.isHidden = true
                    self.lblNoExecuted.isHidden = false
                }
            } else {
                if self.arrExecuted.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewExecuted.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewExecuted.isHidden = true
                }
                self.lblNoExecuted.isHidden = true
            }
            
            self.tblExecutedList.reloadData()
        }
        else {//CLOSED
            self.searchBarClosed.showsCancelButton = true
            if(searchText != "") {
                self.searchActiveClosed = true
                if (self.arrClosed.count) > 0 {
                    self.arrSearchClosed = self.arrClosed.filter() {
                    let symbolExchange = ("\(($0 as OrderObject).symbol.lowercased())")// \(($0 as OrderObject).exchange.lowercased())
                        return symbolExchange.contains(searchText.lowercased())
                    }
                }
            } else {
                self.searchActiveClosed = false
            }
            
            if self.searchActiveClosed {
                if self.arrSearchClosed.count > 0 {
//                    self.viewNoOrder.isHidden = true
//                    self.viewClosed.isHidden = false
                    self.lblNoClosed.isHidden = true
                } else {
//                    self.viewNoOrder.isHidden = false
//                    self.viewClosed.isHidden = true
                    self.lblNoClosed.isHidden = false
                }
            } else {
                if self.arrClosed.count > 0 {
                    self.viewNoOrder.isHidden = true
                    self.viewClosed.isHidden = false
                } else {
                    self.viewNoOrder.isHidden = false
                    self.viewClosed.isHidden = true
                }
                self.lblNoClosed.isHidden = true
            }
            
            self.tblClosedList.reloadData()
        }
    }
}

//MARK: - UITEXTFIELD DELEGATE METHOD -

extension OrdersVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: - API CALL -

extension OrdersVC {
    //HOLDINGS DATA
    func callGetPortfolioAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_PORTFOLIO) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrHoldingList.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = PortfolioObject.init(payloadData[i])
                                strongSelf.arrHoldingList.append(objData)
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //ORDER LIST API
    func callGetOrderListAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_ORDER) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            if let pending = payloadData["pending"] as? [Dictionary<String, Any>] {
                                strongSelf.arrPending.removeAll()
                                for i in 0..<pending.count {
                                    let objData = OrderObject.init(pending[i])
                                    strongSelf.arrPending.append(objData)
                                }
                                
                                strongSelf.lblPendingCount.text = " " + "\(strongSelf.arrPending.count)" + "  "
                            }
                            if let executed = payloadData["executed"] as? [Dictionary<String, Any>] {
                                strongSelf.arrExecuted.removeAll()
                                for i in 0..<executed.count {
                                    let objData = OrderObject.init(executed[i])
                                    strongSelf.arrExecuted.append(objData)
                                }
                                
                                strongSelf.lblExecutedCount.text = " " + "\(strongSelf.arrExecuted.count)" + "  "
                            }
                            if let cancelled = payloadData["cancelled"] as? [Dictionary<String, Any>] {
                                strongSelf.arrClosed.removeAll()
                                for i in 0..<cancelled.count {
                                    let objData = OrderObject.init(cancelled[i])
                                    strongSelf.arrClosed.append(objData)
                                }
                                
                                strongSelf.lblClosedCount.text = " " + "\(strongSelf.arrClosed.count)" + "  "
                            }
                            strongSelf.setupSegmentView()
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                        strongSelf.setupSegmentView()
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
