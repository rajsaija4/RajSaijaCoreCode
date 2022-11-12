//
//  ViewOrderPayment.swift
//  BYT
//
//  Created by RAJ J SAIJA on 24/02/22.
//

import Foundation

class CustomerPayment {
    var customerId = ""
    var customerImage = ""
    var arrAmount:[Double] = []
    var arrItems:[CustomerArrItems] = []
    
    init(customerId:String,customerImage:String, arrAmount:[Double], arrItems:[CustomerArrItems]){
        self.customerId = customerId
        self.customerImage = customerImage
        self.arrAmount = arrAmount
        self.arrItems = arrItems
    }
}

class CustomerArrItems {
    var itemName = ""
    var itemQuentity = 0
    
    init(itemName:String,itemQuentity:Int){
        self.itemQuentity = itemQuentity
        self.itemName = itemName
        
    }
}
