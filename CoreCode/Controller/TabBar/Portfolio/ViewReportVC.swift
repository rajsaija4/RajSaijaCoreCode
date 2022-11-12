//
//  ViewReportVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 13/12/21.
//

import UIKit
import SwiftyJSON

class ViewReportVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblNavTitle: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var lblSegmentTitle: UILabel!
    @IBOutlet weak var viewSegment: UIView!
    @IBOutlet weak var txtSegment: UITextField!
    
    @IBOutlet weak var lblDateTitle: UILabel!
    @IBOutlet weak var txtDate: NoPopUpTextField!
    
    @IBOutlet weak var btnView: UIButton!
    
    @IBOutlet weak var lblLastUpdated: UILabel!
    
    @IBOutlet weak var tblReport: ContentSizedTableView!
    @IBOutlet weak var tblReportHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    var arrReport: [ReportObject] = []
    
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
            self.tblReportHeightConstraint.constant = self.tblReport.contentSize.height
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.btnView.createButtonShadow(BorderColor: UIColor.init(hex: 0x81CF01, a: 0.35), ShadowColor: UIColor.init(hex: 0x81CF01, a: 0.35))
        }
        
        self.lblNavTitle.textColor = UIColor.labelTextColor
        self.lblTitle.textColor = UIColor.labelTextColor
        
        self.lblSegmentTitle.textColor = UIColor.labelTextColor
        self.txtSegment.textColor = UIColor.textFieldTextColor
        
        self.lblDateTitle.textColor = UIColor.labelTextColor
        self.txtDate.textColor = UIColor.textFieldTextColor
        
        self.txtDate.tintColor = .clear
        self.txtDate.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(doneButtonClicked))
        
        self.txtSegment.isUserInteractionEnabled = false
        
        self.lblLastUpdated.textColor = UIColor.tblMarketDepthContent
        
        self.lblNoRecord.textColor = UIColor.labelTextColor
                
        self.tblReport.showsVerticalScrollIndicator = false
        self.tblReport.tableFooterView = UIView()
        
        self.tblReport.isHidden = true
        self.lblNoRecord.isHidden = true
                        
        //SET DATA
        let today = Date()
        let strToday = (today.string(format: "yyyy-MM-dd"))
        self.txtSegment.text = "Equity"
        self.txtDate.text = strToday
        self.lblLastUpdated.text = "Last updated: \(strToday)"
        
        self.callGetReportByDateAPI()
    }
    
    //MARK: - HELPER -
    
    @objc func doneButtonClicked(_ sender: UITextField) {
        if sender == self.txtDate {
            if let picker = sender.inputView as? UIDatePicker {
                self.txtDate.text = picker.date.getDateOnly()
            }
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDateClick(_ sender: UIButton) {
        if sender.accessibilityIdentifier == "DATE" {
            self.txtDate.becomeFirstResponder()
        }
    }
    
    @IBAction func btnViewClick(_ sender: UIButton) {
        debugPrint("View Click")
        self.callGetReportByDateAPI()
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension ViewReportVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrReport.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        
        let objDict = self.arrReport[indexPath.section]
        let qty = (objDict.qty as NSString).doubleValue
        let price = (objDict.price as NSString).doubleValue
        
        cell.lblQty.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "Qty:" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: cell.lblQty.font.pointSize)!, strFirstColor: UIColor.labelTextColor, strSecond: String(format: "%.4f", qty), strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: cell.lblQty.font.pointSize)!, strSecondColor: UIColor.tblMarketDepthContent)
        cell.lblName.text = objDict.symbol
        cell.lblVariationAmount.text = "$" + String(format: "%.4f", price)
        
        if price > 0 || price > 0.0 {
            cell.lblVariationAmount.textColor = UIColor.init(hex: 0x65AA3D)
        } else {
            cell.lblVariationAmount.textColor = UIColor.init(hex: 0xFE3D2F)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 114.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - UITEXTFIELD DELEGATE METHOD -

extension ViewReportVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.txtDate {
            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.timeZone = TimeZone.current
            datePicker.date = Date.getSelectedDateFromString(self.txtDate.text ?? Date.getDateOnly())
            datePicker.addTarget(self, action: #selector(updateDateField(sender:)), for: .valueChanged)
            
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
            self.txtDate.inputView = datePicker
        }
        return true
    }
    
    @objc func updateDateField(sender: UIDatePicker) {
        self.txtDate.text = sender.date.getDateOnly()
    }
}

//MARK: - API CALL -

extension ViewReportVC {
    //VIEW REPORT BY DATE
    func callGetReportByDateAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_STATEMENT_HISTORY + "/" + "\(self.txtDate.text ?? "")"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrReport.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = ReportObject.init(payloadData[i])
                                strongSelf.arrReport.append(objData)
                            }
                            
                            if strongSelf.arrReport.count > 0 {
                                strongSelf.tblReport.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblReport.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }

                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblReport)
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))

                        strongSelf.arrReport.removeAll()
                        if strongSelf.arrReport.count > 0 {
                            strongSelf.tblReport.isHidden = false
                            strongSelf.lblNoRecord.isHidden = true
                        } else {
                            strongSelf.tblReport.isHidden = true
                            strongSelf.lblNoRecord.isHidden = false
                        }
                        GlobalData.shared.reloadTableView(tableView: strongSelf.tblReport)
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
