//
//

import UIKit
import Charts

class InvestingVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPortfolioValueTitle: UILabel!
    @IBOutlet weak var lblPortfolioValue: UILabel!
    @IBOutlet weak var lblPortfolioDesc: UILabel!
    
    @IBOutlet var pieChartView: PieChartView!
    @IBOutlet weak var lblStockOptionTitle: UILabel!
    @IBOutlet weak var lblStockOptionValue: UILabel!
    @IBOutlet weak var lblCashTitle: UILabel!
    @IBOutlet weak var lblCashValue: UILabel!
    
    @IBOutlet weak var lblBuyingPowerTitle: UILabel!
    @IBOutlet weak var lblBuyingPowerValue: UILabel!
    @IBOutlet weak var lblBuyingPowerDesc: UILabel!
    
    @IBOutlet weak var lblWithdrawableTitle: UILabel!
    @IBOutlet weak var lblWithdrawableValue: UILabel!
    @IBOutlet weak var lblInstantDepositeTitle: UILabel!
    @IBOutlet weak var lblInstantDepositeValue: UILabel!
    @IBOutlet weak var lblBuyingTitle: UILabel!
    @IBOutlet weak var lblBuyingValue: UILabel!
    
    @IBOutlet weak var lblDepositeHealthTitle: UILabel!
    @IBOutlet weak var lblDepositeHealthValue: UILabel!
    @IBOutlet weak var lblDepositeHealthDesc: UILabel!
    
    @IBOutlet weak var lblDepositeLimitTitle: UILabel!
    @IBOutlet weak var lblDepositeLimitValue: UILabel!
    @IBOutlet weak var lblPendingDepositeTitle: UILabel!
    @IBOutlet weak var lblPendingDepositeValue: UILabel!
    @IBOutlet weak var lblPendingUsedTitle: UILabel!
    @IBOutlet weak var lblPendingUsedValue: UILabel!
    
    let kCharacterBeforReadMore =  20
    let kReadMoreText           =  "...ReadMore"
    let kReadLessText           =  "...ReadLess"
    
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
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        self.lblPortfolioValueTitle.textColor = UIColor.tblStatementContent
        self.lblPortfolioValue.textColor = UIColor.labelTextColor
        self.lblPortfolioDesc.textColor = UIColor.tblStatementContent
        
        self.lblStockOptionTitle.textColor = UIColor.tblStatementContent
        self.lblStockOptionValue.textColor = UIColor.labelTextColor
        self.lblCashTitle.textColor = UIColor.tblStatementContent
        self.lblCashValue.textColor = UIColor.labelTextColor
        
        self.lblBuyingPowerTitle.textColor = UIColor.labelTextColor
        self.lblBuyingPowerValue.textColor = UIColor.labelTextColor
        self.lblBuyingPowerDesc.textColor = UIColor.tblStatementContent
        
        self.lblWithdrawableTitle.textColor = UIColor.tblStatementContent
        self.lblWithdrawableValue.textColor = UIColor.labelTextColor
        self.lblInstantDepositeTitle.textColor = UIColor.tblStatementContent
        self.lblInstantDepositeValue.textColor = UIColor.labelTextColor
        self.lblBuyingTitle.textColor = UIColor.tblStatementContent
        self.lblBuyingValue.textColor = UIColor.labelTextColor
        
        self.lblDepositeHealthTitle.textColor = UIColor.labelTextColor
        self.lblDepositeHealthValue.textColor = UIColor.labelTextColor
        self.lblDepositeHealthDesc.textColor = UIColor.tblStatementContent
        
        self.lblDepositeLimitTitle.textColor = UIColor.tblStatementContent
        self.lblDepositeLimitValue.textColor = UIColor.labelTextColor
        self.lblPendingDepositeTitle.textColor = UIColor.tblStatementContent
        self.lblPendingDepositeValue.textColor = UIColor.labelTextColor
        self.lblPendingUsedTitle.textColor = UIColor.tblStatementContent
        self.lblPendingUsedValue.textColor = UIColor.labelTextColor
        
        //SET DATA
        self.lblPortfolioValue.text = "$588.91"
        self.lblPortfolioDesc.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
        
        self.lblStockOptionValue.text = "$566.51"
        self.lblCashValue.text = "$22.40"
        
        self.setPieChartDataCount(4, range: 100)
                
        self.lblBuyingPowerValue.text = "$12.40"
        self.lblBuyingPowerDesc.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
        
        self.lblWithdrawableValue.text = "$0.00"
        self.lblInstantDepositeValue.text = "$12.40"
        self.lblBuyingValue.text = "$12.40"
        
        self.lblDepositeHealthValue.text = "Good"
        self.lblDepositeHealthDesc.text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy"
        
        self.lblDepositeLimitValue.text = "$1,000.00"
        self.lblPendingDepositeValue.text = "$20.00"
        self.lblPendingUsedValue.text = "$20.00"
    }
    
    //MARK: - HELPER -
    
    //Set Pie Chart Data
    func setPieChartDataCount(_ count: Int, range: UInt32) {
        self.pieChartView.usePercentValuesEnabled = true
        self.pieChartView.drawSlicesUnderHoleEnabled = false
        self.pieChartView.holeRadiusPercent = 0.75
        self.pieChartView.transparentCircleRadiusPercent = 0.2
        self.pieChartView.chartDescription?.enabled = false
        self.pieChartView.setExtraOffsets(left: 5, top: 5, right: 5, bottom: 5)
        
        self.pieChartView.drawCenterTextEnabled = true
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let amount = "$588.91"
        
        let centerText = NSMutableAttributedString(string: "\(amount)\nPortfolio")
        centerText.setAttributes([NSAttributedString.Key.font: UIFont.init(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: 10.0)!, NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, centerText.length))
                
        centerText.addAttributes([.font : UIFont(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: 10.0)!,
                                  .foregroundColor : UIColor.labelTextColor], range: NSRange(location: 14, length: 0))
        self.pieChartView.centerAttributedText = centerText;
        
        self.pieChartView.drawHoleEnabled = true
        self.pieChartView.rotationAngle = 0
        self.pieChartView.rotationEnabled = true
        self.pieChartView.highlightPerTapEnabled = true
        self.pieChartView.legend.enabled = false
        
//        self.pieChartView.holeColor = UIColor.clear
        
//        let l = self.pieChartView.legend
//        l.horizontalAlignment = .right
//        l.verticalAlignment = .top
//        l.orientation = .vertical
//        l.xEntrySpace = 7
//        l.yEntrySpace = 0
//        l.yOffset = 0
////        self.pieChartView.legend = l
        
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5),
                                     label: "",//parties[i % parties.count]
                                     icon: nil)
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.drawIconsEnabled = false
        set.sliceSpace = 2
        
        set.selectionShift = 0
        
        var colors: [NSUIColor] = []
        for i in 0..<entries.count {
//            let red = Double(arc4random_uniform(256))
//            let green = Double(arc4random_uniform(256))
//            let blue = Double(arc4random_uniform(256))
//
//            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//            colors.append(color)

            if i == entries.count - 1 {
                let color = UIColor.init(hex: 0x81CF01, a: 0.25)
                colors.append(color)
            } else {
                let color = UIColor.init(hex: 0x81CF01, a: 1.0)
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
        
        data.setValueFont(.systemFont(ofSize: 11, weight: .light))
        data.setValueTextColor(.black)
        
        data.setDrawValues(false)
        self.pieChartView.drawEntryLabelsEnabled = false
        
        self.pieChartView.data = data
        self.pieChartView.highlightValues(nil)
        
        self.pieChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnWithdrawClick(_ sender: UIButton) {
        debugPrint("Withdraw Click")
    }
}
