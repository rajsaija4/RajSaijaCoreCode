//

import UIKit
import SideMenuSwift
import Charts
import SwiftyJSON
import SDWebImage

struct StockQuoteOption {
    var bidQTY: Int
    var bidPrice: Double
    var offerQTY: Int
    var offerPrice: Double
}

class StockDetailVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var viewStock: UIView!
    @IBOutlet weak var imgStock: UIImageView!
    @IBOutlet weak var lblStockName: UILabel!
    @IBOutlet weak var lblStockCompany: UILabel!

    @IBOutlet weak var viewStockDetailBG: UIView!
    @IBOutlet weak var viewGreen: UIView!
    @IBOutlet weak var lblStockPrice: UILabel!
    @IBOutlet weak var imgArrowVariation: UIImageView!
    @IBOutlet weak var lblStockVariation: UILabel!
    @IBOutlet weak var btnBuy: UIButton!
    @IBOutlet weak var btnSell: UIButton!

    @IBOutlet weak var viewStockDetail: UIView!
    @IBOutlet weak var stackFirstStock: UIStackView!
    @IBOutlet weak var lblOpenStackFirst: UILabel!
    @IBOutlet weak var lblHighStackFirst: UILabel!
    @IBOutlet weak var lblLowStackFirst: UILabel!
    @IBOutlet weak var lblCloseStackFirst: UILabel!

    @IBOutlet weak var stackSecondStock: UIStackView!
    @IBOutlet weak var lblOpenStackSecond: UILabel!
    @IBOutlet weak var lblCloseStackSecond: UILabel!
    @IBOutlet weak var lblHighStackSecond: UILabel!
    @IBOutlet weak var lblLowStackSecond: UILabel!
    @IBOutlet weak var lblVolumeStackSecond: UILabel!
    
    @IBOutlet weak var viewChart: UIView!
    @IBOutlet weak var lblNoChartDataAvailable: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var chartViewWidth: NSLayoutConstraint!

    @IBOutlet weak var stackViewChartBtn: UIStackView!
    @IBOutlet weak var btnDay: UIButton!
    @IBOutlet weak var btnWeek: UIButton!
    @IBOutlet weak var btnMonth: UIButton!
    @IBOutlet weak var btnSixMonth: UIButton!
    @IBOutlet weak var btnYear: UIButton!

    @IBOutlet weak var tblMarketDepth: ContentSizedTableView!
    @IBOutlet weak var tblMarketDepthHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewMarketTotalQTY: UIView!
    @IBOutlet weak var lblTitleTotalBidQTY: UILabel!
    @IBOutlet weak var lblTotalBidQTY: UILabel!
    @IBOutlet weak var lblTitleTotalOfferQTY: UILabel!
    @IBOutlet weak var lblTotalOfferQTY: UILabel!

    @IBOutlet weak var viewPaymentTransaction: UIView!
    @IBOutlet weak var lblPaymentTransaction: UILabel!

    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var tblNews: ContentSizedTableView!
    @IBOutlet weak var tblNewsHeightConstraint: NSLayoutConstraint!
    
    var strSymbol: String = ""
    var objStockDetail = AssetsObject.init([:])
    var arrStockGraph: [StockGraphObject] = []
    var arrQuotes: [StockQuoteOption] = []
    var objNews = NewsObject.init([:])
    
    var arrHoldingList: [PortfolioObject] = []
    
    var isNewsAvailable:Bool = false
        
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.btnBuy.isHidden = true
        self.btnSell.isHidden = true
        self.callGetPortfolioAPI()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // change your delay here
            SocketIOManager.shared.setupSocket()
            SocketIOManager.shared.setupStockSocketEvents()
            SocketIOManager.shared.socket?.connect()
            
            var objBars = Dictionary<String,AnyObject>()
            objBars["symbol"] = self.strSymbol as AnyObject
            objBars["type"] = EMIT_TYPE_BARS as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var objTrades = Dictionary<String,AnyObject>()
                objTrades["symbol"] = self.strSymbol as AnyObject
                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
            }
            
            var objQuotes = Dictionary<String,AnyObject>()
            objQuotes["symbol"] = self.strSymbol as AnyObject
            objQuotes["type"] = EMIT_TYPE_QUOTES as AnyObject
            SocketIOManager.shared.emitSubscribe(Data: objQuotes as [String : AnyObject])
        }
        
        self.SetupAllSocketNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateStockBars), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateStockTrades), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(kUpdateStockQuotes), object: nil)
        
        SocketIOManager.shared.disconnectSocket()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        DispatchQueue.main.async {
//            self.tblMarketDepthHeightConstraint.constant = self.tblMarketDepth.contentSize.height
//            self.tblNewsHeightConstraint.constant = self.tblNews.contentSize.height
//        }
//    }
    
    //MARK: - SETUP SOCKET NOTIFICATION -
    
    func SetupAllSocketNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(StockDetailVC.getStockBarData(notification:)), name: NSNotification.Name(kUpdateStockBars), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StockDetailVC.getStockTradesData(notification:)), name: NSNotification.Name(kUpdateStockTrades), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StockDetailVC.getStockQuotesData(notification:)), name: NSNotification.Name(kUpdateStockQuotes), object: nil)
    }

    @objc func getStockBarData(notification: Notification) {
        debugPrint("=====Getting Stock Bar Data=====")
        let barObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(barObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = barObject["symbol"] as? String {
                if symbol == self.strSymbol {
                    self.objStockDetail.openPrice = ("\(barObject["openPrice"] ?? "")" as NSString).doubleValue
//                    self.objStockDetail.closePrice = ("\(barObject["closePrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.highPrice = ("\(barObject["highPrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.lowPrice = ("\(barObject["lowPrice"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.volume = ("\(barObject["volume"] ?? "")" as NSString).integerValue
                    self.objStockDetail.tradeCount = ("\(barObject["tradeCount"] ?? "")" as NSString).integerValue
                    
                    DispatchQueue.main.async {
                        self.setupBarData()
                    }
                }
            }
        }
    }
    
    @objc func getStockTradesData(notification: Notification) {
        debugPrint("=====Getting Stock Trades Data=====")
        let tradesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(tradesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = tradesObject["symbol"] as? String {
                if symbol == self.strSymbol {
                    self.objStockDetail.current_price = ("\(tradesObject["price"] ?? "")" as NSString).doubleValue
                    self.objStockDetail.plVariationValue = self.objStockDetail.current_price - self.objStockDetail.prev_close_price//closePrice //self.objStockDetail.current_price - self.objStockDetail.openPrice
                    self.objStockDetail.plVariationPer = (self.objStockDetail.plVariationValue * 100) / self.objStockDetail.prev_close_price//closePrice
                    
                    DispatchQueue.main.async {
                        self.setupLiveData()
                    }
                }
            }
        }
    }
    
    @objc func getStockQuotesData(notification: Notification) {
        debugPrint("=====Getting Stock Quotes Data=====")
        let quotesObject = (notification.object as! Dictionary<String,Any>)["data"] as! Dictionary<String,Any>
        debugPrint(quotesObject)
        
        DispatchQueue.global(qos: .utility).async {
            if let symbol = quotesObject["symbol"] as? String {
                if self.strSymbol == symbol {
                    let bidQTY = ("\(quotesObject["bidQty"] ?? "")" as NSString).integerValue
                    let bidPrice = ("\(quotesObject["bidPrice"] ?? "")" as NSString).doubleValue
                    let offerQTY = ("\(quotesObject["askQty"] ?? "")" as NSString).integerValue
                    let offerPrice = ("\(quotesObject["askPrice"] ?? "")" as NSString).doubleValue
                    
                    DispatchQueue.main.async {
                        if self.arrQuotes.count >= 5 {
                            self.arrQuotes.remove(at: 0)
                            self.arrQuotes.append(StockQuoteOption(bidQTY: bidQTY, bidPrice: bidPrice, offerQTY: offerQTY, offerPrice: offerPrice))
                        } else {
                            self.arrQuotes.append(StockQuoteOption(bidQTY: bidQTY, bidPrice: bidPrice, offerQTY: offerQTY, offerPrice: offerPrice))
                        }
                        
                        self.tblMarketDepth.reloadData()
                        
//                        self.tblMarketDepthHeightConstraint.constant = /self.tblMarketDepth.contentSize.height
                    }
                }
            }
        }
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewStockDetailBG.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 10)
            self.viewGreen.roundCorners(corners: [.topLeft, .topRight], radius: 10)
            
            self.viewStockDetailBG.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.btnBuy.layer.cornerRadius = self.btnBuy.frame.height / 2.0
            self.btnSell.layer.cornerRadius = self.btnSell.frame.height / 2.0
            
            self.viewStockDetail.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
            
            self.viewPaymentTransaction.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.2), ShadowColor: UIColor.init(hex: 0x000000, a: 0.2))
        }
                
        self.stackFirstStock.isHidden = false
        self.stackSecondStock.isHidden = true
        
        self.tblMarketDepth.showsVerticalScrollIndicator = false
        self.tblMarketDepth.tableFooterView = UIView()
        
        self.lblNoChartDataAvailable.textColor = UIColor.labelTextColor
        
        self.viewMarketTotalQTY.backgroundColor = UIColor.viewThemeColorWithOpacity
        self.lblTitleTotalBidQTY.textColor = UIColor.labelTextColor
        self.lblTotalBidQTY.textColor = UIColor.tblMarketDepthContent
        self.lblTitleTotalOfferQTY.textColor = UIColor.labelTextColor
        self.lblTotalOfferQTY.textColor = UIColor.tblMarketDepthContent
        
        self.lblPaymentTransaction.textColor = UIColor.labelTextColor
        
        self.lblNewsTitle.textColor = UIColor.labelTextColor
        
        self.tblNews.showsVerticalScrollIndicator = false
        self.tblNews.tableFooterView = UIView()
        
        self.chartView.isHidden = true
        self.lblNoChartDataAvailable.isHidden = true
        
