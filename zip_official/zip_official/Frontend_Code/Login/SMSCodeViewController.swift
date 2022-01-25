//
//  SMSCodeViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/26/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import CoreLocation

class SMSCodeViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .light)
    var userId = ""
    
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
    
    private let codeField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Enter Code...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white

        return field
    }()
    
    private let verifyCodeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Verify", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold.withSize(20)
        return btn
    }()

    
    @objc private func didTapLoginButton(){
        codeField.resignFirstResponder()
        
        guard let smsCode = codeField.text, !smsCode.isEmpty else {
            return
        }
        
        loginOrRegister(smsCode: smsCode)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Log In/Register"
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .zipGray
        codeField.delegate = self
        verifyCodeButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        
        addSubviews()
    }
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(codeField)
        scrollView.addSubview(verifyCodeButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
        
        codeField.translatesAutoresizingMaskIntoConstraints = false
        codeField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 10).isActive = true
        codeField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        codeField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        codeField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        verifyCodeButton.translatesAutoresizingMaskIntoConstraints = false
        verifyCodeButton.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 10).isActive = true
        verifyCodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        verifyCodeButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        verifyCodeButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    
    private func continuteRegistration(){
        let vc = BasicProfileSetupViewController()
        vc.user.userId = userId
        navigationController?.pushViewController(vc, animated: true)

    }
    
    private func loginOrRegister(smsCode: String){
        DatabaseManager.shared.verifyCode(smsCode: smsCode, completion: {[weak self] success in
            guard success, let strongSelf = self else { return }
            
            DatabaseManager.shared.userExists(with: strongSelf.userId, completion: { [weak self] exists in
                guard let strongSelf = self else {
                    return
                }
                

                
                if exists {
                    //user already exists
                    let user = User(userId: strongSelf.userId)
                    DatabaseManager.shared.loadUserProfileZipFinder(given: user, completion: { [weak self] result in
                        guard let strongSelf = self else {
                            return
                        }
                        
                        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                        AppDelegate.userDefaults.set(user.username, forKey: "username")
                        AppDelegate.userDefaults.set((user.fullName), forKey: "name")
                        AppDelegate.userDefaults.set((user.firstName), forKey: "firstName")
                        AppDelegate.userDefaults.set((user.lastName), forKey: "lastName")
                        AppDelegate.userDefaults.set((user.birthday), forKey: "birthday")
                        AppDelegate.userDefaults.set(0, forKey: "picNum")
                        AppDelegate.userDefaults.set(user.pictureURLs[0].description, forKey: "profilePictureUrl")

                        DispatchQueue.main.async {
                            let vc = MapViewController()
                            vc.modalPresentationStyle = .fullScreen
                            AppDelegate.locationManager.requestWhenInUseAuthorization()

                            // get basic user profile - username, userId, name
                            AppDelegate.userDefaults.set(self?.userId, forKey: "userId")
                            

                            if !CLLocationManager.locationServicesEnabled() || AppDelegate.locationManager.authorizationStatus == .denied {
                                print("location services not enabled")
                                let vc = LocationDeniedViewController()
                                vc.modalPresentationStyle = .overFullScreen
                                vc.modalTransitionStyle = .crossDissolve
                                self?.present(vc, animated: true, completion: nil)
                            } else {
                                let vc = MapViewController()
                                vc.isNewAccount = false
                                vc.configureLocationServices()
                                vc.modalPresentationStyle = .fullScreen
                                self?.present(vc, animated: true, completion: nil)
                            }
                            
                            DispatchQueue.main.async {
                                strongSelf.spinner.dismiss()
                            }
                            
                            // make sure to check if location is already enabled
                            // have to request if its straight log in on first device
                            
                            
                            self?.present(vc, animated: true, completion: nil)
                            
                            
                        }
                        
                    })
                    
                } else {
                    //user doens't exist
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss()
                    }
                    strongSelf.continuteRegistration()
                }
            })
        })
    }
    
}



extension SMSCodeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let smsCode = textField.text, !smsCode.isEmpty {
            loginOrRegister(smsCode: smsCode)
        }
        return true
    }
    
}


// OLD email based insert user


//Firebase register
    
//                DatabaseManager.shared.insertUser(with: user, completion: { success in
//                    if success {
//                        //upload image
//                        guard let image = strongSelf.imageView.image,
//                              let data = image.pngData() else {
//                            return
//                        }
//
//                        let fileName = user.profilePictureFileName
//                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { results in
//                            switch results {
//                            case .success(let downloadUrl):
//                                AppDelegate.userDefaults.set(downloadUrl, forKey: "profilePictureUrl")
//                                print(downloadUrl)
//                            case .failure(let error):
//                                print("Storage Manager Error: \(error)")
//                            }
//
//                        })
//                    }
//
//                })
