//
//  TabBarViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//


/*

 Firebase rules after expire
 
 {
   "rules": {
     ".read": "now < 1635998400000",  // 2021-11-4
     ".write": "now < 1635998400000",  // 2021-11-4
   }
 }





*/
import UIKit
import MapKit
import CoreLocation
import FirebaseAuth

protocol TabBarReselectHandling {
    func handleReselect()
}

protocol LocationUpdateProtocol {
    func locationUpdated()
    func zoomMap()
    func updateProfilePic()
}

class ZipperTabBarViewController: UITabBarController {
    static var userLoc: CLLocationCoordinate2D!
    var reselectDelegate: TabBarReselectHandling?
    var locationDelegate: LocationUpdateProtocol?
    var isNewAccount = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        view.backgroundColor = .zipMidGray
        
        if #available(iOS 13.0, *){
            overrideUserInterfaceStyle = .dark
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        tabBar.standardAppearance = appearance
        
        let eventsVC = EventFinderViewController()
        let eventsNav = UINavigationController(rootViewController: eventsVC)
        let eventsIcon = UITabBarItem(title: "",
                                      image: UIImage(named: "events")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "events")?.withRenderingMode(.alwaysOriginal)
                                                                              .withTintColor(.zipYellow))
        eventsVC.tabBarItem = eventsIcon
        
        let mapVC = MapViewController()
        mapVC.isNewAccount = self.isNewAccount
//        mapVC.isNewAccount = true

        let mapNav = UINavigationController(rootViewController: mapVC)
        let mapIcon = UITabBarItem(title: "",
                                   image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal),
                                   selectedImage: UIImage(named: "homeFullColor")?.withRenderingMode(.alwaysOriginal))
        
        mapVC.tabBarItem = mapIcon
        
        let messagesVC = ZipMessagesViewController()
        let messagesNav = UINavigationController(rootViewController: messagesVC)
        let messagesIcon = UITabBarItem(title: "",
                                        image: UIImage(named: "messages")?.withRenderingMode(.alwaysOriginal),
                                        selectedImage: UIImage(named: "messages")?.withRenderingMode(.alwaysOriginal)
                                                                                  .withTintColor(.zipGreen))
        messagesVC.tabBarItem = messagesIcon
        
        let notificationsVC = NotificationsViewController()
        let notificationsNav = UINavigationController(rootViewController: notificationsVC)
        let notificationsIcon = UITabBarItem(title: "",
                                             image: UIImage(named: "notifications")?.withRenderingMode(.alwaysOriginal),
                                             selectedImage: UIImage(named: "notifications")?.withRenderingMode(.alwaysOriginal)
                                                                                            .withTintColor(.zipRed))
        notificationsVC.tabBarItem = notificationsIcon
        
        
        viewControllers = [eventsNav, mapNav, messagesNav, notificationsNav]
        selectedIndex = 2 // start on map
    }
    
    //Login
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    func updateMapProfilePic(){
        locationDelegate?.updateProfilePic()
    }
    
    
}

extension ZipperTabBarViewController: UITabBarControllerDelegate {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if (tabBar.items?[selectedIndex] == item) {
            reselectDelegate?.handleReselect()
        }
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if let vc = viewController as? UINavigationController {
            vc.popToRootViewController(animated: false);
        }
        
        if let tabBarItem = tabBarController.tabBar.items?[2] {
            tabBarItem.selectedImage = UIImage(named: "homeFullColor")?.withRenderingMode(.alwaysOriginal)
        }
        return true
    }
}


//MARK: - Location Services
extension ZipperTabBarViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.first else { return }
//        userLoc = latestLocation.coordinate

    }
    
    // change auuthorization status
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: AppDelegate.locationManager)
        }
    }
    
    @objc  func configureLocationServices(){
        AppDelegate.locationManager.delegate = self
        AppDelegate.locationManager.requestWhenInUseAuthorization()

        if CLLocationManager.locationServicesEnabled(){
            beginLocationUpdates(locationManager: AppDelegate.locationManager)
        }
    }
    
    //start location updates
    private func beginLocationUpdates(locationManager: CLLocationManager){
        AppDelegate.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        AppDelegate.locationManager.startUpdatingLocation()
        AppDelegate.locationManager.pausesLocationUpdatesAutomatically = false

    }
}

extension ZipperTabBarViewController: registrationCompleteProtocol {
    func startLocationTracking() {
        configureLocationServices()
    }
}
