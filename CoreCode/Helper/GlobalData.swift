//
//  GlobalData.swift
//  projectName
//
//  companyName on 22/10/21.
//

import UIKit
import Foundation
import Alamofire
import SVProgressHUD
import CoreLocation

class GlobalData {
    
    var objTradingAccount = TradingAccountObject.init([:])

    class var shared: GlobalData {
        struct Singleton {
            static let instance = GlobalData()
        }
        return Singleton.instance
    }
    
    func checkInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func showToastMessage(message :String) {
        UIApplication.shared.windows.first?.makeToast(message, duration: 2.0, position: .bottom)
    }
    
    class func GetValueFromData(dataDict:Dictionary<String,AnyObject>, key : String) -> String {
        var value : String = ""
        if dataDict[key] != nil {
            if dataDict[key] is NSNumber {
                value = (dataDict[key] as! NSNumber).stringValue
            } else if dataDict[key] is String {
                value = (dataDict[key] as! String)
            }  else if dataDict[key] is Int {
                value = String(format:"%d",dataDict[key] as! Int)
            }else if dataDict[key] is Float {
                value = String(format:"%.2f",dataDict[key] as! Float)
            }
        }
        return value
    }
    
    //MARK: - Random UIColor
    func randomColor() -> UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
    
    //MARK: - CHECK USER DEFAULT KEY EXISTS -
    func containsUserDefaultKey(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    //MARK: - RELOAD TABLEVIEW -
    func reloadTableView(tableView: UITableView) {
        DispatchQueue.main.async {
            tableView.reloadData()
        }
    }
    
    //MARK: - RELOAD COLLECTIONVIEW -
    func reloadCollectionView(collectionView: UICollectionView) {
        DispatchQueue.main.async {
            collectionView.reloadData()
        }
    }
    
    //MARK: - UIALERT METHOD -
    func displayAlertMessage(Title title: String, Message message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertMessageOnController(Title title: String, Message message: String?, controller: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            
        }))
        controller.present(alert, animated: true, completion: nil)
    }
    
    func displayAlertWithOkAction(_ parent: UIViewController, title: String, message: String, btnTitle: String, actionBlock: @escaping (_ isOK:Bool)->Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: btnTitle, style: .default) { (action) in
            actionBlock(true)
        }
        alertController.addAction(okAction)
        parent.present(alertController, animated: true, completion: nil)
    }
    
    func displayInvalidTokenAlert(Title title: String, Message message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            appDelegate.logoutUser()
        })
        alertController.addAction(defaultAction)
        appDelegate.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
    func displayInvalidTokenAlertInController(Title title: String, Message message: String?, controller: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: { action in
            appDelegate.logoutUser()
        })
        alertController.addAction(defaultAction)
        controller.present(alertController, animated: true, completion: nil)
    }
    
    func displayConfirmationAlert(_ parent: UIViewController, title: String, message: String, btnTitle1: String, btnTitle2: String, actionBlock: @escaping (_ isConfirmed:Bool)->Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: btnTitle1, style: .cancel) { (action) in
            actionBlock(false)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: btnTitle2, style: .default) { (action) in
            actionBlock(true)
        }
        alertController.addAction(okAction)
        parent.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - HEX STRING TO UICOLOR -
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK: - SVProgressHUD -
    
    func customizationSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setDefaultStyle(.light)
        SVProgressHUD.setBackgroundLayerColor(UIColor.black.withAlphaComponent(0.30))
        SVProgressHUD.setBackgroundColor(UIColor.white)
        SVProgressHUD.setFont(UIFont.systemFont(ofSize: 16.0))
        SVProgressHUD.setRingRadius(18)
        
        SVProgressHUD.setRingThickness(2.5)
        SVProgressHUD.setCornerRadius(10.0)
    }
    
    func showDefaultProgress() {
        SVProgressHUD.show()
    }
    
    func showProgressWithTitle(title: String) {
        SVProgressHUD.show(withStatus: title)
    }
    
    func hideProgress() {
        SVProgressHUD.dismiss()
    }
    
    //MARK: - TOAST -
    func showSystemToastMesage(message: String) {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                var style = ToastStyle()
                style.backgroundColor = .white
                style.messageColor = .black
                appDelegate.window?.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
            }
            else {
                var style = ToastStyle()
                style.backgroundColor = .black
                style.messageColor = .white
                appDelegate.window?.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
            }
        } else {
            var style = ToastStyle()
            style.backgroundColor = .black
            style.messageColor = .white
            appDelegate.window?.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
        }
    }
    
    func showSystemToastMesageInController(message: String, controller: UIViewController) {
        if #available(iOS 13.0, *) {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                var style = ToastStyle()
                style.backgroundColor = .white
                style.messageColor = .black
                controller.view.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
            }
            else {
                var style = ToastStyle()
                style.backgroundColor = .black
                style.messageColor = .white
                controller.view.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
            }
        } else {
            var style = ToastStyle()
            style.backgroundColor = .black
            style.messageColor = .white
            controller.view.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
        }
    }
    
    func showLightStyleToastMesage(message :String) {
        var style = ToastStyle()
        style.backgroundColor = .white
        style.messageColor = .black
        appDelegate.window?.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
    }
    
    func showLightStyleToastMesageInController(message :String, controller: UIViewController) {
        var style = ToastStyle()
        style.backgroundColor = .white
        style.messageColor = .black
        controller.view.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
    }
    
    func showDarkStyleToastMesage(message :String) {
        var style = ToastStyle()
        style.backgroundColor = .black
        style.messageColor = .white
        appDelegate.window?.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
    }
    
    func showDarkStyleToastMesageInController(message :String, controller: UIViewController) {
        var style = ToastStyle()
        style.backgroundColor = .black
        style.messageColor = .white
        controller.view.makeToast(message, duration: 2.0, position: .bottom, title: nil, image: nil, style: style, completion: nil)
    }
    
    //MARK: - CHECK LOCATION STATUS -
    func checkLocationStatus() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            @unknown default:
                return false
            }
        } else {
            return false
        }
    }
    
    //MARK: - FULL TIME STRING -
    
    func FullTimeString(time: TimeInterval) -> String {
        let hour = Int(time) / 3600
        let minute = Int(time) / 60 % 60
        let second = Int(time) % 60

        // return formated string
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    //MARK: - CONVERT DATE TO STRING METHOD -
    
    func convertDateToString(Date date: Date, DateFormat dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: date)
    }
    
    //MARK: - CONVERT STRING TO DATE METHOD -
    
    func convertStringToDate(StrDate strDate: String, DateFormat dateFormat: String, timeZone: TimeZone? = .current) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = timeZone //TimeZone(abbreviation: "UTC")
        //according to date format your date string
        guard let date = dateFormatter.date(from: strDate) else {
            fatalError()
        }
        return date
    }
    
    func utcToLocalDateFormat(StrDate strDate: String, DateFormat dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: strDate) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = dateFormat//"H:mm:ss"
        
            return date
        }
        return nil
    }
    
    func utcToLocalStringFormat(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"
        
            return dateFormatter.string(from: date)
        }
        return nil
    }
    
    //MARK: - CONVERT DATE FORMAT METHOD -
    
    func formattedDateFromString(dateString: String, InputFormat inputFormat: String, OutputFormat outputformat: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
//        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = outputformat
//            outputFormatter.amSymbol = "am"
//            outputFormatter.pmSymbol = "pm"
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    //MARK: - FIND PERCENTAGE BETWEEN TWO NUMBER -
    
    func calculatePercentage(totalValue: Double, currentValue: Double) -> Double {
        let calculateValue = ceil((currentValue/totalValue)*100)
        let finalValue = calculateValue/100
        return finalValue
    }
    
    //MARK: - CHANGE UILABEL COLOR & ATTRIBUTED STRING -
    
    func setColoredSelectedLabel(mainStr: String, mainColor: UIColor, selectedstr: String, selectedColor: UIColor) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: mainStr)
        attributedString.setColor(color: mainColor, forText: mainStr)
        attributedString.setColor(color: selectedColor, forText: selectedstr)
        
        return attributedString
    }
    
    func convertStringtoAttributedText(strFirst: String, strFirstFont: UIFont, strFirstColor: UIColor, strSecond: String, strSecondFont: UIFont, strSecondColor: UIColor) -> NSMutableAttributedString {
        let attrs1 = [NSAttributedString.Key.font : strFirstFont, NSAttributedString.Key.foregroundColor : strFirstColor]
        let attrs2 = [NSAttributedString.Key.font : strSecondFont, NSAttributedString.Key.foregroundColor : strSecondColor]

        let attributedString1 = NSMutableAttributedString(string:strFirst, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:strSecond, attributes:attrs2)

        attributedString1.append(attributedString2)
        return attributedString1
    }
    
    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.init(name: Constants.Font.YUGOTHIC_UI_BOLD, size: font.pointSize)!]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }
    
    //MARK: - GENRATE IMAGE FROM TEXT -
    
    func GenrateImageFromText(imageWidth: CGFloat, imageHeight: CGFloat, name: String?) -> UIImage? {
        let frame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        let nameLabel = UILabel(frame: frame)
        nameLabel.textAlignment = .center
        nameLabel.backgroundColor = UIColor.init(hex: 0x27B1FC)
        nameLabel.textColor = .white
        nameLabel.font = UIFont.init(name: Constants.Font.ARIAL_ROUNDED_BOLD, size: 25)
        nameLabel.text = name
        UIGraphicsBeginImageContext(frame.size)
        if let currentContext = UIGraphicsGetCurrentContext() {
            nameLabel.layer.render(in: currentContext)
            let nameImage = UIGraphicsGetImageFromCurrentImageContext()
            return nameImage
        }
        return nil
    }
    
    //MARK: - UISTORYBOARD -
    
    class func mainStoryBoard() -> UIStoryboard {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        return mainStoryBoard
    }
    
    class func sideMenuStoryBoard() -> UIStoryboard {
        let sideMenuStoryBoard = UIStoryboard(name: "SideMenu", bundle: nil)
        return sideMenuStoryBoard
    }
    
    class func profileStoryBoard() -> UIStoryboard {
        let profileStoryBoard = UIStoryboard(name: "Profile", bundle: nil)
        return profileStoryBoard
    }
    
    class func fundStoryBoard() -> UIStoryboard {
        let fundStoryBoard = UIStoryboard(name: "Fund", bundle: nil)
        return fundStoryBoard
    }
    
    class func tabBarStoryBoard() -> UIStoryboard {
        let tabBarStoryBoard = UIStoryboard(name: "TabBar", bundle: nil)
        return tabBarStoryBoard
    }
    
    class func dashboardStoryBoard() -> UIStoryboard {
        let dashboardStoryBoard = UIStoryboard(name: "Dashboard", bundle: nil)
        return dashboardStoryBoard
    }
    
    class func watchlistStoryBoard() -> UIStoryboard {
        let watchlistStoryBoard = UIStoryboard(name: "Watchlist", bundle: nil)
        return watchlistStoryBoard
    }
    
    class func portfolioStoryBoard() -> UIStoryboard {
        let portfolioStoryBoard = UIStoryboard(name: "Portfolio", bundle: nil)
        return portfolioStoryBoard
    }
    
    class func updateStoryBoard() -> UIStoryboard {
        let portfolioStoryBoard = UIStoryboard(name: "Update", bundle: nil)
        return portfolioStoryBoard
    }
    
    //MARK: - Convert Param To JSON
    func convertParameter(inJSONString dict: [AnyHashable: Any]) -> String {
        var jsonString = ""
        
        defer {
        }
        
        do{
            let jsonData: Data? = try? JSONSerialization.data(withJSONObject: dict, options: [])
            if jsonData == nil {
                debugPrint("Error While converting Dictionary tp JSON String.")
                throw MyError.FoundNil("xmlDict")
            }
            else {
                jsonString = String(data: jsonData ?? Data(), encoding: .utf8) ?? ""
            }
        } catch {
            debugPrint("error getting xml string: \(error)")
        }
        return jsonString
    }
}
