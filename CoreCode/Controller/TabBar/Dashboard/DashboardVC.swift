//
//  DashboardVC.swift

import UIKit
import SideMenuSwift
import Charts
import SwiftyJSON
import SDWebImage

class DashboardVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var imgUp: UIImageView!
    @IBOutlet weak var viewInfo: UIView!
    @IBOutlet weak var imgTop: UIImageView!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var objScroll: UIScrollView!
    @IBOutlet weak var lblBalanceTitle: UILabel!
    @IBOutlet weak var lblOrderTitle: UILabel!
    
    @IBOutlet weak var lblBalanceAmount: UILabel!
    @IBOutlet weak var lblDayAmount: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    @IBOutlet weak var viewChart: UIView!
    @IBOutlet weak var lblNoChartDataAvailable: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var chartViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var stackViewChartBtn: UIStackView!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnYear: UIButton!
    @IBOutlet weak var btnYTD: UIButton!
    
    @IBOutlet weak var lblHoldingTitle: UILabel!
    @IBOutlet weak var lblPLTitle: UILabel!
    @IBOutlet weak var tblHolding: ContentSizedTableView!
    @IBOutlet weak var tblHoldingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblNoRecord: UILabel!
    
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet weak var lblPortfolioTitle: UILabel!
    @IBOutlet weak var lblPortfolioValue: UILabel!
    @IBOutlet weak var lblPortfolioValueTitle: UILabel!
    
    @IBOutlet weak var lblWithdrawableCashTitle: UILabel!
    @IBOutlet weak var lblWithdrawableCash: UILabel!
    @IBOutlet weak var lblBuyingPowerTitle: UILabel!
    @IBOutlet weak var lblBuyingPower: UILabel!
    @IBOutlet weak var lblBuyingPowerTop: UILabel!
    @IBOutlet weak var lblCashTitle: UILabel!
    @IBOutlet weak var lblCash: UILabel!
    
    var arrHoldingList: [PortfolioObject] = []
    var arrHoldingSymbol: [String] = []
    let portfolioChart = ["Holding", "Cash"]
    var arrPortfolio: [PortfolioObject] = []
    var investedAmount: Double = 0.0
    var currentAmount: Double = 0.0
    
    let timeStampFormat = DateFormatter()
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        SocketIOManager.shared.setupSocket()
        SocketIOManager.shared.setupDashboardSocketEvents()
        SocketIOManager.shared.socket?.connect()
        
        if self.arrHoldingList.count > 0 {
            self.arrHoldingSymbol = self.arrHoldingList.map { $0.symbol }
            let strSymbol = self.arrHoldingSymbol.joined(separator: ",")
            
            var objBars = Dictionary<String,AnyObject>()
            objBars["symbol"] = strSymbol as AnyObject
            objBars["type"] = EMIT_TYPE_BARS as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var objTrades = Dictionary<String,AnyObject>()
                objTrades["symbol"] = strSymbol as AnyObject
                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
            }
        }
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateDashboardBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateDashboardTrades), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.tblHoldingHeightConstraint.constant = self.tblHolding.contentSize.height
        }
    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.getDashboardBarData(notification:)), name: NSNotification.Name(kUpdateDashboardBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.getDashboardTradesData(notification:)), name: NSNotification.Name(kUpdateDashboardTrades), object: nil)
    }
    
    func setPortfolioData() {
        let variationValue = self.currentAmount - self.investedAmount
        let variationPer = (variationValue * 100) / self.investedAmount
        
//        self.lblInvestedValue.text = "$" + "\(Double(self.investedAmount.clean)?.calculator ?? "0.0")"
//        self.lblCurrentValue.text = "$" + "\(Double(self.currentAmount.clean)?.calculator ?? "0.0")"
        
        if variationValue > 0 {
            imgUp.image = UIImage(named: "ic_desk_up")
            self.lblTotalAmount.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: "+ $\(Double(String(format: "%.2f", variationValue))?.calculator ?? "0.0")" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize)!, strFirstColor: UIColor.init(hex: 0xFFFFFF), strSecond: "+(\(String(format: "%.2f", variationPer))%)Total", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize - 3)!, strSecondColor: UIColor.init(hex: 0xFFFFFF))
        } else if variationValue < 0 {
            imgUp.image = UIImage(named: "ic_down_home")
            self.lblTotalAmount.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: " $\(Double(String(format: "%.2f", variationValue))?.calculator ?? "0.0")" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize)!, strFirstColor: UIColor.init(hex: 0xFFFFFF), strSecond: "(\(String(format: "%.2f", variationPer))%)Total", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize - 3)!, strSecondColor: UIColor.init(hex: 0xFFFFFF))
        } else {
            imgUp.image = nil
            self.lblTotalAmount.attributedText = GlobalData.shared.convertStringtoAttributedText(strFirst: " $\(Double(String(format: "%.2f", variationValue))?.calculator ?? "0.0")" + " ", strFirstFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize)!, strFirstColor: UIColor.init(hex: 0xFFFFFF), strSecond: "(\(String(format: "%.2f", variationPer))%)Total", strSecondFont: UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: self.lblTotalAmount.font.pointSize - 3)!, strSecondColor: UIColor.init(hex: 0xFFFFFF))
        }
    }
    
    @objc func getDashboardBarData(notification: Notification) {
        debugPrint("=====Getting Dashboard Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        if let symbol = barObject["symbol"] as? String {
            if let row = self.arrHoldingList.firstIndex(where: {$0.symbol == symbol}) {
                self.arrHoldingList[row].openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
                self.arrHoldingList[row].closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                self.arrHoldingList[row].highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                self.arrHoldingList[row].lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                self.arrHoldingList[row].volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                self.arrHoldingList[row].tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
            }
        }
    }
    
    @objc func getDashboardTradesData(notification: Notification) {
        debugPrint("=====Getting Dashboard Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
//        DispatchQueue.global(qos: .background).async {
//            if let symbol = tradesObject["symbol"] as? String {
//                if let row = self.arrHoldingList.firstIndex(where: {$0.symbol == symbol}) {
//                    let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
//                    let openPrice = self.arrHoldingList[row].openPrice
//                    let closePrice = self.arrHoldingList[row].closePrice
//                    let variationValue = currentPrice - closePrice //currentPrice - openPrice
//                    let variationPer = (variationValue * 100) / closePrice
//
//                    self.arrHoldingList[row].lastday_price = "\(currentPrice)"
//                    self.arrHoldingList[row].plVariationValue = variationValue
//                    self.arrHoldingList[row].plVariationPer = variationPer
//
//    //                DispatchQueue.global(qos: .background).async {
//    //                    DispatchQueue.main.async {
//    //                        self.tblHolding.reloadSections(IndexSet(integer: row), with: .none)
//    //                    }
//    //                }
//    //                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//    //                    DispatchQueue.main.async {
//    //                        self.tblHolding.reloadSections(IndexSet(integer: row), with: .none)
//    //                    }
//    //                }
//                    DispatchQueue.main.async {
////                        self.tblHolding.reloadSections(IndexSet(integer: row), with: .none)
//                        self.tblHolding.reloadData()
//                    }
//                }
//            }
//        }
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if let row = self.arrHoldingList.firstIndex(where: {$0.symbol == symbol}) {
                    let currentPrice = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    let openPrice = self.arrHoldingList[row].openPrice
                    let closePrice = self.arrHoldingList[row].closePrice
                    let variationValue = currentPrice - closePrice //currentPrice - openPrice
                    let variationPer = (variationValue * 100) / closePrice

                    self.arrHoldingList[row].lastday_price = "\(currentPrice)"
                    self.arrHoldingList[row].plVariationValue = variationValue
                    self.arrHoldingList[row].plVariationPer = variationPer

                    DispatchQueue.main.async {
//                        self.tblHolding.reloadSections(IndexSet(integer: row), with: .none)
                        self.tblHolding.reloadData()
                    }
                }
            }
        }
    }
    
    //MARK: - SETUP VIEW -
    
    @IBAction func onClickInfo(_ sender: UIButton) {
        GlobalData.shared.displayAlertMessage(Title: "", Message: "All the stock market investments made by you")
    }
    
    @IBAction func onClickInfoClose(_ sender: UIButton) {
        viewInfo.isHidden = true

    }
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.imgTop.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.objScroll.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
//        self.lblBalanceTitle.textColor = UIColor.labelTextColor
//        self.lblOrderTitle.textColor = UIColor.DontHaveAnAccount
        
        self.lblBalanceAmount.textColor = UIColor.white
        
