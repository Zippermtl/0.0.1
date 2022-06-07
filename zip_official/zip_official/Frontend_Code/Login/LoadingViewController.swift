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

    
    
    
    private let logo: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "logopng")
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    
    private let signoutButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Sign out for testing purposes", for: .normal)
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
        configureLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationServices()
    }
    
    private func checkLocationServices() {

        let manager = CLLocationManager()
        if !CLLocationManager.locationServicesEnabled() || manager.authorizationStatus == .denied {
            let vc = LocationDeniedViewController()
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        } else {
            loadZipRequests()
        }
    }
    
    private func loadZipRequests() {
        
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        let user = User(userId: userId)
        user.getIncomingRequests(completion: { [weak self] results in
            
            switch results {
            case .success(let requests):
                self?.zipRequests = requests
                
                if requests.count != 0 {
                    let imagesPath = "images/" + requests[0].fromUser.userId
                    StorageManager.shared.getProfilePicture(path: imagesPath, completion: { result in
                        switch result {
                        case .success(let url):
                            requests[0].fromUser.pictureURLs.append(contentsOf: url)
                            print("IN LOADING1 ", requests[0].fromUser.pictureURLs)

                            print("Success in loading???")
                            print("Successful pull of user image URLS for \(user.fullName) with \(user.pictureURLs.count) URLS ")
                            print("Successfully loaded tableview")
                            
                            self?.presentMap()

                        case .failure(let error):
                            print("error load in LoadUser image URLS -> LoadUserProfile -> LoadImagesManually \(error)")
                        }
                    })
                }
               
                
                print("IN LOADING ", requests[0].fromUser.pictureURLs)
                
            case .failure(let error):
                print("failed to initialize zip requests on launch with error \(error)")
            }
            
            // present map regaurdless?


        })
    }
    
    private func presentMap(){
        let vc = MapViewController()
        vc.isNewAccount = false
        vc.zipRequests = zipRequests
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
        signoutButton.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        signoutButton.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        
        
        
    }
    
    


}
