//
//  BaseVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit

class BaseVC: UIViewController {

    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.white, .font : UIFont.init(name: Constants.Font.YUGOTHIC_UI_SEMIBOLD, size: 18)!]
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
