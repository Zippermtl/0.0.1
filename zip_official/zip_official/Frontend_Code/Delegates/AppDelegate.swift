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
import FirebaseMessaging
import UserNotifications



@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    static let userDefaults = UserDefaults.standard
    let locationManager = CLLocationManager()

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        if Self.locationManager.authorizationStatus == .denied {
//            AppDelegate.userDefaults.removeObject(forKey: "userLoc")
//        }
        
        locationManager.delegate = self
        //FireBase
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self
     
        
        //connect to googlemaps API
        GMSPlacesClient.provideAPIKey("GOOGLE ACCESS KEY")

//        AppDelegate.userDefaults.setValue("Yianni Zavaliagkos", forKey: "name")

        AppDelegate.userDefaults.setValue(100, forKey: "maxRangeFilter")
        
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
        
        //Apearance Changes
        UITableView.appearance().backgroundColor = .clear
        applyDropDownAppearanceChanges()
        applyNavControllerAppearanceChanges()
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
        //MARK: Gabe Do
    }
    
    func applyDropDownAppearanceChanges(){
        DropDown.appearance().textFont = .zipTextFill
        DropDown.appearance().textColor = .white
        DropDown.appearance().selectedTextColor = .white
        DropDown.appearance().backgroundColor = .zipLightGray
        DropDown.appearance().selectionBackgroundColor = .zipLightGray
        DropDown.appearance().cornerRadius = 8
        DropDown.appearance().direction = .bottom
    }
  
    
    func applyNavControllerAppearanceChanges() {
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
//            let backImage = UIImage(named: "navBarBack")?.withRenderingMode(.alwaysOriginal)
            let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

            let titleAttributes = [NSAttributedString.Key.font: UIFont.zipHeader,
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
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenParts.joined()
        //AppDelegate.userDefaults.set(token, forKey: "notifToken")
        print("Device Token: \(token)")
        DatabaseManager.shared.updateNotificationToken(token: token, completion: { error in
        })
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        AppDelegate.userDefaults.set(fcmToken, forKey: "notifToken")
        DatabaseManager.shared.updateNotificationToken(token: fcmToken!, completion: { error in
        })
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
      }
    
    
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register: \(error)")
    }

}

extension AppDelegate : CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .denied {
            AppDelegate.userDefaults.removeObject(forKey: "userLoc")
        }
    }
}

