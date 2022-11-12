//
//  ExtensionFile.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit
import AVKit
import LocalAuthentication

typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)
private var kAssociationKeyMaxLength: Int = 0

extension UITextField {
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var maxLength: Int {
        get {
            if let length = objc_getAssociatedObject(self, &kAssociationKeyMaxLength) as? Int {
                return length
            } else {
                return Int.max
            }
        }
        set {
            objc_setAssociatedObject(self, &kAssociationKeyMaxLength, newValue, .OBJC_ASSOCIATION_RETAIN)
            self.addTarget(self, action: #selector(checkMaxLength), for: .editingChanged)
        }
    }
    
//    @IBInspectable var paddingLeft: CGFloat {
//        get {
//            return leftView!.frame.size.width
//        }
//        set {
//            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
//            leftView = paddingView
//            leftViewMode = .always
//        }
//    }
//
//    @IBInspectable var paddingRight: CGFloat {
//        get {
//            return rightView!.frame.size.width
//        }
//        set {
//            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: frame.size.height))
//            rightView = paddingView
//            rightViewMode = .always
//        }
//    }
    
    func isInputMethod() -> Bool {
        if let positionRange = self.markedTextRange {
            if let _ = self.position(from: positionRange.start, offset: 0) {
                return true
            }
        }
        return false
    }
    
    @objc func checkMaxLength(textField: UITextField) {
        
        guard !self.isInputMethod(), let prospectiveText = self.text,
            prospectiveText.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
//        text = prospectiveText.substring(to: maxCharIndex)
        text = String(prospectiveText[..<maxCharIndex])
        selectedTextRange = selection
    }
    
    func setLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func isEmpty()->Int{
        let whitespaceSet = CharacterSet.whitespaces
        if self.text!.trimmingCharacters(in: whitespaceSet) != "" {
            return 0
        }
        return 1
    }
    
    func isValidEmail() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .caseInsensitive)
        return regex?.firstMatch(in: self.text!, options: [], range: NSMakeRange(0, self.text!.count)) != nil
    }
    
    func isValidPhone() -> Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self.text!)
    }
    
//    func isValidPhone(phone: String) -> Bool {
//        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
//        return phoneTest.evaluate(with: phone)
//    }
    
    func setUpImage(imageName: String, on side: TextFieldImageSide) {
        let imageView = UIImageView(frame: CGRect(x: 15, y: (self.frame.size.height - 16) / 2, width: 16, height: 16))
        if #available(iOS 13.0, *) {
            if let imageWithSystemName = UIImage(systemName: imageName) {
                imageView.image = imageWithSystemName
            } else {
                imageView.image = UIImage(named: imageName)
            }
        } else {
            imageView.image = UIImage(named: imageName)
        }
        
        let imageContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 45, height: 40))
        imageContainerView.addSubview(imageView)
        
        switch side {
        case .left:
            leftView = imageContainerView
            leftViewMode = .always
        case .right:
            rightView = imageContainerView
            rightViewMode = .always
        }
    }
    
    func setInputViewDatePicker(target: Any, selector: Selector, MinDate minDate: Date, MaxDate maxDate: Date, DatePickerMode datePickerMode: UIDatePicker.Mode) {
//        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker() //UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 250)) //H:- 216
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = datePickerMode
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        self.inputView = datePicker
        
//        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
//        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
//        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
//        toolBar.setItems([cancel, flexible, barButton], animated: false)
//        self.inputAccessoryView = toolBar
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .black
        toolBar.sizeToFit()

        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true

        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
    
    var length: Int {
        #if swift(>=3.2)
            return self.count
        #else
            return self.characters.count
        #endif
    }
    
    var containsSpecialCharacter: Bool {
        let regex = ".*[^A-Za-z0-9 ,].*"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    func trim() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }

        guard let characterSpacing = characterSpacing else {return attributedString}

        attributedString.addAttribute(NSAttributedString.Key.kern, value: characterSpacing, range: NSRange(location: 0, length: attributedString.length))

        return attributedString
    }
    
    func convertStringToInt() -> Int {
        return Int(Double(self) ?? 0.0)
    }
    
    var hex: Int? {
        return Int(self, radix: 16)
    }
    
    var html2Attributed: NSAttributedString? {
        do {
            guard let data = data(using: String.Encoding.utf8) else {
                return nil
            }
            return try NSAttributedString(data: data,
                                          options: [.documentType: NSAttributedString.DocumentType.html,
                                                    .characterEncoding: String.Encoding.utf8.rawValue],
                                          documentAttributes: nil)
        } catch {
            debugPrint("error: ", error)
            return nil
        }
    }
    
    func convertToAttributedFromHTML() -> NSAttributedString? {
        var attributedText: NSAttributedString?
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
        if let data = data(using: .unicode, allowLossyConversion: true), let attrStr = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            attributedText = attrStr
        }
        return attributedText
    }
    
    func take(_ n: Int) -> String {
        guard n >= 0 else {
            fatalError("n should never negative")
        }
        let index = self.index(self.startIndex, offsetBy: min(n, self.count))
        return String(self[..<index])
    }
    
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let urlwithPercentEscapes = self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        return urlwithPercentEscapes
    }
    
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func isValidEmailString() -> Bool {
        let regex = try? NSRegularExpression(pattern: "^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$", options: .caseInsensitive)
        return regex?.firstMatch(in: self, options: [], range: NSMakeRange(0, self.count)) != nil
    }
    
    // GET FILE NAME AND EXTENSION
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }

    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
    var url : URL? {
        if let urlString = URL(string: self) {
            return urlString
        }
        return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
    }
    
    func replace(myString: String, _ index: [Int], _ newChar: Character) -> String {
        var chars = Array(myString)   // gets an array of characters
        
        var modifiedString = ""
        for i in 0 ..< index.count {
            chars[index[i]] = newChar
            modifiedString = String(chars)
        }
        
//        chars[index] = newChar
//        let modifiedString = String(chars)
        return modifiedString
    }
}