//        self.lblNoChartDataAvailable.textColor = UIColor.labelTextColor
        
        self.lblHoldingTitle.textColor = UIColor.labelTextColor
        self.lblPLTitle.textColor = UIColor.labelTextColor
        
        self.lblPortfolioTitle.textColor = UIColor.labelTextColor
        self.lblPortfolioValue.textColor = UIColor.labelTextColor
        self.lblPortfolioValueTitle.textColor = UIColor.labelTextColor
        
        self.lblWithdrawableCashTitle.textColor = UIColor.labelTextColor
        self.lblWithdrawableCash.textColor = UIColor.labelTextColor
        self.lblBuyingPowerTitle.textColor = UIColor.labelTextColor
        self.lblBuyingPower.textColor = UIColor.labelTextColor
        self.lblBuyingPowerTop.textColor = UIColor.white
        self.lblCashTitle.textColor = UIColor.labelTextColor
        self.lblCash.textColor = UIColor.labelTextColor
        
        self.lblNoRecord.textColor = UIColor.labelTextColor
        
        self.tblHolding.showsVerticalScrollIndicator = false
        self.tblHolding.tableFooterView = UIView()
        
        self.tblHolding.isHidden = true
        self.lblNoRecord.isHidden = true
        
//        self.chartView.isHidden = true
//        self.lblNoChartDataAvailable.isHidden = true
        
        self.timeStampFormat.dateFormat = "dd/MM/yyyy h:mm a"
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupDashboardSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
        //SET DATA
