//
//  FilterSelected.swift
//  BYT
//
//  Created by 21Twelve Interactive on 26/10/21.
//

import Foundation
class FilterSelected {
    
    var index:IndexPath = IndexPath(row: 0, section: 0)
    var selected:Bool = true
    
    init(index:IndexPath,selected:Bool) {
        self.index = index
        self.selected = selected
    }
}