enum GradientOrientation {
    case topRightBottomLeft
    case topLeftBottomRight
    case horizontal
    case vertical
    
    var startPoint : CGPoint {
        return points.startPoint
    }
    
    var endPoint : CGPoint {
        return points.endPoint
    }
    
    var points : GradientPoints {
        get {
            switch(self) {
            case .topRightBottomLeft:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 1,y: 1))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            }
        }
    }
}

extension UILabel {
    func GetLabelHeight(labelWidth: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: labelWidth, height:CGFloat(CGFloat.greatestFiniteMagnitude)))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        return label.frame.height
    }
}

extension UITextView {
    func isEmpty()->Int{
        let whitespaceSet = CharacterSet.whitespaces
        if self.text.trimmingCharacters(in: whitespaceSet) != "" {
            return 0
        }
        return 1
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
    
    func openSettings() {
        let urlString = UIApplication.openSettingsURLString
        guard let url = URL(string: urlString) else { return }
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topViewController(controller: selected)
//            }
//        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
//        get {
//            return UIColor(cgColor: layer.borderColor!)
//        }
//        set {
//            layer.borderColor = newValue?.cgColor
//        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    //***//
    @IBInspectable var leftBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: 0.0, width: newValue, height: bounds.height))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = UIColor(cgColor: layer.borderColor!)
            line.tag = 110
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line(==lineWidth)]", options: [], metrics: metrics, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line]|", options: [], metrics: nil, views: views))
        }
    }
    
    @IBInspectable var topBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: 0.0, width: bounds.width, height: newValue))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            line.tag = 110
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line(==lineWidth)]", options: [], metrics: metrics, views: views))
        }
    }
    
    @IBInspectable var rightBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: bounds.width, y: 0.0, width: newValue, height: bounds.height))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            line.tag = 110
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "[line(==lineWidth)]|", options: [], metrics: metrics, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[line]|", options: [], metrics: nil, views: views))
        }
    }
    
    @IBInspectable var bottomBorderWidth: CGFloat {
        get {
            return 0.0   // Just to satisfy property
        }
        set {
            let line = UIView(frame: CGRect(x: 0.0, y: bounds.height, width: bounds.width, height: newValue))
            line.translatesAutoresizingMaskIntoConstraints = false
            line.backgroundColor = borderColor
            line.tag = 110
            self.addSubview(line)
            
            let views = ["line": line]
            let metrics = ["lineWidth": newValue]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[line]|", options: [], metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[line(==lineWidth)]|", options: [], metrics: metrics, views: views))
        }
    }
    
    func removeborder() {
          for view in self.subviews {
               if view.tag == 110  {
                    view.removeFromSuperview()
               }
               
          }
    }
    
    func addDashedBorder(color: UIColor) {
        let color = color.cgColor
        self.layoutIfNeeded()
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [4,2]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 10).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func applyGradient(colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addshadow(top: Bool,
                   left: Bool,
                   bottom: Bool,
                   right: Bool,
                   shadowRadius: CGFloat) {
        
        self.layer.masksToBounds = false
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 0.6
        self.layer.shadowColor = UIColor.init(hex: 0x707070).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        
        let path = UIBezierPath()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var viewWidth = self.frame.width
        var viewHeight = self.frame.height
        
        // here x, y, viewWidth, and viewHeight can be changed in
        // order to play around with the shadow paths.
        if (!top) {
            y+=(shadowRadius+1)
        }
        if (!bottom) {
            viewHeight-=(shadowRadius+1)
        }
        if (!left) {
            x+=(shadowRadius+1)
        }
        if (!right) {
            viewWidth-=(shadowRadius+1)
        }
        // selecting top most point
        path.move(to: CGPoint(x: x, y: y))
        // Move to the Bottom Left Corner, this will cover left edges
        /*
         |☐
         */
        path.addLine(to: CGPoint(x: x, y: viewHeight))
        // Move to the Bottom Right Corner, this will cover bottom edge
        /*
         ☐
         -
         */
        path.addLine(to: CGPoint(x: viewWidth, y: viewHeight))
        // Move to the Top Right Corner, this will cover right edge
        /*
         ☐|
         */
        path.addLine(to: CGPoint(x: viewWidth, y: y))
        // Move back to the initial point, this will cover the top edge
        /*
         _
         ☐
         */
        path.close()
        self.layer.shadowPath = path.cgPath
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            clipsToBounds = true
            layer.cornerRadius = radius
            layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
        } else {
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
    
//    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
//        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }
    
    func createShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
//        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath

        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func drawShadow() {
        self.layer.borderColor = UIColor.init(hex: 0x707070).cgColor
        self.layer.borderWidth = 0.3
        
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.6
        self.layer.shadowColor = UIColor.init(hex: 0x707070).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
    }
    
    func createButtonShadow(BorderColor borderColor: UIColor, ShadowColor shadowColor: UIColor) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = 0.3
        
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.6
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
    }
    
    func addBottomShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1 //4
        self.layer.shadowOpacity = 0.6 //1
        self.layer.shadowColor = UIColor.init(hex: 0x000000, a: 0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height: 3)
        self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: self.bounds.maxY - self.layer.shadowRadius,
                                                          width: self.bounds.width,
                                                          height: self.layer.shadowRadius)).cgPath
    }
    
    func addTopShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.6
        self.layer.shadowColor = UIColor.init(hex: 0x000000, a: 0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height: 2)
        self.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                          y: self.bounds.minY - self.layer.shadowRadius,
                                                          width: self.bounds.width,
                                                          height: self.layer.shadowRadius)).cgPath
    }
    
    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
}