//        self.lblDayAmount.text = "+$4,396 (+10.25%) Day"
//        self.lblTotalAmount.text = "-$398 (-24.66%) Total"
        
//        self.setupChartButton(Duration: "day")
                
        self.callTradingAccountAPI()
        self.callGetPortfolioAPI()

        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTradingAccountData), name: NSNotification.Name(rawValue: kUpdateTradingAccount), object: nil)
    }
    
    //MARK: - HELPER -
    @objc func updateTradingAccountData() {
        self.callTradingAccountAPI()
        self.callGetPortfolioAPI()
    }
    
    func setupChartButton(Duration duration: String) {
        if duration == "day" {
            self.btnDay.setTitleColor(UIColor.white, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYTD.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
            self.btnYTD.backgroundColor = UIColor.clear
        } else if duration == "week" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.white, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYTD.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
            self.btnYTD.backgroundColor = UIColor.clear
        } else if duration == "month" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.white, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYTD.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnYear.backgroundColor = UIColor.clear
            self.btnYTD.backgroundColor = UIColor.clear
        } else if duration == "year" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.white, for: [])
            self.btnYTD.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnYTD.backgroundColor = UIColor.clear
        } else {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYTD.setTitleColor(UIColor.white, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
            self.btnYTD.backgroundColor = UIColor.init(hex: 0x27B1FC)
        }
        
        if duration == "ytd" {
            self.chartView.isHidden = true
            self.lblNoChartDataAvailable.isHidden = false
        } else {
            self.callDashboardGraphAPI(Duration: duration)
        }
    }
    
    //Set Line Chart Data
    func setLineChartData(_ dataPoints: [String], values: [Double]) {
//        self.chartViewWidth.constant = CGFloat((((count)+1) * 60) + 60)
        self.chartView.chartDescription?.text = ""
        self.chartView.noDataText = "No chart data available"
        self.chartView.drawGridBackgroundEnabled = false
        self.chartView.setScaleEnabled(true)
        self.chartView.pinchZoomEnabled = false
        self.chartView.rightAxis.enabled = false
        self.chartView.scaleXEnabled = false
        self.chartView.scaleYEnabled = false
//        self.chartView.xAxis.labelRotationAngle = -45
        self.chartView.xAxis.drawGridLinesEnabled = false
        self.chartView.leftAxis.drawGridLinesEnabled = false
//        self.chartView.xAxis.labelCount = dataPoints.count-1
        
        self.chartView.xAxis.drawLabelsEnabled = false
        self.chartView.xAxis.drawAxisLineEnabled = false
        self.chartView.leftAxis.drawAxisLineEnabled = false
        self.chartView.leftAxis.drawLabelsEnabled = false
        
        self.chartView.xAxis.valueFormatter = DateValueFormatter() as? IAxisValueFormatter
        self.chartView.dragYEnabled = false
        
        self.chartView.legend.enabled = false
        self.chartView.legend.form = .default
        
        let marker = BalloonMarker(color: .clear,//UIColor(white: 180/255, alpha: 1)
                                   font: .systemFont(ofSize: 12),
                                   textColor: UIColor.labelTextColor,
                                   insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
        marker.chartView = self.chartView
        marker.minimumSize = CGSize(width: 80, height: 40)
        self.chartView.marker = marker
        
        //******//
        var lineChartEntry  = [ChartDataEntry]()
        for i in 0..<dataPoints.count {
            let value = ChartDataEntry(x: Double(i), y: values[i])
            lineChartEntry.append(value)
        }
        //******//
        let set1 = LineChartDataSet(entries: lineChartEntry, label: "")
        set1.drawCirclesEnabled = false
        set1.drawIconsEnabled = false
        set1.drawValuesEnabled = false //true
        set1.valueFormatter = (XValueFormatter())
        set1.mode = .linear //.cubicBezier
//        set1.setColor(ChartColorTemplates.colorFromString("#30006DFF"))
//        set1.setCircleColor(ChartColorTemplates.colorFromString("#006DFF"))
        set1.setColor(UIColor.labelTextColor)
        set1.setCircleColor(UIColor.labelTextColor)
        set1.lineWidth = 2
        set1.circleRadius = 2
        set1.drawCircleHoleEnabled = false
        set1.circleHoleColor = .clear
        set1.formLineWidth = 1
        set1.formSize = 0
        set1.valueTextColor = UIColor.labelTextColor
        set1.valueFont = UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 10.0)!
        
        let data = LineChartData()
        data.addDataSet(set1)
        self.chartView.data = data
        
        self.chartView.extraLeftOffset = 10
        //******//
//        let set1 = LineChartDataSet(entries: values, label: "Live")
//        set1.axisDependency = .left
//        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
//        set1.lineWidth = 1.5
//        set1.drawCirclesEnabled = false
//        set1.drawValuesEnabled = false
//        set1.fillAlpha = 0.26
//        set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
//        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
//        set1.drawCircleHoleEnabled = false
        
//        let data = LineChartData(dataSet: set1)
//        data.setValueTextColor(.white)
//        data.setValueFont(.systemFont(ofSize: 9, weight: .light))
//
//        chartView.data = data
        //******//
        if dataPoints.count <= 1 {
            self.chartView.isUserInteractionEnabled = false
            self.chartView.leftAxis.labelTextColor = UIColor.clear
            self.chartView.xAxis.labelTextColor = UIColor.clear
            self.chartView.extraRightOffset = 0
        }
        else {
            self.chartView.isUserInteractionEnabled = true
            self.chartView.leftAxis.labelTextColor = UIColor.black
            self.chartView.xAxis.labelTextColor = UIColor.black
            self.chartView.extraRightOffset = 30.0
        }
        self.chartView.leftAxis.labelFont = UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 10.0)!
        self.chartView.rightAxis.enabled = false
        self.chartView.xAxis.labelPosition = .bottom
        self.chartView.xAxis.labelFont = UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 10.0)!
        
        self.chartView.animate(xAxisDuration: 1, yAxisDuration: 1)
    }
    
    //Set Pie Chart Data
    func setPieChartDataCount(_ count: Int, range: UInt32) {
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.drawSlicesUnderHoleEnabled = false
        self.pieChartView.holeRadiusPercent = 0.60
        self.pieChartView.transparentCircleRadiusPercent = 0.2
        self.pieChartView.chartDescription?.enabled = false
        self.pieChartView.setExtraOffsets(left: 5, top: 5, right: 5, bottom: 5)
        
        self.pieChartView.drawCenterTextEnabled = true
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let holdingValue = (GlobalData.shared.objTradingAccount.long_market_value as NSString).doubleValue
        let cashValue = (GlobalData.shared.objTradingAccount.cash as NSString).doubleValue
        let euityValue = (GlobalData.shared.objTradingAccount.equity as NSString).doubleValue
        let amount = "$" + convertThousand(value: euityValue)
        
        let centerText = NSMutableAttributedString(string: "Stocks & Cash\n\(amount)")
        centerText.setAttributes([NSAttributedString.Key.font: UIFont.init(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: 10.0)!, NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, centerText.length))
                
        centerText.addAttributes([.font : UIFont(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: 11.0)!,
                                  .foregroundColor : UIColor.labelTextColor], range: NSRange(location: 14, length: 0))
        self.pieChartView.centerAttributedText = centerText;
        
        self.pieChartView.drawHoleEnabled = true
        self.pieChartView.rotationAngle = 0
        self.pieChartView.rotationEnabled = true
        self.pieChartView.highlightPerTapEnabled = true
//        self.pieChartView.legend.enabled = false
        
//        self.pieChartView.holeColor = UIColor.clear
        
        let l = self.pieChartView.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.xEntrySpace = 7
        l.yEntrySpace = 0
        l.yOffset = 0
//        self.pieChartView.legend = l
        
        //******//
        var pieChartEntry  = [PieChartDataEntry]()
        for i in 0..<self.portfolioChart.count {
            if i == 0 {
                let value = PieChartDataEntry(value: holdingValue, label: self.portfolioChart[i], icon: nil)
                pieChartEntry.append(value)
            } else {
                let value = PieChartDataEntry(value: cashValue, label: self.portfolioChart[i], icon: nil)
                pieChartEntry.append(value)
            }
        }
        //******//
        let set = PieChartDataSet(entries: pieChartEntry, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        set.selectionShift = 0
        
        var colors: [NSUIColor] = []
        for i in 0..<pieChartEntry.count {
            if i == 0 {
                let color = UIColor.init(hex: 0x81CF01, a: 1.0)
                colors.append(color)
            } else {
                let color = UIColor.init(hex: 0x81CF01, a: 0.25)
                colors.append(color)
            }
        }
        set.colors = colors
        
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .semibold))
        data.setValueTextColor(.black)
        
