//
//  BacktoLoginVC.swift
//  Prospuh
//
//  Created by RAJ J SAIJA on 19/07/22.
//

import UIKit

class BacktoLoginVC: UIViewController {
    
//MARK: - Outlets and variable

    @IBOutlet weak var lblWelcome: UILabel!
    
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblWelcome.text = "Welcome To Prospuh \(objUserDetail.givenName) ! "
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPressBacktoLoginbtnTap(_ sender: UIButton) {
        
        let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navController = UINavigationController.init(rootViewController: controller)
        appDelegate.window?.rootViewController = navController
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