extension UITabBarController {
    func increaseBadge(indexOfTab: Int, num: String) {
        let tabItem = tabBar.items![indexOfTab]
        tabItem.badgeValue = num
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage/100, 1.0),
                           green: min(green + percentage/100, 1.0),
                           blue: min(blue + percentage/100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
    
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }
    
    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init?(hexString: String) {
        guard let hex = hexString.hex else {
            return nil
        }
        self.init(hex: hex)
    }
    
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexFormatted: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted = String(hexFormatted.dropFirst())
        }
        
        assert(hexFormatted.count == 6, "Invalid hex code used.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    func hexStringToUIColor(hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIImage {
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func fixOrientationForChat() -> UIImage? {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }

        UIGraphicsBeginImageContext(self.size)
        self.draw(in: CGRect(origin: .zero, size: self.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    /**
     Returns image with size 1x1px of certain color.
     */
    class func imageWithColor(color : UIColor) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
    
    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
        
        self.init(data: imageData)
    }
}

extension UIInputView : UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
    
}

extension Date {
    
    var elapsedTime: String {
        
        let fromDate = self
        
        let toDate = Date()
        
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minutes
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "Just now"
    }
    
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    var startOfWeek: Date {
        let gregorian = Calendar(identifier: .gregorian)
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 1, to: sunday!)!
    }
    
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func getFormattedDate(string: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss +zzzz" // This formate is input formated .

        let formateDate = dateFormatter.date(from:"2018-02-02 06:50:16 +0000")!
        dateFormatter.dateFormat = "dd-MM-yyyy" // Output Formated

        print ("Print :\(dateFormatter.string(from: formateDate))")//Print :02-02-2018
        return dateFormatter.string(from: formateDate)
    }
    
    func string(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    mutating func changeDays(by days: Int) {
        self = Calendar.current.date(byAdding: .day, value: days, to: self)!
    }
    
    static func getSelectedDateFromString(_ str:String)-> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: str) ?? Date()
        return date
    }
    
    static func getDateOnly() -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        return date
    }
    
    func getDateOnly() -> String! {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: self)
        return date
    }
}