//        data.setDrawValues(false)
        self.pieChartView.drawEntryLabelsEnabled = false
        
        self.pieChartView.data = data
        self.pieChartView.highlightValues(nil)
        
        self.pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func onClickDepositeMoney(_ sender: UIButton) {
        let controller = GlobalData.fundStoryBoard().instantiateViewController(withIdentifier: "FundAmountVC") as! FundAmountVC
        controller.isFromMenu = true
        controller.isFromAdd = true
        let navController = UINavigationController.init(rootViewController: controller)
        appDelegate.drawerController.contentViewController = navController
        appDelegate.drawerController.hideMenu(animated: true, completion:nil)
        
    }
    
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnChartButtonClick(_ sender: UIButton) {
        if sender.tag == 1 {
            self.setupChartButton(Duration: "day")
        } else if sender.tag == 2 {
            self.setupChartButton(Duration: "week")
        } else if sender.tag == 3 {
            self.setupChartButton(Duration: "month")
        } else if sender.tag == 4 {
            self.setupChartButton(Duration: "year")
        } else {
            self.setupChartButton(Duration: "ytd")
        }
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension DashboardVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.arrHoldingList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HoldingCell", for: indexPath) as! HoldingCell
        
        let objDict = self.arrHoldingList[indexPath.section]
        let qty = (objDict.qty as NSString).doubleValue
        let lastDayPrice = (objDict.lastday_price as NSString).doubleValue
//        let variationValue = (objDict.unrealized_pl as NSString).doubleValue
//        let variationPer = (objDict.unrealized_plpc as NSString).doubleValue
//        let strVariationValue = String(format: "%.4f", variationValue)
//        let strVariationPer = String(format: "%.4f", variationPer)
        let current = qty * lastDayPrice
        let invested = (objDict.cost_basis as NSString).doubleValue
        let plValue = current - invested
        let plPer = (plValue * 100) / invested
        
        if objDict.image == "" {
            cell.viewStock.backgroundColor = UIColor.init(hex: 0x27B1FC)
            
            let dpName = objDict.symbol.prefix(1)
            cell.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: cell.imgStock.frame.size.width, imageHeight: cell.imgStock.frame.size.height, name: "\(dpName)")
        } else {
            cell.viewStock.backgroundColor = UIColor.white
            
            cell.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imgStock.sd_setImage(with: URL(string: objDict.image), placeholderImage: nil)
        }
        
        cell.lblStockName.text = objDict.symbol
        cell.lblStockQty.text = String(format: "%.4f", qty)
        cell.lblStockAmount.text = "$" + convertThousand(value: lastDayPrice)
        
        //**********//
