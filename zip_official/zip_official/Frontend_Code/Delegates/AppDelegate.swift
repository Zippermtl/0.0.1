//
//  AppDelegate.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreGraphics
import DropDown
import GooglePlaces
import Firebase
import FirebaseAuth


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let userDefaults = UserDefaults.standard
    static let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        //FireBase
        FirebaseApp.configure()
        
        //connect to googlemaps API
        GMSPlacesClient.provideAPIKey("AIzaSyAlXUKYzukB_QHXwWtI3RPGu9bx_nkbuII")

//        AppDelegate.userDefaults.setValue("Yianni Zavaliagkos", forKey: "name")

        AppDelegate.userDefaults.setValue(2, forKey: "maxRangeFilter")
        
        
        //Apearance Changes
        applyDropDownAppearanceChanges()
        applyTableViewAppearanceChanges()
        applyNavControllerAppearanceChanges()
        applyTabBarAppearanceChanges()
        applyGooglePlacesSearchAppearanceChanges()
        setDeviceDefault()
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applyDropDownAppearanceChanges(){
        DropDown.appearance().textFont = .zipBody
        DropDown.appearance().textColor = .white
        DropDown.appearance().selectedTextColor = .white
        DropDown.appearance().backgroundColor = .zipLightGray
        DropDown.appearance().selectionBackgroundColor = .zipLightGray
        DropDown.appearance().cornerRadius = 15
        DropDown.appearance().direction = .bottom
    }
    
    func applyTableViewAppearanceChanges(){
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .zipSeparator
        UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 1))
        UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 1))
        UITableView.appearance().bounces = true
        
//        if #available(iOS 15.0, *) {
//            UITableView.appearance().sectionHeaderTopPadding = 0
//        }
    }
    
    func applyNavControllerAppearanceChanges() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
//            let backImage = UIImage(named: "navBarBack")?.withRenderingMode(.alwaysOriginal)
            let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

            let titleAttributes = [NSAttributedString.Key.font: UIFont.zipTitle.withSize(27),
                                   NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .zipGray
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
            appearance.titleTextAttributes = titleAttributes
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
            UINavigationBar.appearance().isTranslucent = false
            UINavigationBar.appearance().barTintColor = .zipGray
            UINavigationBar.appearance().titleTextAttributes = titleAttributes
        } else {
            UINavigationBar.appearance().barTintColor = .zipGray
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.zipTitle.withSize(27),
                                                                NSAttributedString.Key.foregroundColor: UIColor.white]
        }
        
        
        
//        let backImage = UIImage(named: "navBarBack")?.withRenderingMode(.alwaysOriginal)
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal)

        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
    }
    
    func applyTabBarAppearanceChanges(){
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .zipDarkGray
        UITabBar.appearance().standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            print("tab bar should be good")
            UITabBar.appearance().scrollEdgeAppearance = appearance
        } else {
            print("WHAT THE FUCK")
        }
        UITabBar.appearance().isTranslucent = false
    }

    private func applyGooglePlacesSearchAppearanceChanges() {
//        GMSAutocompleteViewController.appearance()
    }


    
    private func setDeviceDefault(){
        switch UIDevice.modelName {
        case "iPod touch (5th generation)",
             "iPod touch (6th generation)" ,
             "iPod touch (7th generation)" ,
             "iPhone 4",
             "iPhone 4s",
             "iPhone 5",
             "iPhone 5c",
             "iPhone 5s",
             "iPhone 6",
             "iPhone 6 Plus" ,
             "iPhone 6s",
             "iPhone 6s Plus",
             "iPhone SE",
             "iPhone 7",
             "iPhone 7 Plus",
             "iPhone 8",
             "iPhone 8 Plus",
             "iPad 2",
             "iPad (3rd generation)",
             "iPad (4th generation)",
             "iPad (5th generation)",
             "iPad (6th generation)",
             "iPad (7th generation)",
             "iPad (8th generation)",
             "iPad Air",
             "iPad Air 2",
             "iPad Air (3rd generation)",
             "iPad Air (4th generation)",
             "iPad mini",
             "iPad mini 2",
             "iPad mini 3",
             "iPad mini 4",
             "iPad mini (5th generation)",
             "iPad Pro (9.7-inch)",
             "iPad Pro (10.5-inch)",
             "iPad Pro (11-inch) (1st generation)",
             "iPad Pro (11-inch) (2nd generation)",
             "iPad Pro (12.9-inch) (1st generation)",
             "iPad Pro (12.9-inch) (2nd generation)",
             "iPad Pro (12.9-inch) (3rd generation)",
             "iPad Pro (12.9-inch) (4th generation)":
                AppDelegate.userDefaults.setValue(true, forKey: "hasHomeButton")
        default:
            AppDelegate.userDefaults.setValue(false, forKey: "hasHomeButton")
        }
    }
    
    
}


