//
//  LoadingViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/25/22.
//

import UIKit
import CoreLocation
import FirebaseAuth




class LoadingViewController: UIViewController {

     //info that needs to be loaded
    var zipRequests: [ZipRequest] = []
    var events: [Event] = []
    
    
    private let logo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "zipperLogo")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    private let signoutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign out", for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.titleLabel?.textColor = .white

        return btn
    }()
    

    private let continueButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue to App", for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    
    
    @objc private func didTapLogoutButton(){
        print("logout tapped")
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let domain = Bundle.main.bundleIdentifier!
                AppDelegate.userDefaults.removePersistentDomain(forName: domain)
                AppDelegate.userDefaults.synchronize()
                
                let vc = OpeningLoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }
            catch {
                print("Failed to Logout User")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @objc private func didTapContinueButton() {
        guard isLocationEnabled() == true else {
            locationDenied()
            return
        }
        presentMap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipLogoBlue
        
        signoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)


        signoutButton.layer.masksToBounds = true
        signoutButton.layer.cornerRadius = 8
        
        continueButton.layer.masksToBounds = true
        continueButton.layer.cornerRadius = 8

        configureLayout()
        
        AppDelegate.locationManager.requestWhenInUseAuthorization()
        let userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        DatabaseManager.shared.loadUserProfile(given: User(userId: userId), completion: { [weak self] result in
            switch result {
            case .success(let user):
                AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                AppDelegate.userDefaults.set(user.username, forKey: "username")
                AppDelegate.userDefaults.set(user.fullName, forKey: "name")
                AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
                AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
                AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
                AppDelegate.userDefaults.set(user.picNum, forKey: "picNum")
                AppDelegate.userDefaults.set(user.profilePicIndex, forKey: "profileIndex")
                AppDelegate.userDefaults.set(user.picIndices, forKey: "picIndices")
                
                if let pfpUrl = user.profilePicUrl {
                    AppDelegate.userDefaults.set(pfpUrl.absoluteString, forKey: "profilePictureUrl")
                } else {
                    AppDelegate.userDefaults.set("", forKey: "profilePictureUrl")
                }
                
                DatabaseManager.shared.loadUserFriendships(given: user.userId, completion: { result in
                    switch result {
                    case .success(let friendships):
                        let encoded = EncodeFriendsUserDefaults(friendships)
                        AppDelegate.userDefaults.set(encoded, forKey: "friendships")
                        print("Friendships loaded", friendships)
                    case .failure(let error):
                        print("failure loading friendships in loadingVC Error: \(error)")
                    }
                })
            case .failure(let error):
                print("failure loading profile in loadingVC Error: \(error)")

            }
        })
    }
    
    private func isLocationEnabled() -> Bool {
        let manager = CLLocationManager()
        return CLLocationManager.locationServicesEnabled() || manager.authorizationStatus != .denied
    }
    
    private func locationDenied() {
        let vc = LocationDeniedViewController()
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
    }
    
    private func loadLaunchData(completion: @escaping ((Error?) -> Void)){
//        loadZipRequests(completion: { [weak self] error in
//            completion(error)
//
//        })
    }
    
    private func loadEvents(completion: @escaping ((Error?) -> Void)) {
//        GeoManager.shared.GetEventByLocation(range: <#T##Double#>, max: <#T##Int#>, completion: <#T##() -> Void#>)
    }
    
    private func loadZipRequests(completion: @escaping ((Error?) -> Void)) {
        
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        DataStorageManager.shared.selfUser.getIncomingRequests(completion: { [weak self] results in
            switch results {
            case .success(let requests):
                self?.zipRequests = requests
                completion(nil)
//                if requests.count != 0 {
//                    let imagesPath = "images/" + requests[0].fromUser.userId
//                    StorageManager.shared.getProfilePicture(path: imagesPath, completion: { result in
//                        switch result {
//                        case .success(let url):
//                            requests[0].fromUser.pictureURLs.append(contentsOf: url)
//                            print("IN LOADING1 ", requests[0].fromUser.pictureURLs)
//
//                            print("Success in loading???")
//                            print("Successful pull of user image URLS for \(user.fullName) with \(user.pictureURLs.count) URLS ")
//                            print("Successfully loaded tableview")
//                            
//                            completion(nil)
//
//                        case .failure(let error):
//                            print("error load in LoadUser image URLS -> LoadUserProfile -> LoadImagesManually \(error)")
//                            completion(error)
//                        }
//                    })
//                }
//
//
//                print("IN LOADING ", requests[0].fromUser.pictureURLs)
                
            case .failure(let error):
                print("failed to initialize zip requests on launch with error \(error)")
                completion(error)
            }
            
            // present map regaurdless?


        })
    }
    
    private func presentMap(){
        let vc = MapViewController(isNewAccount: false)
        let navVC = UINavigationController(rootViewController: vc)
        navVC.modalPresentationStyle = .overFullScreen
        navVC.modalTransitionStyle = .crossDissolve
        present(navVC, animated: true, completion: nil)
    }
    
    private func configureLayout(){
        view.addSubview(logo)
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        logo.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        logo.heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        view.addSubview(signoutButton)
        signoutButton.backgroundColor = .red
        signoutButton.translatesAutoresizingMaskIntoConstraints = false
        signoutButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 30).isActive = true
        signoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signoutButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        signoutButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true

        view.addSubview(continueButton)
        continueButton.backgroundColor = .zipVeryLightGray
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.topAnchor.constraint(equalTo: signoutButton.bottomAnchor, constant: 10).isActive = true
        continueButton.heightAnchor.constraint(equalTo: signoutButton.heightAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: signoutButton.widthAnchor).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: signoutButton.centerXAnchor).isActive = true
    }
    
    


}
