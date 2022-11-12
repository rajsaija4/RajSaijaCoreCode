//
//  ContentSizedTableView.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class ContentSizedTableView: UITableView {

    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
