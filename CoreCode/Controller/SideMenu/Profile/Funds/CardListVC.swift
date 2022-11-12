//
//  CardListVC.swift


import UIKit
import SwiftyJSON

class CardListVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    @IBOutlet weak var btnDone: UIButton!
    
    var isFromAdd:Bool = false
    var strAmount:String = ""
    
    var arrCard: [CardObject] = []
    var selectedIndex:Int = -1
    
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
            
            self.btnDone.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblList.showsVerticalScrollIndicator = false
        self.tblList.tableFooterView = UIView()
        
        self.tblList.isHidden = true
        self.lblNoRecord.isHidden = true
        
        self.callGetCardListAPI()
        
        //ADDED NOTIFICATION OBSERVER TO NOTIFY US WHEN ADD NEW CARD
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNewlyCreatedCardInList(_:)), name: NSNotification.Name(rawValue: kAddCardDetail), object: nil)
        
        //ADDED NOTIFICATION OBSERVER TO NOTIFY US WHEN UPDATE CARD
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateExistingCardInList(_:)), name: NSNotification.Name(rawValue: kUpdateCardDetail), object: nil)
        
        //ADDED NOTIFICATION OBSERVER TO MOVE TRANSACTION HISTORY
        NotificationCenter.default.addObserver(self, selector: #selector(self.moveToFundTransaction), name: NSNotification.Name(rawValue: "moveToFundTransaction"), object: nil)
    }
    
    //MARK: - HELPER -
    
    @objc private func addNewlyCreatedCardInList(_ notification: NSNotification) {
        if let objCard = notification.userInfo?["card"] as? CardObject {
            self.arrCard.insert(objCard, at: 0)
            if self.arrCard.count > 0 {
                self.tblList.isHidden = false
                self.lblNoRecord.isHidden = true
            } else {
                self.tblList.isHidden = true
                self.lblNoRecord.isHidden = false
            }
                        
            GlobalData.shared.reloadTableView(tableView: self.tblList)
        }
    }
    
    @objc private func updateExistingCardInList(_ notification: NSNotification) {
        if let objUpdatedCard = notification.userInfo?["card"] as? CardObject {
            if let row = self.arrCard.firstIndex(where: {$0._id == objUpdatedCard._id}) {
                self.arrCard[row] = objUpdatedCard
                self.tblList.reloadData()
            }
        }
    }
    
    @objc func moveToFundTransaction() {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "FundsTransactionVC") as! FundsTransactionVC
        controller.isSelectedAdd = true
        controller.isNeedToPopOnly = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func setCardNumber(CardNo cardNo: String) -> String {
        var myString = cardNo
        let stringlength = myString.count
        let e = try? NSRegularExpression(pattern: "\\d", options: [])
        var finalString = ""
        
        if stringlength == 14 {
            myString = (e?.stringByReplacingMatches(in: myString, options: [], range: NSRange(location: 0, length: stringlength-4), withTemplate: "X"))!

            finalString = myString.codeFormat()
        }
        else if stringlength == 15 {
            myString = (e?.stringByReplacingMatches(in: myString, options: [], range: NSRange(location: 0, length: stringlength-5), withTemplate: "X"))!
            
            finalString = myString.codeFormat()
        }
        else { //if stringlength == 16
            myString = (e?.stringByReplacingMatches(in: myString, options: [], range: NSRange(location: 0, length: stringlength-4), withTemplate: "X"))!
            myString = myString.separate(every: 4, with: " ") // Seprate with space every 4 character
            
            finalString = myString
        }
        
        return finalString
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "AddEditCardPopupVC") as! AddEditCardPopupVC
        controller.strPage = "Add"
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnDoneClick(_ sender: UIButton) {
        if self.selectedIndex == -1 {
            GlobalData.shared.showSystemToastMesage(message: "Please select any card")
        } else {
            let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "AddEditCardPopupVC") as! AddEditCardPopupVC
            controller.strPage = "Add Fund"
            controller.objCardDetail = self.arrCard[self.selectedIndex]
            controller.strAmount = self.strAmount
            controller.modalPresentationStyle = .overFullScreen
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension CardListVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrCard.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell", for: indexPath) as! CardCell
        
        let objData = self.arrCard[indexPath.section]
        let cardNo = objData.cardNumber.replacingOccurrences(of: " ", with: "")
        
        if (indexPath.section % 2) == 0 {
            cell.imgCardBG.image = UIImage.init(named: "card_green")
        } else {
            cell.imgCardBG.image = UIImage.init(named: "card_blue")
        }
        
        cell.lblName.text = objData.cardHolderName
        cell.lblCardNo.text = self.setCardNumber(CardNo: cardNo)
        cell.lblCardType.text = objData.cardType
        cell.lblExpiryDate.text = objData.cardExpiry
        
        if indexPath.section == self.selectedIndex {
            cell.btnTick.isSelected = true
        } else {
            cell.btnTick.isSelected = false
        }
        
        cell.btnTick.tag = indexPath.section
        cell.btnTick.addTarget(self, action: #selector(btnTickClick), for: .touchUpInside)
        
        cell.btnEdit.tag = indexPath.section
        cell.btnEdit.addTarget(self, action: #selector(btnEditClick), for: .touchUpInside)
        
        cell.btnDelete.tag = indexPath.section
        cell.btnDelete.addTarget(self, action: #selector(btnDeleteClick), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //CELL ACTION
    @objc func btnTickClick(_ sender: UIButton) {
        if sender.tag != self.selectedIndex {
            self.selectedIndex = sender.tag
            self.tblList.reloadData()
        }
    }
    
    @objc func btnEditClick(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "AddEditCardPopupVC") as! AddEditCardPopupVC
        controller.strPage = "Edit"
        controller.objCardDetail = self.arrCard[sender.tag]
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @objc func btnDeleteClick(_ sender: UIButton) {
        debugPrint("Delete \(sender.tag)")
        GlobalData.shared.displayConfirmationAlert(self, title: "Delete Card", message: "Are you sure you want to delete this card detail?", btnTitle1: "Cancel", btnTitle2: "Delete", actionBlock: { (isConfirmed) in
            if isConfirmed {
                let cardID = self.arrCard[sender.tag]._id
                self.callDeleteCardAPI(CardID: cardID)
            }
        })
    }
}

//MARK: - API CALL -

extension CardListVC {
    //CARD LIST API
    func callGetCardListAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_CARD) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrCard.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = CardObject.init(payloadData[i])
                                strongSelf.arrCard.append(objData)
                            }
                            
                            if strongSelf.arrCard.count > 0 {
                                strongSelf.tblList.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblList.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.arrCard.removeAll()
                        if strongSelf.arrCard.count > 0 {
                            strongSelf.tblList.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblList.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //DELETE CARD API
    func callDeleteCardAPI(CardID cardID: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_CARD + "/" + "\(cardID)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestDELETEURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let row = strongSelf.arrCard.firstIndex(where: {$0._id == cardID}) {
                            strongSelf.arrCard.remove(at: row)
                        }
                        
                        if strongSelf.arrCard.count > 0 {
                            strongSelf.tblList.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblList.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblList)
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
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
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
