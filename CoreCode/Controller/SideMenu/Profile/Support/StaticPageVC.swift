//
//  StaticPageVC.swift

import UIKit
import WebKit

class StaticPageVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    var strPage: String = ""
    var strPageLink: String = ""
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViewDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - SETUP VIEW -
    
    func setupViewDetail() {
        DispatchQueue.main.async {
            self.viewBG.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub1.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            self.viewBGsub2.roundCorners(corners: [.topLeft, .topRight], radius: 27)
            
            self.viewNavigation.roundCorners(corners: [.topLeft, .topRight], radius: 27)
        }
        
        self.lblTitle.textColor = UIColor.labelTextColor
        
        //SET DATA
        self.lblTitle.text = self.strPage
        
        self.webView.navigationDelegate = self
        self.updateWebView()
    }
    
    //MARK: - HELPER -
    
    func updateWebView() {
        let script: WKUserScript = WKUserScript(source: kWebViewSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(script)
        
        self.webView.navigationDelegate = self
        self.webView.backgroundColor = UIColor.white
        self.webView.isOpaque = false
        
        if let url = URL(string: self.strPageLink) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - WEBVIEW DELEGATE METHOD -

extension StaticPageVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        GlobalData.shared.showProgressWithTitle(title: kPleaseWait)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        GlobalData.shared.hideProgress()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        GlobalData.shared.hideProgress()
    }
}
