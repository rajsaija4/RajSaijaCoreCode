//
//  ComponentBase.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 10/11/21.
//

import Foundation
import CoreGraphics


/// This class encapsulates everything both Axis, Legend and LimitLines have in common
@objc(ChartComponentBase)
open class ComponentBase: NSObject
{
    /// flag that indicates if this component is enabled or not
    @objc open var enabled = true
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0
    @objc open var xOffset = CGFloat(5.0)
    
    /// The offset this component has on the x-axis
    /// **default**: 5.0 (or 0.0 on ChartYAxis)
    @objc open var yOffset = CGFloat(5.0)
    
    public override init()
    {
        super.init()
    }

    @objc open var isEnabled: Bool { return enabled }
}