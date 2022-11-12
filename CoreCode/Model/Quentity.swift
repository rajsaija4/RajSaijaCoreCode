//
//  Quentity.swift
//  BYT
//
//  companyName on 26/10/21.
//

import Foundation

class Quentity {
    
    var index:IndexPath = IndexPath(row: 0, section: 0)
    var count:Int = 0
    
    init(index:IndexPath,count:Int) {
        self.index = index
        self.count = count
    }
}
