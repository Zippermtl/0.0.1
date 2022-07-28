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
    
    private let seungButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign in Seung", for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    private let yianniButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign in Yianni", for: .normal)
        btn.titleLabel?.font = .zipBody
        btn.titleLabel?.textColor = .white
        return btn
    }()
    
    private let ezraButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign in Ezra", for: .normal)
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
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                
                let vc = LoginViewController()
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
    
    @objc private func didTapYianni() {
        var dateComponents = DateComponents()
        dateComponents.year = 2001
        dateComponents.month = 12
        dateComponents.day = 06

        let userCalendar = Calendar(identifier: .gregorian)
        let birthday = userCalendar.date(from: dateComponents)!
        
        let user = User(userId: "u9789070602",
                          username: "yianni_zav",
                          firstName: "Yianni",
                          lastName: "Zavaliagkos",
                          birthday: birthday)
        
        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
        AppDelegate.userDefaults.set(user.username, forKey: "username")
        AppDelegate.userDefaults.set(user.fullName, forKey: "name")
        AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
        AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
        AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
        AppDelegate.userDefaults.set(1, forKey: "picNum")
        
        let emptyFriendships: [String: Int]  = [:]
        AppDelegate.userDefaults.set(emptyFriendships, forKey:  "friendships")
        AppDelegate.userDefaults.set(EncodePreferences(user.notificationPreferences), forKey: "encodedNotificationSettings")
        AppDelegate.userDefaults.set("https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6501111111%2Fprofile_picture.png?alt=media&token=3d0b4726-fd1e-41a2-a26d-24b7a932065e", forKey: "profilePictureUrl")
        
        didTapContinueButton()

    }
    
    @objc private func didTapSeung() {
        var dateComponents = DateComponents()
        dateComponents.year = 2002
        dateComponents.month = 1
        dateComponents.day = 1

        let userCalendar = Calendar(identifier: .gregorian)
        let birthday = userCalendar.date(from: dateComponents)!
        
        let user = User(userId: "u2508575270",
                          username: "seungchoi",
                          firstName: "Seung",
                          lastName: "Choi",
                          birthday: birthday)
        
        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
        AppDelegate.userDefaults.set(user.username, forKey: "username")
        AppDelegate.userDefaults.set(user.fullName, forKey: "name")
        AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
        AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
        AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
        AppDelegate.userDefaults.set(1, forKey: "picNum")
        
        let emptyFriendships: [String: Int]  = [:]
        AppDelegate.userDefaults.set(emptyFriendships, forKey:  "friendships")
        AppDelegate.userDefaults.set(EncodePreferences(user.notificationPreferences), forKey: "encodedNotificationSettings")
        AppDelegate.userDefaults.set("https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6501111111%2Fprofile_picture.png?alt=media&token=3d0b4726-fd1e-41a2-a26d-24b7a932065e", forKey: "profilePictureUrl")
        
        didTapContinueButton()

    }
    
    @objc private func didTapEzra(){
        var dateComponents = DateComponents()
        dateComponents.year = 2001
        dateComponents.month = 10
        dateComponents.day = 21

        let userCalendar = Calendar(identifier: .gregorian)
        let birthday = userCalendar.date(from: dateComponents)!
        
        let user = User(userId: "u2158018458",
                          username: "ezrataylor55",
                          firstName: "Ezra",
                          lastName: "Taylor",
                          birthday: birthday)
        
        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
        AppDelegate.userDefaults.set(user.username, forKey: "username")
        AppDelegate.userDefaults.set(user.fullName, forKey: "name")
        AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
        AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
        AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
        AppDelegate.userDefaults.set(1, forKey: "picNum")
        
        let emptyFriendships: [String: Int]  = [:]
        AppDelegate.userDefaults.set(emptyFriendships, forKey:  "friendships")
        AppDelegate.userDefaults.set(EncodePreferences(user.notificationPreferences), forKey: "encodedNotificationSettings")
        AppDelegate.userDefaults.set("https://firebasestorage.googleapis.com:443/v0/b/zipper-f64e0.appspot.com/o/images%2Fu6501111111%2Fprofile_picture.png?alt=media&token=3d0b4726-fd1e-41a2-a26d-24b7a932065e", forKey: "profilePictureUrl")
        
        didTapContinueButton()
    }

    
