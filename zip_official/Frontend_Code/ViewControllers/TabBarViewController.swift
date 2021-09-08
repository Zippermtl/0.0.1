//
//  TabBarViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit
import MapKit
import CoreLocation


protocol TabBarReselectHandling {
    func handleReselect()
}

class TabBarViewController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        tabBar.standardAppearance = appearance
//        UITabBar.appearance().backgroundColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
//        tabBar.tintColor = UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
        
        let eventsVC = EventFinderViewController()
        let eventsIcon = UITabBarItem(title: "",
                                      image: UIImage(named: "events")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "events")?.withRenderingMode(.alwaysOriginal)
                                                                              .withTintColor(.zipYellow))
        eventsVC.tabBarItem = eventsIcon
        
        let searchVC = SearchViewController()
        let searchIcon = UITabBarItem(title: "",
                                      image: UIImage(named: "search")?.withRenderingMode(.alwaysOriginal),
                                      selectedImage: UIImage(named: "search")?.withRenderingMode(.alwaysOriginal)
                                                                              .withTintColor(.zipPink))
        searchVC.tabBarItem = searchIcon
        
        let mapVC = MapViewController()
        let mapIcon = UITabBarItem(title: "",
                                   image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal),
                                   selectedImage: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal)
                                                                         .withTintColor(.zipBlue))
        mapVC.tabBarItem = mapIcon
        
        let messagesVC = UINavigationController(rootViewController: MessagesViewController())
        
        let messagesIcon = UITabBarItem(title: "",
                                        image: UIImage(named: "messages")?.withRenderingMode(.alwaysOriginal),
                                        selectedImage: UIImage(named: "messages")?.withRenderingMode(.alwaysOriginal)
                                                                                  .withTintColor(.zipGreen))
        messagesVC.tabBarItem = messagesIcon
        
        let notificationsVC = NotificationsViewController()
        let notificationsIcon = UITabBarItem(title: "",
                                             image: UIImage(named: "notifications")?.withRenderingMode(.alwaysOriginal),
                                             selectedImage: UIImage(named: "notifications")?.withRenderingMode(.alwaysOriginal)
                                                                                            .withTintColor(.zipRed))
        notificationsVC.tabBarItem = notificationsIcon
        
        
        viewControllers = [eventsVC, searchVC, mapVC, messagesVC, notificationsVC]
        selectedIndex = 2

    }
    
}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if tabBarController.selectedViewController === viewController,
                    let handler = viewController as? TabBarReselectHandling {
                    handler.handleReselect()
        } else {
            tabBarController.selectedViewController?.dismiss(animated: false, completion: nil)
        }
        
        return true
    }
}