//        if objDict.plVariationPer > 0 {
//            cell.lblStockVariation.text = "+\(String(format: "%.2f", objDict.plVariationValue)) (+\(String(format: "%.2f", objDict.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
//        } else if objDict.plVariationPer < 0 {
//            cell.lblStockVariation.text = "\(String(format: "%.2f", objDict.plVariationValue)) (\(String(format: "%.2f", objDict.plVariationPer))%)"//"\(strVariationValue) (\(strVariationPer)%)"
//        } else {
//            cell.lblStockVariation.text = "\(String(format: "%.2f", objDict.plVariationValue)) (0.00%)"
//        }
//
//        if objDict.plVariationValue > 0 {
//            cell.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
//        } else if objDict.plVariationValue < 0 {
//            cell.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
//        } else {
//            cell.lblStockVariation.textColor = UIColor.tblMarketDepthContent
//        }
        
        if plPer > 0 {
            cell.lblStockVariation.text = "+$\(convertThousand(value: plValue)) (+\(String(format: "%.2f", plPer))%)"
            cell.lblStockVariation.textColor = UIColor.init(hex: 0x65AA3D)
        } else if plPer < 0 {
            cell.lblStockVariation.text = "$\(convertThousand(value: plValue)) (\(String(format: "%.2f", plPer))%)"
            cell.lblStockVariation.textColor = UIColor.init(hex: 0xFE3D2F)
        } else {
            cell.lblStockVariation.text = "$\(convertThousand(value: plValue)) (0.00%)"
            cell.lblStockVariation.textColor = UIColor.tblMarketDepthContent
        }
        //**********//
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let objDict = self.arrHoldingList[indexPath.section]
        
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailVC
        controller.strSymbol = objDict.symbol
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    //FOOTER VIEW
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 20
//    }
//
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
//        footerView.backgroundColor = .clear
//        return footerView
//    }
}

