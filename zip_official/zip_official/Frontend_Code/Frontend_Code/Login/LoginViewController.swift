//
//  LoginViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

protocol registrationCompleteProtocol{
    func startLocationTracking()
}

class LoginViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .light)
    var locationDelegate: registrationCompleteProtocol?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zipperLogo")
        return imageView
    }()
    
    private let phoneField: UITextField = {
        let field = UITextField()
        field.keyboardType = .numberPad
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Phone Number....",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white

        return field
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Log In", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold.withSize(20)
        return btn
    }()

    
    @objc private func didTapLoginButton(){
        phoneField.resignFirstResponder()
        
        if let text = phoneField.text, !text.isEmpty {
            let number = "+1\(text)"
            DatabaseManager.shared.startAuth(phoneNumber: number, completion: { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    let vc = SMSCodeViewController()
                    vc.userId = "u" + text
                    vc.title = "Verify Code"
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        
        
        
//        guard let email = phoneField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
//            return
//        }
//
//        spinner.show(in: view)
//
//
//        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResults, error in
//            guard let strongSelf = self else {
//                return
//            }
//
//            DispatchQueue.main.async {
//                strongSelf.spinner.dismiss()
//            }
//
//            guard authResults != nil, error == nil else {
//                print("failed to log in user with email \(email)")
//                return
//            }
//            AppDelegate.userDefaults.set(email, forKey: "email")
//
//            let safeEmail = DatabaseManager.safeEmail(email: email)
//            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { results in
//                switch results {
//                case .success(let data):
//                    guard let userData = data as? [String: Any],
//                          let firstName = userData["first_name"] as? String,
//                          let lastName = userData["last_name"] as? String else {
//                              return
//                          }
//
//                    AppDelegate.userDefaults.set("\(firstName) \(lastName)", forKey: "email")
//
//                case .failure(let error):
//                    print("Failed ot read data with error \(error)")
//                }
//
//            })
//
//            AppDelegate.userDefaults.set(email, forKey: "email")
//
//
//            strongSelf.locationDelegate?.startLocationTracking()
//            strongSelf.dismiss(animated: true, completion: nil)
//        })
    }
    
//    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Log In/Register"
        view.backgroundColor = .zipGray
        navigationController?.navigationBar.isHidden = true
        phoneField.delegate = self
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        
        addSubviews()
    }
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(phoneField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
        
        phoneField.translatesAutoresizingMaskIntoConstraints = false
        phoneField.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 10).isActive = true
        phoneField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        phoneField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        phoneField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: phoneField.bottomAnchor, constant: 10).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }

    
    
    

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            let number = "+1\(text)"
            DatabaseManager.shared.startAuth(phoneNumber: number, completion: { [weak self] success in
                guard success else { return }
                DispatchQueue.main.async {
                    let vc = SMSCodeViewController()
                    vc.userId = "u" + text
                    vc.title = "Verify Code"
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
                
            })
        }
        return true
    }
    
}
