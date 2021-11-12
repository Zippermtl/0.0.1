//
//  PermissionsSetupViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/27/21.
//

import UIKit
import CoreLocation
import JGProgressHUD


class PermissionsSetupViewController: UIViewController {
    var user = User()
    let spinner = JGProgressHUD(style: .light)
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zipperLogo")
        return imageView
    }()

    private let locationButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipBlue
        btn.setTitle("TURN ON LOCATION", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .zipBodyBold.withSize(16)
        btn.layer.masksToBounds = true
        
        let view = UIImageView(image: UIImage(named: "distanceTo")?.withTintColor(.white))
        btn.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: btn.leftAnchor, constant: 5).isActive = true
        view.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: btn.heightAnchor, multiplier: 0.67).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        return btn
    }()
    
    private let notificationsButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipGreen
        btn.layer.masksToBounds = true
        btn.setTitle("RECIEVE NOTIFICATIONS", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .zipBodyBold.withSize(16)

        
        let view = UIImageView(image: UIImage(named: "notifications"))
        btn.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leftAnchor.constraint(equalTo: btn.leftAnchor, constant: 5).isActive = true
        view.centerYAnchor.constraint(equalTo: btn.centerYAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: btn.heightAnchor, multiplier: 0.67).isActive = true
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true

        return btn
    }()
    
    private let completeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("COMPLETE", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold//.withSize(20)
        return btn
    }()
    
    private let createAnAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "CREATE AN ACCOUNT"
        label.textColor = .white
        label.font = .zipBodyBold
        return label
    }()
    
    private let stepLabel: UILabel = {
        let label = UILabel()
        label.text = "STEP 3"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(12)
        return label
    }()
    
    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PERMISSIONS"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(22)
        return label
    }()
    
    private let pageStatus3: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus2 = StatusCheckView()
    
    private let requiredLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBodyBold.withSize(12)
        label.text = "REQUIRED"
        return label
    }()
    
    private let recommendedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBodyBold.withSize(12)
        label.text = "RECOMMENDED"
        return label
    }()
    
    
    @objc private func didTapCompleteButton(){
        user.firstName = "Yianni"
        user.lastName = "Zavaliagkos"
        user.userId = "u6501111111"
        user.username = "yianni_zav"
        AppDelegate.userDefaults.set("delete this", forKey: "profilePictureUrl") // delete this, for testing purposes bc user defaults stay

        
        AppDelegate.locationManager.requestWhenInUseAuthorization()

        if !CLLocationManager.locationServicesEnabled() {
            let actionSheet = UIAlertController(title: "Location Services Must Be Enabled to Use Zipper",
                                                message: "Go into settings and enable it from there",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Continue",
                                                style: .cancel,
                                                handler: nil))
            
            present(actionSheet, animated: true)
        }
        
        spinner.show(in: view)
        DatabaseManager.shared.insertUser(with: user, completion: { [weak self] success in
            guard let strongSelf = self else {
                return
            }
            
            if success {
                //upload image
                guard !strongSelf.user.pictures.isEmpty else {
                    return
                }
                
                let image = strongSelf.user.pictures[0]
                guard let data = image.pngData() else {
                    return
                }
                
                
                AppDelegate.userDefaults.set(strongSelf.user.userId, forKey: "userId")
                AppDelegate.userDefaults.set(strongSelf.user.username, forKey: "username")
                AppDelegate.userDefaults.set((strongSelf.user.firstName+strongSelf.user.lastName), forKey: "name")
                AppDelegate.userDefaults.set((strongSelf.user.firstName), forKey: "firstName")
                AppDelegate.userDefaults.set((strongSelf.user.lastName), forKey: "lastName")
                AppDelegate.userDefaults.set((strongSelf.user.birthday), forKey: "birthday")
                
                
                AppDelegate.userDefaults.set(2000, forKey: "BlueRing")
                AppDelegate.userDefaults.set(5000, forKey: "GreenRing")
                AppDelegate.userDefaults.set(10000, forKey: "PinkRing")
                
                
                
                let fileName = strongSelf.user.profilePictureFileName
                
                
                StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { results in
                    switch results {
                    case .success(let downloadUrl):
                        AppDelegate.userDefaults.set(downloadUrl, forKey: "profilePictureUrl")
                    case .failure(let error):
                        print("Storage Manager Error: \(error)")
                    }
                    
                    
                    DispatchQueue.main.async {
                        let vc = ZipperTabBarViewController()
                        vc.isNewAccount = true
                        vc.configureLocationServices()
                        vc.modalPresentationStyle = .fullScreen
                        strongSelf.present(vc, animated: true, completion: nil)
                    }
                })
            }
            
        })
        
    }
    
    @objc private func didTapLocation(){
        AppDelegate.locationManager.requestWhenInUseAuthorization()
        
        if !CLLocationManager.locationServicesEnabled() {
            let actionSheet = UIAlertController(title: "Location Services Must Be Enabled to Use Zipper",
                                                message: "Go into settings and enable it from there",
                                                preferredStyle: .actionSheet)
            
            actionSheet.addAction(UIAlertAction(title: "Continue",
                                                style: .cancel,
                                                handler: nil))
            
            present(actionSheet, animated: true)
        }
    }
    
    @objc private func didTapNotifications(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error enabling notifications: \(error)")
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
//        title = "REGISTRATION"
        navigationController?.navigationBar.isHidden = true
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(didTapLocation), for: .touchUpInside)
        notificationsButton.addTarget(self, action: #selector(didTapNotifications), for: .touchUpInside)

        addSubviews()
    }
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(createAnAccountLabel)
        scrollView.addSubview(stepLabel)
        scrollView.addSubview(stepTitleLabel)
        scrollView.addSubview(locationButton)
        scrollView.addSubview(notificationsButton)
        scrollView.addSubview(completeButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)
        scrollView.addSubview(requiredLabel)
        scrollView.addSubview(recommendedLabel)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
        
        createAnAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        createAnAccountLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 15).isActive = true
        createAnAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.topAnchor.constraint(equalTo: createAnAccountLabel.bottomAnchor, constant: 15).isActive = true
        stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        stepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stepTitleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 0).isActive = true
        stepTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        locationButton.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 40).isActive = true
        locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -50).isActive = true
        locationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        notificationsButton.translatesAutoresizingMaskIntoConstraints = false
        notificationsButton.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 40).isActive = true
        notificationsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        notificationsButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -50).isActive = true
        notificationsButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        requiredLabel.translatesAutoresizingMaskIntoConstraints = false
        requiredLabel.bottomAnchor.constraint(equalTo: locationButton.topAnchor, constant: -5).isActive = true
        requiredLabel.leftAnchor.constraint(equalTo: locationButton.leftAnchor).isActive = true
        
        recommendedLabel.translatesAutoresizingMaskIntoConstraints = false
        recommendedLabel.bottomAnchor.constraint(equalTo: notificationsButton.topAnchor, constant: -5).isActive = true
        recommendedLabel.leftAnchor.constraint(equalTo: notificationsButton.leftAnchor).isActive = true
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.topAnchor.constraint(equalTo: notificationsButton.bottomAnchor, constant: 40).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.67, constant: -60).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageStatus2.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus1.translatesAutoresizingMaskIntoConstraints = false
        pageStatus1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus1.rightAnchor.constraint(equalTo: pageStatus2.leftAnchor, constant: -10).isActive = true
        pageStatus1.heightAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        pageStatus1.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus3.translatesAutoresizingMaskIntoConstraints = false
        pageStatus3.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus3.leftAnchor.constraint(equalTo: pageStatus2.rightAnchor, constant: 10).isActive = true
        pageStatus3.heightAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        pageStatus3.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus1.layer.cornerRadius = 5
        pageStatus2.layer.cornerRadius = 5
        pageStatus3.layer.cornerRadius = 5
        
        notificationsButton.layer.cornerRadius = 15
        locationButton.layer.cornerRadius = 15
        
    }

   
}
