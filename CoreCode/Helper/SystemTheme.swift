//
//  SystemTheme.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 25/10/21.
//

import Foundation
import UIKit

//ASSETS COLOR
enum AssetsColor : String {
    case background
    case border
    case textfieldTint
    case documentBG
    case tabBar
    case deleteAlertBorder
    case editAlertBorder
    case tabBarTint
    case tabBarSelected
}

extension UIColor {
    static func appColor(_ name: AssetsColor) -> UIColor? {
        return UIColor(named: name.rawValue)
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    static var iqKeyboardToolbarPlaceholder: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0xFFFFFF, a: 0.7) :
                UIColor.init(hex: 0x000000, a: 0.7)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0x000000, a: 0.7)
        }
    }
    
    static var indicatorSelected: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x000000)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x000000)
        }
    }
    
    static var indicatorNormal: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0xFFFFFF, a: 0.3) :
                UIColor.init(hex: 0x000000, a: 0.3)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0x000000, a: 0.3)
        }
    }
    
    static var DontHaveAnAccount: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x757272)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x757272)
        }
    }
    
    static var textFieldTextColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x000000)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x000000)
        }
    }
    
    static var textViewTextColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x000000)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x000000)
        }
    }
    
    static var labelTextColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x000000)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x000000)
        }
    }
    
    static var taxExemptionDescription: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0xACACAC)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0xACACAC)
        }
    }
    
    static var taxExemptionAgreeTerms: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x8B8A8A)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x8B8A8A)
        }
    }
    
    static var btnChartColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x919191)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x919191)
        }
    }
    
    static var tblMarketDepthHeaderBG: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0x474747, a: 1.0) :
                UIColor.init(hex: 0x81CF01, a: 0.17)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0x81CF01, a: 0.17)
        }
    }
    
    static var tblMarketDepthContent: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0x676767)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x676767)
        }
    }
    
    static var tblMarketDepthEvenCellBG: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0xFFFFFF, a: 0.28) :
                UIColor.clear
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.clear
        }
    }
    
    static var viewThemeColorWithOpacity: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0x81CF01, a: 1.0) :
                UIColor.init(hex: 0x81CF01, a: 0.17)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0x81CF01, a: 0.17)
        }
    }
    
    static var cellSelectionColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0xFFFFFF, a: 0.19) :
                UIColor.init(hex: 0x81CF01, a: 0.19)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0x81CF01, a: 0.19)
        }
    }
    
    static var searchTextfieldBG: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor.init(hex: 0xF5F5F5, a: 0.42) :
                UIColor.init(hex: 0xF5F5F5, a: 1.0)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor.init(hex: 0xF5F5F5, a: 1.0)
        }
    }
    
    static var tblPortfolioContent: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xFFFFFF) :
                UIColor(rgb: 0xA7A7A7)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0xA7A7A7)
        }
    }
    
    static var tblStatementContent: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                // Return one of two colors depending on light or dark mode
                return traits.userInterfaceStyle == .dark ?
                UIColor(rgb: 0xE4E4E4) :
                UIColor(rgb: 0x676767)
            }
        } else {
            // Same old color used for iOS 12 and earlier
            return UIColor(rgb: 0x676767)
        }
    }
}
