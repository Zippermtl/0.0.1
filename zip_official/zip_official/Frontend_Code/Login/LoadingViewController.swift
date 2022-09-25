//
//  LoadingViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/25/22.
//

import UIKit
import CoreLocation
import FirebaseAuth
import JGProgressHUD



class LoadingViewController: UIViewController {
    let spinner = JGProgressHUD(style: .light)
    private let logo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "zipperLogo")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        view.backgroundColor = .zipGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipLogoBlue
        spinner.backgroundColor = .clear
        spinner.tintColor = .clear
        configureLayout()
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        let user = User(userId: userId)
        spinner.show(in: view)
        let vc = MapViewController(isNewAccount: false)
        user.load(status: .UserProfileUpdates, dataCompletion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let user):
                AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                AppDelegate.userDefaults.set(user.username, forKey: "username")
                AppDelegate.userDefaults.set(user.fullName, forKey: "name")
                AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
                AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
                AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
                AppDelegate.userDefaults.set(user.gender, forKey: "gender")
                AppDelegate.userDefaults.set(user.picNum, forKey: "picNum")
                
                AppDelegate.userDefaults.set(user.profilePicIndex, forKey: "profileIndex")
                AppDelegate.userDefaults.set(user.picIndices, forKey: "picIndices")
                
                DatabaseManager.shared.getImportantUsers()
                
                let navVC = UINavigationController(rootViewController: vc)
                navVC.modalPresentationStyle = .overFullScreen
                navVC.modalTransitionStyle = .crossDissolve
                
                DispatchQueue.main.async {
                    strongSelf.view.backgroundColor = .zipGray
                    strongSelf.spinner.dismiss(animated: true)
                    strongSelf.present(navVC, animated: true, completion: nil)
                }
            case .failure(_):
//                print("Failed to load and logout user Error: \(error)\nPushing to login")
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    let domain = Bundle.main.bundleIdentifier!
                    AppDelegate.userDefaults.removePersistentDomain(forName: domain)
                    AppDelegate.userDefaults.synchronize()
                    DispatchQueue.main.async {
                        let vc = OpeningLoginViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        strongSelf.present(nav, animated: true, completion: nil)
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        let vc = OpeningLoginViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        strongSelf.present(nav, animated: true, completion: nil)
                    }
                }
            }
            
        }, completionUpdates: { _ in
            if let pfpUrl = user.profilePicUrl {
                AppDelegate.userDefaults.set(pfpUrl.absoluteString, forKey: "profilePictureUrl")
                vc.profileButton.sd_setImage(with: pfpUrl, for: .normal)
            } else {
                AppDelegate.userDefaults.set("", forKey: "profilePictureUrl")
            }
        })
        
        DatabaseManager.shared.getAllUserDefaultsEvents(completion: { error in
            guard error == nil else {
                print("FUCK USER DEFAULTS FAILED")
                return
            }
        })
    }

    private func configureLayout(){
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        logo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 250).isActive = true
    }
    
    


}
