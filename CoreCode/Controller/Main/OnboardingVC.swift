//
//  OnboardingVC.swift
//  Prospuh
//
//  Created by 21Twelve Interactive on 22/10/21.
//

import UIKit
import AdvancedPageControl
import SDWebImage

struct OnboardingObject {
    var image: UIImage
    var gifName: String
    var title: String
    var description: String
}

class OnboardingVC: BaseVC {

    //MARK: - PROPERTIES & OUTLETS -
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var pageControl: AdvancedPageControlView!
    @IBOutlet weak var btnSkip: UIButton!
    
    let reuseIdentifier = "BoardingCell"

    var arrOnboarding = [
        OnboardingObject(image: #imageLiteral(resourceName: "onboarding_bg"), gifName: "onboarding_first", title: "Welcome to Prospuh", description: "Get signed up in minutes, make trades in seconds"),
        OnboardingObject(image: #imageLiteral(resourceName: "onboarding_bg"), gifName: "onboarding_second", title: "Invest From $5", description: "You can buy as little as 0.00001 shares with a minimum of $5. Now you can support companies you believe in and own them"),
        OnboardingObject(image: #imageLiteral(resourceName: "onboarding_bg"), gifName: "onboarding_third", title: "Safety you Deserve", description: "Prospuh and its partners are regulated. Your account is protected for up to USD 500,000 by the SIPC"),
    ]
    
    var currentPage: Int = 0
    
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
        self.btnSkip.setTitle("SKIP", for: [])
        self.btnSkip.setTitleColor(UIColor.indicatorSelected, for: [])
        
        self.pageControl.drawer = ExtendedDotDrawer(numberOfPages: self.arrOnboarding.count,
                                                    height: 8.0,
                                                    width: 8.0,
                                                    space: 16.0,
                                                    indicatorColor: UIColor.indicatorSelected,
                                                    dotsColor: UIColor.indicatorNormal,
                                                    isBordered: false,
                                                    borderWidth: 0.0,
                                                    indicatorBorderColor: .clear,
                                                    indicatorBorderWidth: 0.0)
    }
    
    //MARK: - HELPER -
    
    //MARK: - ACTIONS -
    
    @IBAction func btnSkipClick(_ sender: UIButton) {
        if self.btnSkip.titleLabel?.text == "SKIP" {
//            if self.arrOnboarding.count - 1 > currentPage {
//                collectionView.scrollToNextItem()
//            }
            defaults.set(true, forKey: isOnBoradingScreenDisplayed)
            defaults.synchronize()

            let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        } else {
            defaults.set(true, forKey: isOnBoradingScreenDisplayed)
            defaults.synchronize()

            let controller = GlobalData.mainStoryBoard().instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let navController = UINavigationController.init(rootViewController: controller)
            appDelegate.window?.rootViewController = navController
        }
    }
}

//MARK: - UICOLLECTIONVIEW DATASOURCE & DELEGATE METHOD -

extension OnboardingVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrOnboarding.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! BoardingCell
                
        cell.imgBackground.image = self.arrOnboarding[indexPath.item].image
        cell.imgGIF.loadGif(name: self.arrOnboarding[indexPath.item].gifName)
        cell.lblTitle.text = self.arrOnboarding[indexPath.item].title
        cell.lblDescription.text = self.arrOnboarding[indexPath.item].description
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

//MARK: - UISCROLLVIEW DELEGATE -

extension OnboardingVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width

        self.pageControl.setPage(Int(round(offSet / width)))
        self.pageControl.setPageOffset(offSet / width)

        currentPage = Int(round(offSet / width))

        if currentPage == self.arrOnboarding.count - 1 {
            self.btnSkip.setTitle("NEXT", for: [])
        } else {
            self.btnSkip.setTitle("SKIP", for: [])
        }
    }
    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
//            if visibleIndexPath.row == self.arrOnboarding.count - 1 {
//                self.btnSkip.isHidden = true
//                self.btnSkip.setTitle("NEXT", for: [])
//            } else {
//                self.btnSkip.isHidden = false
//                self.btnSkip.setTitle("SKIP", for: [])
//            }
//
//            currentPage = visibleIndexPath.row
//            self.pageControl.setPage(currentPage)
////            self.pageControl.currentPage = visibleIndexPath.row
//        }
//    }
}
