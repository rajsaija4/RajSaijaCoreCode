//
//  UIFontSizeUpdate.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

extension UITextField {
    open override func awakeFromNib() {
        if Constants.DeviceType.IS_IPHONE_5 {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! - 1)
        }
//        if Constants.DeviceType.IS_IPHONE_6 {
//            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
//        }
        if Constants.DeviceType.IS_IPHONE_6P {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_X {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
        }
        if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 3)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        //IPAD
        if Constants.DeviceType.IS_IPAD_PRO {//1024
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        if Constants.DeviceType.IS_IPAD {//1080
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 5)
        }
        if Constants.DeviceType.IS_IPAD_AIR_3rdGEN {//1112
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 6)
        }
        if Constants.DeviceType.IS_IPAD_AIR_4thGEN {//1180
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_2ndGEN {//1194
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_4thGEN {//1366
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 8)
        }
    }
}

extension UITextView {
    open override func awakeFromNib() {
        if Constants.DeviceType.IS_IPHONE_5 {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! - 1)
        }
//        if Constants.DeviceType.IS_IPHONE_6 {
//            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
//        }
        if Constants.DeviceType.IS_IPHONE_6P {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_X {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
        }
        if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 3)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        //IPAD
        if Constants.DeviceType.IS_IPAD_PRO {//1024
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        if Constants.DeviceType.IS_IPAD {//1080
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 5)
        }
        if Constants.DeviceType.IS_IPAD_AIR_3rdGEN {//1112
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 6)
        }
        if Constants.DeviceType.IS_IPAD_AIR_4thGEN {//1180
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_2ndGEN {//1194
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_4thGEN {//1366
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 8)
        }
    }
}

extension UILabel {
    open override func awakeFromNib() {
        if Constants.DeviceType.IS_IPHONE_5 {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! - 1)
        }
//        if Constants.DeviceType.IS_IPHONE_6 {
//            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
//        }
        if Constants.DeviceType.IS_IPHONE_6P {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_X {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 1)
        }
        if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 3)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        //IPAD
        if Constants.DeviceType.IS_IPAD_PRO {//1024
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 4)
        }
        if Constants.DeviceType.IS_IPAD {//1080
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 5)
        }
        if Constants.DeviceType.IS_IPAD_AIR_3rdGEN {//1112
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 6)
        }
        if Constants.DeviceType.IS_IPAD_AIR_4thGEN {//1180
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_2ndGEN {//1194
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_4thGEN {//1366
            self.font = UIFont(name: (self.font?.fontName)!, size: (self.font?.pointSize)! + 8)
        }
    }
}

extension UIButton {
    open override func awakeFromNib() {
        if Constants.DeviceType.IS_IPHONE_5 {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! - 1)
        }
//        if Constants.DeviceType.IS_IPHONE_6 {
//            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 1)
//        }
        if Constants.DeviceType.IS_IPHONE_6P {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_X {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 1)
        }
        if Constants.DeviceType.IS_IPHONE_11_PRO_MAX {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 3)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 2)
        }
        if Constants.DeviceType.IS_IPHONE_12_PRO_MAX {
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 4)
        }
        //IPAD
        if Constants.DeviceType.IS_IPAD_PRO {//1024
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 4)
        }
        if Constants.DeviceType.IS_IPAD {//1080
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 5)
        }
        if Constants.DeviceType.IS_IPAD_AIR_3rdGEN {//1112
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 6)
        }
        if Constants.DeviceType.IS_IPAD_AIR_4thGEN {//1180
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_2ndGEN {//1194
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 7)
        }
        if Constants.DeviceType.IS_IPAD_PRO_4thGEN {//1366
            self.titleLabel?.font = UIFont(name: (self.titleLabel!.font?.fontName)!, size: (self.titleLabel!.font?.pointSize)! + 8)
        }
    }
}