//MARK: - BELOW CODE IS TO HIDE 0 VALUE IN BAR CHART
public class XValueFormatter: NSObject, IValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return value <= 0.0 ? "" : value.clean
    }
}

//MARK: - API CALL -

extension DashboardVC {
    //GET DASHBOARD GRAPH DETAIL
    func callDashboardGraphAPI(Duration duration: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_DASHBOARD_GRAPH + "/" + "\(duration)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            var arrDate: [String] = []
                            var arrValue: [Double] = []
                            
                            if let timestamp = payloadData["timestamp"] as? [NSNumber] {
                                for i in 0..<timestamp.count {
                                    let ts = timestamp[i]
                                    let date = Date(timeIntervalSince1970: TimeInterval(truncating: ts))
                                    let strDate = strongSelf.timeStampFormat.string(from: date as Date)
                                    arrDate.append(strDate)
                                }
                            }
                            
                            if let equity = payloadData["equity"] as? [Double] {
                                arrValue = equity
                            }
                            
                            if arrValue.count > 1 {
                                strongSelf.chartView.isHidden = false
                                strongSelf.lblNoChartDataAvailable.isHidden = true
                                strongSelf.setLineChartData(arrDate, values: arrValue)
                            }
                            else {
                                strongSelf.chartView.isHidden = true
                                strongSelf.lblNoChartDataAvailable.isHidden = false
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
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //TRADING ACCOUNT DETAIL
    func callTradingAccountAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.TRADING_ACCOUNT) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            GlobalData.shared.objTradingAccount = TradingAccountObject.init(payload)
                            
                            let portfolioValue = (GlobalData.shared.objTradingAccount.long_market_value as NSString).doubleValue
                            let withdrawableCash = (GlobalData.shared.objTradingAccount.cash_withdrawable as NSString).doubleValue
                            let buyingPower = (GlobalData.shared.objTradingAccount.buying_power as NSString).doubleValue
                            let cash = (GlobalData.shared.objTradingAccount.cash as NSString).doubleValue
                            let equity = (GlobalData.shared.objTradingAccount.equity)
                            
                            strongSelf.lblBalanceAmount.text = "$" + convertThousand(value: Double(equity) ?? 0.0)
                            strongSelf.lblPortfolioValue.text = "$" + convertThousand(value: portfolioValue)
                            
                            strongSelf.lblWithdrawableCash.text = "$" + convertThousand(value: withdrawableCash)
                            strongSelf.lblBuyingPower.text = "$" + convertThousand(value: buyingPower)
                            strongSelf.lblBuyingPowerTop.text = "$" + convertThousand(value: buyingPower)
                            strongSelf.lblCash.text = "$" + convertThousand(value: cash)
                            
                            strongSelf.setPieChartDataCount(2, range: 100)
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
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //HOLDINGS DATA
    func callGetPortfolioAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
                
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(Constants.URLS.GET_PORTFOLIO) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            strongSelf.arrHoldingList.removeAll()
                            for i in 0..<payloadData.count {
                                let objData = PortfolioObject.init(payloadData[i])
                                strongSelf.arrHoldingList.append(objData)
                            }
                            
                            if strongSelf.arrHoldingList.count > 0 {
                                strongSelf.arrHoldingSymbol = strongSelf.arrHoldingList.map { $0.symbol }
                                let strSymbol = strongSelf.arrHoldingSymbol.joined(separator: ",")
                                
                                //
                                strongSelf.arrPortfolio.removeAll()
                                for i in 0..<payloadData.count {
                                    let objData = PortfolioObject.init(payloadData[i])
                                    strongSelf.arrPortfolio.append(objData)
                                }
                                                            
                                if strongSelf.arrPortfolio.count > 0 {
                                    let arrInvestment = strongSelf.arrPortfolio.map { $0.stock_investment }
                                    strongSelf.investedAmount = arrInvestment.sum()
                                    
                                    let arrCurrent = strongSelf.arrPortfolio.map { $0.stock_current }
                                    strongSelf.currentAmount = arrCurrent.sum()
                                    
                                    strongSelf.setPortfolioData()
                                }
                                //
                                
                                var objBars = Dictionary<String,AnyObject>()
                                objBars["symbol"] = strSymbol as AnyObject
                                objBars["type"] = EMIT_TYPE_BARS as AnyObject
                                SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])

                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    var objTrades = Dictionary<String,AnyObject>()
                                    objTrades["symbol"] = strSymbol as AnyObject
                                    objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                                    SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
                                }
                                
                                strongSelf.tblHolding.isHidden = false
                                strongSelf.lblNoRecord.isHidden = true
                            } else {
                                strongSelf.tblHolding.isHidden = true
                                strongSelf.lblNoRecord.isHidden = false
                            }
                            
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblHolding)
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
            GlobalData.shared.hideProgress()
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
}