//    private let progressView: UIProgressView = {
//        let view = UIProgressView(progressViewStyle: .bar)
//        view.trackTintColor = .clear
//        view.progressTintColor = .white
//        view.layer.borderWidth = 2
//        view.layer.borderColor = UIColor.white.cgColor
//        return view
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipLogoBlue
        
        signoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        yianniButton.addTarget(self, action: #selector(didTapYianni), for: .touchUpInside)
        seungButton.addTarget(self, action: #selector(didTapSeung), for: .touchUpInside)
        ezraButton.addTarget(self, action: #selector(didTapEzra), for: .touchUpInside)

        signoutButton.layer.masksToBounds = true
        signoutButton.layer.cornerRadius = 8
        
        yianniButton.layer.masksToBounds = true
        yianniButton.layer.cornerRadius = 8
        
        seungButton.layer.masksToBounds = true
        seungButton.layer.cornerRadius = 8
        
        ezraButton.layer.masksToBounds = true
        ezraButton.layer.cornerRadius = 8
        
        continueButton.layer.masksToBounds = true
        continueButton.layer.cornerRadius = 8

        configureLayout()
        
        AppDelegate.locationManager.requestWhenInUseAuthorization()
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
        print("ZIP REQUESTS = \(zipRequests)")
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true, completion: nil)
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

        view.addSubview(yianniButton)
        yianniButton.backgroundColor = .zipGreen
        yianniButton.translatesAutoresizingMaskIntoConstraints = false
        yianniButton.topAnchor.constraint(equalTo: signoutButton.bottomAnchor, constant: 10).isActive = true
        yianniButton.heightAnchor.constraint(equalTo: signoutButton.heightAnchor).isActive = true
        yianniButton.widthAnchor.constraint(equalTo: signoutButton.widthAnchor).isActive = true
        yianniButton.centerXAnchor.constraint(equalTo: signoutButton.centerXAnchor).isActive = true
        
        view.addSubview(seungButton)
        seungButton.backgroundColor = .zipPink
        seungButton.translatesAutoresizingMaskIntoConstraints = false
        seungButton.topAnchor.constraint(equalTo: yianniButton.bottomAnchor, constant: 10).isActive = true
        seungButton.heightAnchor.constraint(equalTo: signoutButton.heightAnchor).isActive = true
        seungButton.widthAnchor.constraint(equalTo: signoutButton.widthAnchor).isActive = true
        seungButton.centerXAnchor.constraint(equalTo: signoutButton.centerXAnchor).isActive = true
        
        view.addSubview(ezraButton)
        ezraButton.backgroundColor = .zipYellow
        ezraButton.translatesAutoresizingMaskIntoConstraints = false
        ezraButton.topAnchor.constraint(equalTo: seungButton.bottomAnchor, constant: 10).isActive = true
        ezraButton.heightAnchor.constraint(equalTo: signoutButton.heightAnchor).isActive = true
        ezraButton.widthAnchor.constraint(equalTo: signoutButton.widthAnchor).isActive = true
        ezraButton.centerXAnchor.constraint(equalTo: signoutButton.centerXAnchor).isActive = true
        
        view.addSubview(continueButton)
        continueButton.backgroundColor = .zipVeryLightGray
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.topAnchor.constraint(equalTo: ezraButton.bottomAnchor, constant: 10).isActive = true
        continueButton.heightAnchor.constraint(equalTo: signoutButton.heightAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: signoutButton.widthAnchor).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: signoutButton.centerXAnchor).isActive = true
    }
    
    


}