//        SocketIOManager.shared.setupSocket()
//        SocketIOManager.shared.setupStockSocketEvents()
//        SocketIOManager.shared.socket?.connect()
        
        DispatchQueue.main.async {
            self.tblMarketDepthHeightConstraint.constant = 230
        }
        
        //SET DATA
        self.lblTotalBidQTY.text = "-"
        self.lblTotalOfferQTY.text = "-"
        
        self.setupChartButton(Duration: "day")
        
        self.callStockDetailAPI()
        self.callGetNewsBySymbolAPI()
    }
    
    //SET BAR DATA
    func setupBarData() {
        self.lblOpenStackFirst.text = "$" + convertThousand(value: self.objStockDetail.openPrice)
        self.lblHighStackFirst.text = "$" + convertThousand(value: self.objStockDetail.highPrice)
        self.lblLowStackFirst.text = "$" + convertThousand(value: self.objStockDetail.lowPrice)
        self.lblCloseStackFirst.text = "$" + convertThousand(value: self.objStockDetail.closePrice)
        
        self.lblOpenStackSecond.text = "$" + convertThousand(value: self.objStockDetail.openPrice)
        self.lblCloseStackSecond.text = "$" + convertThousand(value: self.objStockDetail.closePrice)
        self.lblHighStackSecond.text = "$" + convertThousand(value: self.objStockDetail.highPrice)
        self.lblLowStackSecond.text = "$" + convertThousand(value: self.objStockDetail.lowPrice)
        self.lblVolumeStackSecond.text = convertThousand(value: Double(self.objStockDetail.volume))
    }
    
    //SET LIVE DATA
    func setupLiveData() {
        self.lblStockPrice.text = "$" + convertThousand(value: self.objStockDetail.current_price)
        
        if self.objStockDetail.plVariationPer > 0 {
            self.lblStockVariation.text = "$+\(convertThousand(value: self.objStockDetail.plVariationValue)) (+\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else if self.objStockDetail.plVariationPer < 0 {
            self.lblStockVariation.text = "$\(convertThousand(value: self.objStockDetail.plVariationValue)) (\(String(format: "%.2f", self.objStockDetail.plVariationPer))%)"
        } else {
            self.lblStockVariation.text = "$\(convertThousand(value: self.objStockDetail.plVariationValue)) (0.00%)"
        }
        
        if self.objStockDetail.plVariationValue > 0 {
            self.imgArrowVariation.image = UIImage.init(named: "ic_stock_up")
        } else if self.objStockDetail.plVariationValue < 0 {
            self.imgArrowVariation.image = UIImage.init(named: "ic_stock_down")
        } else {
            self.imgArrowVariation.image = UIImage.init(named: "")
        }
    }
    
    //MARK: - HELPER -
    
    func setupChartButton(Duration duration: String) {
        if duration == "day" {
            self.btnDay.setTitleColor(UIColor.white, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnSixMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnSixMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
        } else if duration == "week" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.white, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnSixMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnSixMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
        } else if duration == "month" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.white, for: [])
            self.btnSixMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnSixMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.clear
        } else if duration == "6months" {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnSixMonth.setTitleColor(UIColor.white, for: [])
            self.btnYear.setTitleColor(UIColor.btnChartColor, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnSixMonth.backgroundColor = UIColor.init(hex: 0x27B1FC)
            self.btnYear.backgroundColor = UIColor.clear
        } else {
            self.btnDay.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnWeek.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnSixMonth.setTitleColor(UIColor.btnChartColor, for: [])
            self.btnYear.setTitleColor(UIColor.white, for: [])

            self.btnDay.backgroundColor = UIColor.clear
            self.btnWeek.backgroundColor = UIColor.clear
            self.btnMonth.backgroundColor = UIColor.clear
            self.btnSixMonth.backgroundColor = UIColor.clear
            self.btnYear.backgroundColor = UIColor.init(hex: 0x27B1FC)
        }
        
        self.callStockGraphDetailAPI(Duration: duration)
    }
    
    //Set Line Chart Data
    func setLineChartData(_ dataPoints: [String], values: [Double]) {
//        self.chartViewWidth.constant = CGFloat((((dataPoints.count)+1) * 60) + 60)
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
//        set1.mode = .linear //.cubicBezier
//        set1.setColor(ChartColorTemplates.colorFromString("#30006DFF"))
//        set1.setCircleColor(ChartColorTemplates.colorFromString("#006DFF"))
        set1.setColor(Constants.Color.THEME_GREEN)
        set1.setCircleColor(Constants.Color.THEME_GREEN)
        set1.lineWidth = 2
        set1.circleRadius = 2
        set1.drawCircleHoleEnabled = false
        set1.circleHoleColor = .clear
        set1.formLineWidth = 1
        set1.formSize = 0
        set1.valueTextColor = UIColor.labelTextColor
        set1.valueFont = UIFont(name: Constants.Font.YUGOTHIC_UI_REGULAR, size: 10.0)!
        
        let gradientColors = [UIColor.init(hex: 0xFFFFFF, a: 0.0).cgColor, Constants.Color.THEME_GREEN.cgColor
                              ]
        let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!

        set1.fillAlpha = 1
//        set1.fill = LinearGradientFill(gradient: gradient, angle: 90)
        set1.fill = Fill.fillWithLinearGradient(gradient, angle: 90.0)
        set1.drawFilledEnabled = true
        
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
    
    //MARK: - ACTIONS -
    
    @IBAction func btnMenuClick(_ sender: UIButton) {
        appDelegate.drawerController.revealMenu(animated: true, completion: nil)
    }
    
    @IBAction func btnCloseClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAddToWatchlistClick(_ sender: UIButton) {
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "PopupAddStockWatchlistVC") as! PopupAddStockWatchlistVC
        controller.strSymbol = self.strSymbol
        controller.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func btnSetAlertClick(_ sender: UIButton) {
        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "SetAlertVC") as! SetAlertVC
        controller.isFromEdit = false
        controller.objStockDetail = self.objStockDetail
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnBuyClick(_ sender: UIButton) {
        
        let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewMarketVc") as! NewMarketVc
        controller.isSelectedBuy = true
        controller.objStockDetail = self.objStockDetail
        controller.arrHoldingList = self.arrHoldingList
        self.navigationController?.pushViewController(controller, animated: true)

//        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "BuySellVC") as! BuySellVC
//        controller.isSelectedBuy = true
//        controller.objStockDetail = self.objStockDetail
//        controller.arrHoldingList = self.arrHoldingList
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnSellClick(_ sender: UIButton) {
        
        let controller = GlobalData.updateStoryBoard().instantiateViewController(withIdentifier: "NewMarketVc") as! NewMarketVc
        controller.isSelectedBuy = false
        controller.objStockDetail = self.objStockDetail
        controller.arrHoldingList = self.arrHoldingList
        self.navigationController?.pushViewController(controller, animated: true)

//        let controller = GlobalData.dashboardStoryBoard().instantiateViewController(withIdentifier: "BuySellVC") as! BuySellVC
//        controller.isSelectedBuy = false
//        controller.objStockDetail = self.objStockDetail
//        controller.arrHoldingList = self.arrHoldingList
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func btnStockArrowClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.stackFirstStock.isHidden = true
            self.stackSecondStock.isHidden = false
        } else {
            self.stackFirstStock.isHidden = false
            self.stackSecondStock.isHidden = true
        }
    }
    
    @IBAction func btnChartButtonClick(_ sender: UIButton) {
        if sender.tag == 1 {
            self.setupChartButton(Duration: "day")
        } else if sender.tag == 2 {
            self.setupChartButton(Duration: "week")
        } else if sender.tag == 3 {
            self.setupChartButton(Duration: "month")
        } else if sender.tag == 4 {
            self.setupChartButton(Duration: "6months")
        } else {
            self.setupChartButton(Duration: "year")
        }
    }
    
    @IBAction func btnPaymentTransactionlClick(_ sender: UIButton) {
        let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "FundsTransactionVC") as! FundsTransactionVC
        controller.isSelectedAdd = true
        controller.isNeedToPopOnly = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

// MARK: - UITABLEVIEW DATASOURCE & DELEGATE -

extension StockDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tblMarketDepth {
            if self.arrQuotes.count > 0 {
                return self.arrQuotes.count + 1
            } else {
                return 6
            }
        } else {
            if self.isNewsAvailable {
                return self.objNews.arrNews.count
            } else {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tblMarketDepth {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MarketDepthCell", for: indexPath) as! MarketDepthCell
            
            if (indexPath.section % 2) != 0 {
                cell.stackviewHeader.isHidden = true
                cell.stackviewContent.isHidden = false
                
                cell.backgroundColor = UIColor.init(hex: 0xF5F5F5, a: 0.57)
            } else {
                if indexPath.section == 0 {
                    cell.stackviewHeader.isHidden = false
                    cell.stackviewContent.isHidden = true
                    
                    cell.backgroundColor = UIColor.tblMarketDepthHeaderBG
                } else {
                    cell.stackviewHeader.isHidden = true
                    cell.stackviewContent.isHidden = false
                    
                    cell.backgroundColor = UIColor.tblMarketDepthEvenCellBG
                }
            }
            
            if self.arrQuotes.count > 0 {
                if indexPath.section != 0 {
                    let bidPrice = self.arrQuotes[indexPath.section - 1].bidPrice
                    let offerPrice = self.arrQuotes[indexPath.section - 1].offerPrice
                    
                    cell.lblBidQty.text = "\(self.arrQuotes[indexPath.section - 1].bidQTY)"
                    cell.lblBidPrice.text = convertThousand(value: bidPrice)
                    cell.lblOfferQty.text = "\(self.arrQuotes[indexPath.section - 1].offerQTY)"
                    cell.lblOfferPrice.text = convertThousand(value: offerPrice)
                }
            } else {
                cell.lblBidQty.text = "0"
                cell.lblBidPrice.text = "0"
                cell.lblOfferQty.text = "0"
                cell.lblOfferPrice.text = "0"
            }
                        
            cell.selectionStyle = .none
            return cell
        } else {
            if self.isNewsAvailable {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
                
                let objDict = self.objNews.arrNews[indexPath.section]
                let date = objDict.published_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd, hh:mm a")
                let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd, hh:mm a", OutputFormat: "MMM dd, yyyy hh:mm a")
                                
                cell.imgNews.sd_imageIndicator = SDWebImageActivityIndicator.grayLarge
                cell.imgNews.sd_setImage(with: URL(string: objDict.image_url), placeholderImage: nil)
                
                cell.lblTitle.text = objDict.title
                cell.lblDescription.text = objDict.description_news
                cell.lblDate.text = finalDate
                
                cell.selectionStyle = .none
                return cell
            } else {
                var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
                if (cell == nil) {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }
                
                cell?.textLabel?.text = "No news found"
                cell?.textLabel?.textAlignment = .center
                
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == self.tblNews {
            if self.isNewsAvailable {
                let controller = GlobalData.profileStoryBoard().instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
                controller.isFrom = "News"
                controller.objNews = self.objNews.arrNews[indexPath.section]
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tblMarketDepth {
            return 90
        } else {
            if self.isNewsAvailable {
                return 130
            } else {
                return 50
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

//MARK: - API CALL -

extension StockDetailVC {
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
                            
                            if strongSelf.arrHoldingList.count > 0 {
                                let arrSymbol = strongSelf.arrHoldingList.map { $0.symbol }
                                
                                if arrSymbol.contains(strongSelf.strSymbol) {
                                    strongSelf.btnBuy.isHidden = false
                                    strongSelf.btnSell.isHidden = false
                                } else {
                                    strongSelf.btnBuy.isHidden = false
                                    strongSelf.btnSell.isHidden = true
                                }
                            }
                        }
                    }
                    else if response["status"] as! Int == invalidTokenCode {
                        GlobalData.shared.displayInvalidTokenAlert(Title: kAlert, Message: (response["message"] as! String))
                    }
                    else {
                        strongSelf.btnBuy.isHidden = false
                        GlobalData.shared.showDarkStyleToastMesage(message: (response["message"] as! String))
                    }
                }
            }
        } failure: { (error) in
            GlobalData.shared.showDarkStyleToastMesage(message: kNetworkError)
        }
    }
    
    //GET STOCK DETAIL BY SYMBOL
    func callStockDetailAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.SEARCH_SHARE_SYMBOL + "/" + "\(self.strSymbol)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payload = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objStockDetail = AssetsObject.init(payload)
                            
                            if strongSelf.objStockDetail.image == "" {
                                strongSelf.viewStock.backgroundColor = UIColor.init(hex: 0x27B1FC)
                                
                                let dpName = strongSelf.objStockDetail.symbol.prefix(1)
                                strongSelf.imgStock.image = GlobalData.shared.GenrateImageFromText(imageWidth: strongSelf.imgStock.frame.size.width, imageHeight: strongSelf.imgStock.frame.size.height, name: "\(dpName)")
                            } else {
                                strongSelf.viewStock.backgroundColor = UIColor.white
                                
                                strongSelf.imgStock.sd_imageIndicator = SDWebImageActivityIndicator.gray
                                strongSelf.imgStock.sd_setImage(with: URL(string: strongSelf.objStockDetail.image), placeholderImage: nil)
                            }
                            
                            strongSelf.lblStockName.text = strongSelf.objStockDetail.symbol
                            if strongSelf.objStockDetail.symbole_description.count > 0 {
                                strongSelf.lblStockCompany.text = strongSelf.objStockDetail.symbole_description

                            }
                            else {
                                strongSelf.lblStockCompany.text = strongSelf.objStockDetail.companyName

                            }
                            
                            strongSelf.setupBarData()
                            strongSelf.setupLiveData()
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblMarketDepth)
                            
//                            var objBars = Dictionary<String,AnyObject>()
//                            objBars["symbol"] = strongSelf.strSymbol as AnyObject
//                            objBars["type"] = EMIT_TYPE_BARS as AnyObject
//                            SocketIOManager.shared.emitSubscribe(Data: objBars as [String : AnyObject])
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                                var objTrades = Dictionary<String,AnyObject>()
//                                objTrades["symbol"] = strongSelf.strSymbol as AnyObject
//                                objTrades["type"] = EMIT_TYPE_TRADES as AnyObject
//                                SocketIOManager.shared.emitSubscribe(Data: objTrades as [String : AnyObject])
//                            }
//
//                            var objQuotes = Dictionary<String,AnyObject>()
//                            objQuotes["symbol"] = strongSelf.strSymbol as AnyObject
//                            objQuotes["type"] = EMIT_TYPE_QUOTES as AnyObject
//                            SocketIOManager.shared.emitSubscribe(Data: objQuotes as [String : AnyObject])
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
    
    //GET STOCK GRAPH DETAIL
    func callStockGraphDetailAPI(Duration duration: String) {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_PORTFOLIO + "/" + "\(self.strSymbol)" + "/" + "\(duration)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? [Dictionary<String, Any>] {
                            var arrDate: [String] = []
                            var arrValue: [Double] = []
                            strongSelf.arrStockGraph.removeAll()
                            
                            for i in 0..<payloadData.count {
                                let objData = StockGraphObject.init(payloadData[i])
                                strongSelf.arrStockGraph.append(objData)
                                arrDate.append(objData.t)
                                arrValue.append(objData.o)
                            }
                            
                            if strongSelf.arrStockGraph.count > 1 {
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
    
    //GET NEWS BY INDUSTRY
    func callGetNewsBySymbolAPI() {
        if GlobalData.shared.checkInternet() == false {
            GlobalData.shared.displayAlertMessage(Title: kAlert, Message: kInternetUnavailable)
            return
        }
        
        let strURL = Constants.URLS.GET_NEWS_SYMBOL + "/" + "\(self.strSymbol)"
        
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
        
        AFWrapper.shared.requestGETURL(strURL) { [weak self] (JSONResponse) in
            guard let strongSelf = self else { return }
            
            GlobalData.shared.hideProgress()
            
            if JSONResponse != JSON.null {
                if let response = JSONResponse.rawValue as? [String : Any] {
                    if response["status"] as! Int == successCode {
                        if let payloadData = response["data"] as? Dictionary<String, Any> {
                            strongSelf.objNews = NewsObject.init(payloadData)
                            
                            if strongSelf.objNews.arrNews.count > 0 {
                                strongSelf.isNewsAvailable = true
                            } else {
                                strongSelf.isNewsAvailable = false
                            }
                            GlobalData.shared.reloadTableView(tableView: strongSelf.tblNews)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                strongSelf.tblNewsHeightConstraint.constant = strongSelf.tblNews.contentSize.height
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
}
