//
//  SelfSizedCollectionView.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class SelfSizedCollectionView: UICollectionView {

    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let s = self.collectionViewLayout.collectionViewContentSize
        return CGSize(width: max(s.width, 1), height: max(s.height,1))
    }
}
