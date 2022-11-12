//
//  CustomSegmentControl.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class CustomSegmentControl: UISegmentedControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selectedColor = UIColor.init(hex: 0xF92D34)
        let normalFont = UIFont(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 13.0)
        let selectedFont = UIFont(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 14.0)
        
        setTitleTextAttributes([.foregroundColor: UIColor.black,
                                .font: normalFont!], for: .normal)
        setTitleTextAttributes([.foregroundColor: UIColor.white,
                                .font: selectedFont!], for: .selected)
        setTitleTextAttributes([.foregroundColor: UIColor.black,
                                .font: normalFont!], for: .highlighted)
        
        layer.masksToBounds = true
        
        if #available(iOS 13.0, *) {
            selectedSegmentTintColor = selectedColor
        } else {
            tintColor = selectedColor
        }
        
        backgroundColor = UIColor.white
        
        //corner radius
//        let cornerRadius = bounds.height / 2 //NOTE:- IF NEED TO SET ROUNDED RADIUS
        let maskedCorners: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        //background
        clipsToBounds = true
        layer.cornerRadius = 8 //cornerRadius
        if #available(iOS 11.0, *) {
            layer.maskedCorners = maskedCorners
        } else {
            // Fallback on earlier versions
        }
        
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex),
            let foregroundImageView = subviews[foregroundIndex] as? UIImageView {
            foregroundImageView.image = UIImage()
            foregroundImageView.clipsToBounds = true
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.backgroundColor = selectedColor
            
//            foregroundImageView.layer.cornerRadius = bounds.height / 2 + 5 //NOTE:- IF NEED TO SET INNERVIEW ROUNDED
            foregroundImageView.layer.cornerRadius = 12
            if #available(iOS 11.0, *) {
                foregroundImageView.layer.maskedCorners = maskedCorners
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect.init(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return image
    }
}
