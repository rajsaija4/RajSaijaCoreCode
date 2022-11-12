//
//  WebviewVC.swift

import UIKit
import SwiftyJSON
import WebKit

class WebViewVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var viewBGsub1: UIView!
    @IBOutlet weak var viewBGsub2: UIView!
    
    @IBOutlet weak var viewNavigation: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var webView: WKWebView!
    
    var isFrom:String = ""
    var objStatement = OrderObject.init([:])
    var objNews = NewsList.init([:])
    
    var strLink:String = ""
    
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
        if self.isFrom == "Account Statement" {
            let date = self.objStatement.created_at.fromUTCToLocalDateTime(OutputFormat: "yyyy/MM/dd")
            let finalDate = GlobalData.shared.formattedDateFromString(dateString: date, InputFormat: "yyyy/MM/dd", OutputFormat: "MMM dd, yyyy")
            
            self.lblTitle.text = finalDate

            self.strLink = "\(Constants.URLS.BASE_DOMAIN)/transection/detail" + "/" + "\(objUserDetail._id)" + "/" + "\(self.objStatement.id)"
        }
        else if self.isFrom == "Tax Document" {
            self.lblTitle.text = "Tax Document"
            
            self.strLink = "http://www.africau.edu/images/default/sample.pdf"
        }
        else {
            self.lblTitle.text = "News"
            
            self.strLink = self.objNews.url
        }
        
        self.webView.navigationDelegate = self
        self.updateWebView()
    }
    
    //MARK: - ACTIONS -
    
    @IBAction func btnBackClick(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDownloadClick(_ sender: UIButton) {
        if self.strLink != "" {
            GlobalData.shared.showDefaultProgress()
            self.downloadDocumentFile(StrURL: self.strLink)
        }
    }
    
    //MARK: - HELPER -
    
    func updateWebView() {
        let script: WKUserScript = WKUserScript(source: kWebViewSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(script)
        
        self.webView.navigationDelegate = self
        self.webView.backgroundColor = UIColor.white
        self.webView.isOpaque = false
        
        if let url = URL(string: self.strLink) {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }
    
    //DOWNLOAD DOCUMENT
    func downloadDocumentFile(StrURL strURL: String) {
        let fileManager = FileManager.default
        if let tDocumentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let filePath =   tDocumentDirectory.appendingPathComponent("projectName")
            
            let fileURL = URL(string: strURL)
            
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            
            let request = URLRequest(url:fileURL!)
            
            if !fileManager.fileExists(atPath: filePath.path) {
                do {
                    try fileManager.createDirectory(atPath: filePath.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    NSLog("Couldn't create document directory")
                }
            }
            NSLog("Document directory is \(filePath)")
            
            let file = fileURL?.lastPathComponent ?? ""
            let fileNameWithoutExtension = file.fileName()
            let fileExtension = file.fileExtension()
            
            var fileName = fileNameWithoutExtension
            
            if fileName == "" {
                fileName = "documentFile"
            }
            
            let timeStamp = Int(Date().timeIntervalSince1970)
            fileName = fileName + "-\(timeStamp)"
            
            if fileExtension == "" {
                fileName = fileName + "." + "pdf"
            } else {
                fileName = fileName + "." + fileExtension
            }
            
            let destinationFileUrl = filePath.appendingPathComponent("\(fileName)") // "\(fileName).pdf"
            
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    
                    if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        debugPrint(statusCode)
                        
                        DispatchQueue.main.async {
                            GlobalData.shared.hideProgress()
                            GlobalData.shared.showDarkStyleToastMesage(message: "Download completed!")
//                            let alert = UIAlertController(title: "Download completed!", message: nil, preferredStyle: .alert)
//                            self.present(alert, animated: true, completion: nil)
//
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                alert.dismiss(animated: true, completion: nil)
//                            }
                        }
                    }
                    do
                    {
                        try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    }
                    catch (let writeError)
                    {
                        debugPrint("Error creating a file \(destinationFileUrl) : \(writeError)")
                        DispatchQueue.main.async {
                            GlobalData.shared.hideProgress()
                        }
                    }
                }
                else
                {
                    debugPrint("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
                    DispatchQueue.main.async {
                        GlobalData.shared.hideProgress()
                    }
                }
            }
            task.resume()
        }
    }
}

// MARK: - WEBVIEW DELEGATE METHOD -

extension WebViewVC: WKNavigationDelegate {
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
