//
//  SceneDelegate.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/2/21.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.overrideUserInterfaceStyle = .dark
        window?.makeKeyAndVisible()

        
//        window?.rootViewController = SMSCodeViewController()
//        window?.rootViewController = LoadingViewController()
        
//        let vc = FilterSettingsViewController()
//        let navVC = UINavigationController(rootViewController: vc)
//        window?.rootViewController = navVC
        
        
        if Auth.auth().currentUser == nil {
            let vc = OpeningLoginViewController()
            let navVC = UINavigationController(rootViewController: vc)
            window?.rootViewController = navVC
        } else {

            if checkUserDefaults() {
                window?.rootViewController = LoadingViewController()
            } else {
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let domain = Bundle.main.bundleIdentifier!
                    UserDefaults.standard.removePersistentDomain(forName: domain)
                    UserDefaults.standard.synchronize()

                    let vc = OpeningLoginViewController()
                    let navVC = UINavigationController(rootViewController: vc)
                    window?.rootViewController = navVC
                }
                catch {
                    print("Failed to Logout User")
                }
            }
        }
         
    }
    
    private func checkUserDefaults() -> Bool {
        guard   AppDelegate.userDefaults.value(forKey: "userId") != nil,
                AppDelegate.userDefaults.value(forKey: "username") != nil,
                AppDelegate.userDefaults.value(forKey: "name") != nil,
                AppDelegate.userDefaults.value(forKey: "firstName") != nil,
                AppDelegate.userDefaults.value(forKey: "lastName") != nil,
                AppDelegate.userDefaults.value(forKey: "lastName") != nil,
                AppDelegate.userDefaults.value(forKey: "profilePictureUrl") != nil,
                AppDelegate.userDefaults.value(forKey: "birthday") != nil,
                AppDelegate.userDefaults.value(forKey: "picNum") != nil
        else {
            return false
        }
        return true
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