extension Dictionary {

   func removeNull() -> Dictionary {
       let mainDict = NSMutableDictionary.init(dictionary: self)
       for _dict in mainDict {
           if _dict.value is NSNull {
               mainDict.removeObject(forKey: _dict.key)
           }
           if _dict.value is NSDictionary {
               let test1 = (_dict.value as! NSDictionary).filter({ $0.value is NSNull }).map({ $0 })
               let mutableDict = NSMutableDictionary.init(dictionary: _dict.value as! NSDictionary)
               for test in test1 {
                   mutableDict.removeObject(forKey: test.key)
               }
               mainDict.removeObject(forKey: _dict.key)
               mainDict.setValue(mutableDict, forKey: _dict.key as? String ?? "")
           }
           if _dict.value is NSArray {
               let mutableArray = NSMutableArray.init(object: _dict.value)
               for (index,element) in mutableArray.enumerated() where element is NSDictionary {
                   let test1 = (element as! NSDictionary).filter({ $0.value is NSNull }).map({ $0 })
                   let mutableDict = NSMutableDictionary.init(dictionary: element as! NSDictionary)
                   for test in test1 {
                       mutableDict.removeObject(forKey: test.key)
                   }
                   mutableArray.replaceObject(at: index, with: mutableDict)
               }
               mainDict.removeObject(forKey: _dict.key)
               mainDict.setValue(mutableArray, forKey: _dict.key as? String ?? "")
           }
       }
       return mainDict as! Dictionary<Key, Value>
   }
}

