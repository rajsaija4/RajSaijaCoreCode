//
//  NoPopUpTextField.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class NoPopUpTextField: UITextField {

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
