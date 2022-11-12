//
//  DateValueFormatter.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 10/11/21.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, AxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