extension CALayer {
    func applySketchShadow(color: UIColor = .black,
                     opacity: Float = 0.5,
                     x: CGFloat = 0,
                     y: CGFloat = 2,
                     blur: CGFloat = 4,
                     spread: CGFloat = 0,
                     path: UIBezierPath? = nil) {
        shadowColor = color.cgColor
        shadowOpacity = opacity
        shadowRadius = blur / 2
        if let path = path {
            if spread == 0 {
                shadowOffset = CGSize(width: x, height: y)
            } else {
                let scaleX = (path.bounds.width + (spread * 2)) / path.bounds.width
                let scaleY = (path.bounds.height + (spread * 2)) / path.bounds.height

                path.apply(CGAffineTransform(translationX: x + -spread, y: y + -spread).scaledBy(x: scaleX, y: scaleY))
                shadowPath = path.cgPath
            }
        } else {
            shadowOffset = CGSize(width: x, height: y)
            if spread == 0 {
                shadowPath = nil
            } else {
                let dx = -spread
                let rect = bounds.insetBy(dx: dx, dy: dx)
                shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
}

extension NSMutableAttributedString {
    func setColor(color: UIColor, forText stringValue: String) {
        let range: NSRange = self.mutableString.range(of: stringValue, options: .caseInsensitive)
        if range.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}

extension UITableView {
    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension TimeZone {
    static let utc = TimeZone(abbreviation: "UTC")
}

extension LAContext {
    enum BiometricType: String {
        case none
        case touchID
        case faceID
    }

    var biometricType: BiometricType {
        var error: NSError?

        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Capture these recoverable error through fabric
            return .none
        }

        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        }

        return self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
    }
}

//***** FOR TAKE SCREENSHOT *****//
extension UIApplication {

    func getKeyWindow() -> UIWindow? {
        if #available(iOS 13, *) {
            return windows.first { $0.isKeyWindow }
        } else {
            return keyWindow
        }
    }

    func makeSnapshot() -> UIImage? { return getKeyWindow()?.layer.makeSnapshot() }
}


extension CALayer {
    func makeSnapshot() -> UIImage? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(frame.size, false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        return screenshot
    }
}

extension UIView {
    func makeSnapshot() -> UIImage? {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: frame.size)
            return renderer.image { _ in drawHierarchy(in: bounds, afterScreenUpdates: true) }
        } else {
            return layer.makeSnapshot()
        }
    }
}

extension UIImage {
    convenience init?(snapshotOf view: UIView) {
        guard let image = view.makeSnapshot(), let cgImage = image.cgImage else { return nil }
        self.init(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }
    
    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}

extension UINavigationController {
    func popToViewController(ofClass: AnyClass, animated: Bool = true) {
        if let controller = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
            popToViewController(controller, animated: animated)
        }
    }
}

extension UISearchBar {
    func setupSearchBar(background: UIColor = .white, inputText: UIColor = .black, placeholderText: UIColor = .gray, image: UIColor = .black) {

        self.searchBarStyle = .minimal

        self.barStyle = .default

        // IOS 12 and lower:
        for view in self.subviews {

            for subview in view.subviews {
                if subview is UITextField {
                    if let textField: UITextField = subview as? UITextField {

                        // Background Color
                        textField.backgroundColor = background

                        //   Text Color
                        textField.textColor = inputText

                        //  Placeholder Color
                        textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderText])

                        //  Default Image Color
                        if let leftView = textField.leftView as? UIImageView {
                            leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                            leftView.tintColor = image
                        }

                        let backgroundView = textField.subviews.first
                        backgroundView?.backgroundColor = background
                        backgroundView?.layer.cornerRadius = 10.5
                        backgroundView?.layer.masksToBounds = true
                    }
                }
            }
        }

        // IOS 13 only:
        if let textField = self.value(forKey: "searchField") as? UITextField {
            // Background Color
            textField.backgroundColor = background

            //   Text Color
            textField.textColor = inputText

            //  Placeholder Color
            textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeholderText])

            //  Default Image Color
            if let leftView = textField.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = image
            }
        }
    }
}

extension UIButton {
    func hasImage(named imageName: String, for state: UIControl.State) -> Bool {
        guard let buttonImage = image(for: state), let namedImage = UIImage(named: imageName) else {
            return false
        }
        
        return buttonImage.pngData() == namedImage.pngData()
    }
}

extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element { reduce(.zero, +) }
}

extension String {
    func chunkFormatted(withChunkSize chunkSize: Int = 4,
                        withSeparator separator: Character = "-") -> String {
        return self.filter { $0 != separator }.chunk(n: chunkSize)
            .map{ String($0) }.joined(separator: String(separator))
    }
    
    func customStringFormatting(of str: String) -> String {
        return str.chunk(n: 4)
            .map{ String($0) }.joined(separator: "-")
    }
}

extension Collection {
    public func chunk(n: Int) -> [SubSequence] {
        var res: [SubSequence] = []
        var i = startIndex
        var j: Index
        while i != endIndex {
            j = index(i, offsetBy: n, limitedBy: endIndex) ?? endIndex
            res.append(self[i..<j])
            i = j
        }
        return res
    }
}

