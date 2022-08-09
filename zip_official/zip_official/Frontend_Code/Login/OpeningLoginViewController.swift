//
//  OpeningLoginViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/9/22.
//

import UIKit

class OpeningLoginViewController: UIViewController {
    let welcomeLabel: UILabel
    
    let loginButton: UIButton
    let registerButton: UIButton
    
    init() {
        welcomeLabel = UILabel.zipTitle()
        loginButton = UIButton()
        registerButton = UIButton()
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .zipGray
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapLoginButton(){
        let vc = LoginViewController(isLogin: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRegisterButton(){
        let vc = LoginViewController(isLogin: false)
        navigationController?.pushViewController(vc, animated: true)
    }
    private func configureSubviews(){
        welcomeLabel.text = "Welcome To Zipper"
        
        view.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = UIFont.zipTextFill
        loginButton.backgroundColor = .zipBlue
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 8
        
        registerButton.setTitle("Register", for: .normal)
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.titleLabel?.font = UIFont.zipTextFill
        registerButton.backgroundColor = .zipVeryLightGray
        registerButton.layer.masksToBounds = true
        registerButton.layer.cornerRadius = 8
        
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 50).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20).isActive = true
        registerButton.heightAnchor.constraint(equalTo: loginButton.heightAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: loginButton.widthAnchor).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    

    
}
