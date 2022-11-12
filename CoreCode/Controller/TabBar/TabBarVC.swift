//
//  TabBarVC.swift
//  
import UIKit

class TabBarVC: UITabBarController, UITabBarControllerDelegate {

    //MARK: - PROPERTIES & OUTLETS -
    
    var dashboardTab = UITabBarItem()
    var watchlistTab = UITabBarItem()
    var marketTab = UITabBarItem()
//    var searchTab = UITabBarItem()
    var portfolioTab = UITabBarItem()
    
//    let customTabBarView: UIView = {
//        let view = UIView(frame: .zero)
//
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 27
//        view.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
//        view.clipsToBounds = true
//
//        view.layer.masksToBounds = false
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSize(width: 0, height: -8.0)
//        view.layer.shadowOpacity = 0.12
//        view.layer.shadowRadius = 10.0
//        return view
//    }()
    
    //MARK: - VIEWCONTROLLER LIFE CYCLE -
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        UITabBar.appearance().barTintColor = UIColor.purple
        self.delegate = self
        
        self.addCustomTabBarView()
        self.hideTabBarBorder()
        self.setupTabBar()
        
        self.dashboardTab  = (self.tabBar.items?[0])!
        self.watchlistTab  = (self.tabBar.items?[1])!
        self.marketTab     = (self.tabBar.items?[2])!
//        self.searchTab     = (self.tabBar.items?[3])!
        self.portfolioTab  = (self.tabBar.items?[3])!
        
        self.dashboardTab.title = ""
        self.dashboardTab.image = UIImage(named:"ic_tab_dashboard_0")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(r: 103, g: 103, b: 103))
        self.dashboardTab.selectedImage = UIImage(named:"ic_tab_dashboard_1")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.white)
        
        self.watchlistTab.title = ""
        self.watchlistTab.image = UIImage(named:"ic_tab_watchlist_0")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(r: 103, g: 103, b: 103))
        self.watchlistTab.selectedImage = UIImage(named:"ic_tab_watchlist_1")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.white)
        
        self.marketTab.title = ""
        self.marketTab.image = UIImage(named:"ic_tab_market_0")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(r: 103, g: 103, b: 103))
        self.marketTab.selectedImage = UIImage(named:"ic_tab_market_1")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.white)
        
//        self.searchTab.title = ""
//        self.searchTab.image = UIImage(named:"ic_tab_search_0")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(r: 103, g: 103, b: 103))
//        self.searchTab.selectedImage = UIImage(named:"ic_tab_search_1")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.white)
        
        self.portfolioTab.title = ""
        self.portfolioTab.image = UIImage(named:"ic_tab_portfolio_0")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(r: 103, g: 103, b: 103))
        self.portfolioTab.selectedImage = UIImage(named:"ic_tab_portfolio_1")?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor.white)
        
//        tabBar.isTranslucent = false
//        tabBar.barTintColor = UIColor.white
        
        tabBar.layer.masksToBounds = true
        tabBar.layer.cornerRadius = 27
        tabBar.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]

//        if #available(iOS 13.0, *) { //REMOVE TOP LINE OF TABBAR
//            let appearance = tabBar.standardAppearance
//            appearance.shadowImage = nil
//            appearance.shadowColor = nil
//            tabBar.standardAppearance = appearance
//        } else {
//            tabBar.shadowImage = UIImage()
//            tabBar.backgroundImage = UIImage()
//        }

        tabBar.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 27)
        tabBar.createButtonShadow(BorderColor: UIColor.init(hex: 0x000000, a: 0.3), ShadowColor: UIColor.init(hex: 0x000000, a: 0.3))
        
        self.selectedIndex = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        customTabBarView.frame = tabBar.frame
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let newSafeArea = UIEdgeInsets()
        
//        newSafeArea.bottom += customTabBarView.bounds.size.height
        self.children.forEach({$0.additionalSafeAreaInsets = newSafeArea})
    }
    
    private func addCustomTabBarView() {
//        customTabBarView.frame = tabBar.frame
//        view.addSubview(customTabBarView)
        view.bringSubviewToFront(self.tabBar)
    }
    
    func hideTabBarBorder()  {
        let tabBar = self.tabBar
        tabBar.backgroundImage = UIImage.from(color: .clear)
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
    }
    
    func setupTabBar() {
        
        tabBar.backgroundColor = Constants.Color.THEME_GREEN
        
        let navDashboard = UINavigationController.init(rootViewController: (GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "DashboardVC")))
        
        let navWatchlist = UINavigationController.init(rootViewController: (GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "WatchlistVC")))
                
        let navMarket = UINavigationController.init(rootViewController: (GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "MarketVC")))
        
//        let navSearch = UINavigationController.init(rootViewController: (GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "SearchByThemeVC")))
        
        let navPortfolio = UINavigationController.init(rootViewController: (GlobalData.tabBarStoryBoard().instantiateViewController(withIdentifier: "PortfolioVC")))
        
        self.setViewControllers([navDashboard, navWatchlist, navMarket, navPortfolio], animated: false)
        self.viewDidLayoutSubviews()
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