extension String {
    func fromUTCToLocalDateTime(OutputFormat outputFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"//"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        var formattedString = self.replacingOccurrences(of: "Z", with: "")
        if let lowerBound = formattedString.range(of: ".")?.lowerBound {
            formattedString = "\(formattedString[..<lowerBound])"
        }

        guard let date = dateFormatter.date(from: formattedString) else {
            return self
        }

        dateFormatter.dateFormat = outputFormat//"EEE, MMM dd, yyyy - h:mm a"
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date)
    }
    
    func separate(every: Int, with separator: String) -> String {
        return String(stride(from: 0, to: Array(self).count, by: every).map {
            Array(Array(self)[$0..<min($0 + every, Array(self).count)])
            }.joined(separator: separator))
    }
    
    func codeFormat() -> String {
        let newStr = NSMutableString()
        for i in 0..<self.count {
//            if (i > 0 && i % 4 == 0){
//                newStr.append(" ")
//            }
            if self.count == 14
            {
                if i == 4 || i == 10 { // || i == 7
                    newStr.append(" ")
                }
            }
            else if self.count == 15
            {
                if i == 4 || i == 10 {
                    newStr.append(" ")
                }
            }
            var c = (self as NSString).character(at: i)
            newStr.append(NSString(characters: &c, length: 1) as String)
        }
        return newStr as String
    }
    
    func capitalize() -> String {
        let arr = self.split(separator: " ").map{String($0)}
        var result = [String]()
        for element in arr {
            result.append(String(element.uppercased().first ?? " ") + element.suffix(element.count-1))
        }
        return result.joined(separator: " ")
    }
}

//*** FOR GENERATE QR CODE WITH CUSTOM LOGO ***//
extension CIImage {
    // Inverts the colors and creates a transparent image by converting the mask to alpha.
    // Input image should be black and white.
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }
 
    // Inverts the colors.
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }
 
        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }
 
    // Converts all black to transparent.
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }
 
    // Applies the given color as a tint color.
    func tinted(using color: UIColor) -> CIImage? {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }
 
        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage
 
        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)
 
        return filter.outputImage!
    }
}

extension URL {
    // Creates a QR code for the current URL in the given color.
    func qrImage(using color: UIColor) -> CIImage? {
        return qrImage?.tinted(using: color)
    }
 
    // Returns a black and white QR code for this URL.
    var qrImage: CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")
 
        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        return qrFilter.outputImage?.transformed(by: qrTransform)
    }
}

extension UIImage {
    // place the imageView inside a container view
    // - parameter superView: the containerView that you want to place the Image inside
    // - parameter width: width of imageView, if you opt to not give the value, it will take default value of 100
    // - parameter height: height of imageView, if you opt to not give the value, it will take default value of 30
    func addToCenter(of superView: UIView, width: CGFloat = 100, height: CGFloat = 30) {
        let overlayImageView = UIImageView(image: self)
        
        overlayImageView.translatesAutoresizingMaskIntoConstraints = false
        overlayImageView.contentMode = .scaleAspectFit
        superView.addSubview(overlayImageView)
        
        let centerXConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerX, relatedBy: .equal, toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: overlayImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
        let height = NSLayoutConstraint(item: overlayImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 30)
        let centerYConst = NSLayoutConstraint(item: overlayImageView, attribute: .centerY, relatedBy: .equal, toItem: superView, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([width, height, centerXConst, centerYConst])
    }
    
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: .lineLength64Characters)
    }

    func jpeg(_ jpegQuality: JPEGQualityType) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension Array {
    func containsObject(object: [String : Any]?) -> Bool {
        var isAlready: Bool = false
        
        for obj in self {
            if ((obj as? [String : Any]) != nil) == (object != nil) {
                isAlready = true
            }
        }
        return isAlready
    }
}

extension NSArray {
    func unique<T:Hashable>(map: ((Element) -> (T))) -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(map(value)) {
                set.insert(map(value))
                arrayOrdered.append(value)
            }
        }
        
        return arrayOrdered
    }
}

