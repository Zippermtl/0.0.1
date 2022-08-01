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
        imageView.image = UIImage(named: "logopng")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let SMSCodeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 15
        stack.alignment = .center
        
        return stack
    }()
    
    private let code1 = SMSCodeField()
    private let code2 = SMSCodeField()
    private let code3 = SMSCodeField()
    private let code4 = SMSCodeField()
    private let code5 = SMSCodeField()
    private let code6 = SMSCodeField()
    
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
        code1.resignFirstResponder()
        code2.resignFirstResponder()
        code3.resignFirstResponder()
        code4.resignFirstResponder()
        code5.resignFirstResponder()
        code6.resignFirstResponder()

        guard let smsCode = getSMSCode(),
                            !smsCode.isEmpty else {
            return
        }
        
        loginOrRegister(smsCode: smsCode)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "Log In/Register"
        navigationController?.navigationBar.isHidden = true
        view.backgroundColor = .zipGray
        code1.delegate = self
        code2.delegate = self
        code3.delegate = self
        code4.delegate = self
        code5.delegate = self
        code6.delegate = self
        
        code1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code4.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code5.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        code6.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        verifyCodeButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        
        code1.keyboardType = .numberPad
        code2.keyboardType = .numberPad
        code3.keyboardType = .numberPad
        code4.keyboardType = .numberPad
        code5.keyboardType = .numberPad
        code6.keyboardType = .numberPad

        
        addSubviews()
    }
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(SMSCodeStack)
        SMSCodeStack.addArrangedSubview(code1)
        SMSCodeStack.addArrangedSubview(code2)
        SMSCodeStack.addArrangedSubview(code3)
        SMSCodeStack.addArrangedSubview(code4)
        SMSCodeStack.addArrangedSubview(code5)
        SMSCodeStack.addArrangedSubview(code6)
        scrollView.addSubview(verifyCodeButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds

        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor, multiplier: 0.5).isActive = true
        
        code1.widthAnchor.constraint(equalToConstant: 30).isActive = true
        code2.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
        code3.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
        code4.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
        code5.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
        code6.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
        
        SMSCodeStack.translatesAutoresizingMaskIntoConstraints = false
        SMSCodeStack.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 10).isActive = true
        SMSCodeStack.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        SMSCodeStack.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        SMSCodeStack.heightAnchor.constraint(equalToConstant: 100).isActive = true
    
        
        verifyCodeButton.translatesAutoresizingMaskIntoConstraints = false
        verifyCodeButton.topAnchor.constraint(equalTo: SMSCodeStack.bottomAnchor, constant: 10).isActive = true
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
                    DatabaseManager.shared.loadUserProfile(given: user, completion: { [weak self] result in
                        
                        AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                        AppDelegate.userDefaults.set(user.username, forKey: "username")
                        AppDelegate.userDefaults.set(user.fullName, forKey: "name")
                        AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
                        AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
                        AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
                        AppDelegate.userDefaults.set(user.picNum, forKey: "picNum")
                        AppDelegate.userDefaults.set(user.profilePicUrl.description, forKey: "profilePictureUrl")

                        DatabaseManager.shared.loadUserFriendships(given: user.userId, completion: { result in
                            switch result {
                            case .success(let friendships):
                                let encoded = EncodeFriendships(friendships)
                                AppDelegate.userDefaults.set(encoded, forKey: "friendships")
                                DispatchQueue.main.async {
                                    guard let strongSelf = self else {
                                        return
                                    }
                                    
                                    let vc = LoadingViewController()
                                    vc.modalPresentationStyle = .fullScreen
                                    DispatchQueue.main.async {
                                        strongSelf.spinner.dismiss()
                                    }
                                    
                                    strongSelf.present(vc, animated: true, completion: nil)
            
                                }
                            case .failure(let error):
                                print("failure to log in user Error: \(error)")
                            }
                            
                            
                        })
                        
                        
                        
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
    
    
    private func getSMSCode() -> String? {
        var out: String? = code1.text
        for code in SMSCodeStack.arrangedSubviews {
            
            guard let c = code as? SMSCodeField,
                  let text = c.text else {
                return out
            }
            
            if code == code1 { continue }

            out! += text
        }
        return out
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        switch textField {
        case code1: code2.becomeFirstResponder()
        case code2: code3.becomeFirstResponder()
        case code3: code4.becomeFirstResponder()
        case code4: code5.becomeFirstResponder()
        case code5: code6.becomeFirstResponder()
        default: textField.resignFirstResponder()
        }
    }
    
}


extension SMSCodeViewController {
    private class SMSCodeField: UITextField {
        override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        init() {
            super.init(frame: .zero)
            config()
        }
        
        private func config(){
            textAlignment = .center
            autocapitalizationType = .none
            autocorrectionType = .no
            returnKeyType = .continue
            layer.cornerRadius = 5
            layer.borderWidth = 1
            layer.borderColor = UIColor.zipLightGray.cgColor
            backgroundColor = .zipLightGray
            font = .zipBody.withSize(30)
            tintColor = .white
            textColor = .white
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        if text.count >= 1 {
            textField.text = ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 1
        let currentString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        if newString.count <= maxLength {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
        
        return false
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