extension Date {
    // Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    // Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    // Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    // Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    // Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    // Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    // Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    // Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return "Just Now"
    }

    func offsetLong(from date: Date) -> String {
        if years(from: date)   > 0 { return years(from: date) > 1 ? "\(years(from: date)) years ago" : "\(years(from: date)) year ago" }
        if months(from: date)  > 0 { return months(from: date) > 1 ? "\(months(from: date)) months ago" : "\(months(from: date)) month ago" }
        if weeks(from: date)   > 0 { return weeks(from: date) > 1 ? "\(weeks(from: date)) weeks ago" : "\(weeks(from: date)) week ago"   }
        if days(from: date)    > 0 { return days(from: date) > 1 ? "\(days(from: date)) days ago" : "\(days(from: date)) day ago" }
        if hours(from: date)   > 0 { return hours(from: date) > 1 ? "\(hours(from: date)) hours ago" : "\(hours(from: date)) hour ago"   }
        if minutes(from: date) > 0 { return minutes(from: date) > 1 ? "\(minutes(from: date)) minutes ago" : "\(minutes(from: date)) minute ago" }
        if seconds(from: date) > 0 { return seconds(from: date) > 1 ? "\(seconds(from: date)) seconds ago" : "\(seconds(from: date)) second ago" }
        return "Just Now"
    }
}

//CONVERT STRING ARRAY TO DOUBLE/FLOAT ARRAY
extension Collection where Iterator.Element == String {
    var convertToDouble: [Double] {
        return compactMap{ Double($0) }
    }
    var convertToFloat: [Float] {
        return compactMap{ Float($0) }
    }
    //Example How to Use
//    let String_Array = ["1.5","2.3","3.7","4.5"]       // ["1.5", "2.3", "3.7", "4.5"]
//    let Double_Array = String_Array.convertToDouble    // [1.5, 2.3, 3.7, 4.5]
//    let Float_Array = String_Array.convertToFloat.     // [1.5, 2.3, 3.7, 4.5]
}

//CONVERT DOUBLE ARRAY TO STRING ARRAY
extension Collection where Iterator.Element == Double {
    var convertToString: [String] {
        return compactMap{ String($0) }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension Double {
    // Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
    
    var cleanWithZero: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.2f", self)
    }
}

extension Int {
    func secondsToTime() -> String {
        let (h,m,s) = (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
        
        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        let s_string =  s < 10 ? "0\(s)" : "\(s)"
        
        return "\(h_string):\(m_string):\(s_string)"
    }
}

public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}

extension Formatter {
    static let number = NumberFormatter()
}
extension Locale {
    static let englishUS: Locale = .init(identifier: "en_US")
    static let frenchFR: Locale = .init(identifier: "fr_FR")
    static let portugueseBR: Locale = .init(identifier: "pt_BR")
    // ... and so on
}
extension Numeric {
    func formatted(with groupingSeparator: String? = nil, style: NumberFormatter.Style, locale: Locale = .current) -> String {
        Formatter.number.locale = locale
        Formatter.number.numberStyle = style
        if let groupingSeparator = groupingSeparator {
            Formatter.number.groupingSeparator = groupingSeparator
        }
        return Formatter.number.string(for: self) ?? ""
    }
    // Localized
    var currency:   String { formatted(style: .currency) }
    // Fixed locales
    var currencyUS: String { formatted(style: .currency, locale: .englishUS) }
    var currencyFR: String { formatted(style: .currency, locale: .frenchFR) }
    var currencyBR: String { formatted(style: .currency, locale: .portugueseBR) }
    // ... and so on
    var calculator: String { formatted(style: .decimal) }
}


func convertThousand(value:Double) -> String {
    return Double(getTwoDecimal(value: value))?.calculator ?? "0.0"
}

func getTwoDecimal(value:Double) -> String {
    return value.clean
}

//******//
//extension Array where Element: Hashable {
//    func difference(from other: [Element]) -> [Element] {
//        let thisSet = Set(self)
//        let otherSet = Set(other)
//        return Array(thisSet.symmetricDifference(otherSet))
//    }
//}
//***********************//
