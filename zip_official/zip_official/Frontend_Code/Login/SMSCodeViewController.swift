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
    var user: User
    var number: String
    private let spinner = JGProgressHUD(style: .light)
    

    private let stepLabel: UILabel
    private let titleLabel: UILabel
    private let explanationLabel: UILabel
    
//    private let SMSCodeStack: UIStackView
    
//    private let code1 : SMSCodeField
//    private let code2 : SMSCodeField
//    private let code3 : SMSCodeField
//    private let code4 : SMSCodeField
//    private let code5 : SMSCodeField
//    private let code6 : SMSCodeField
    
    private let smsField: UITextField
    
    private let confirmButton: UIButton
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus2: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    init(user: User, number: String) {
        self.number = number
        self.user = user
        stepLabel = UILabel.zipSubtitle()
        titleLabel = UILabel.zipHeader()
        explanationLabel = UILabel.zipTextDetail()
        
//        SMSCodeStack = UIStackView()
        confirmButton = UIButton()
        smsField = UITextField()
//        code1 = SMSCodeField()
//        code2 = SMSCodeField()
//        code3 = SMSCodeField()
//        code4 = SMSCodeField()
//        code5 = SMSCodeField()
//        code6 = SMSCodeField()
        super.init(nibName: nil, bundle: nil)
        smsField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        smsField.textContentType = .oneTimeCode
        let dismissKeyboardTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(dismissKeyboardTap)
        
        
        stepLabel.text = "Step 2"
        titleLabel.text = "Verify Your Phone Number"
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        
        let string              = "Didn't receive a text? Resend my verification code."
        let range               = (string as NSString).range(of: "Resend my verification code.")
        let attributedString    = NSMutableAttributedString(string: string)

        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: 1), range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white, range: range)
        explanationLabel.attributedText = attributedString
        
        explanationLabel.text = "Didn't receive a text? Resend my verification code."
        explanationLabel.lineBreakMode = .byWordWrapping
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.isUserInteractionEnabled = true
        
        let explanationTap = UITapGestureRecognizer(target: self, action: #selector(didTapResendVerificationCode))
        explanationLabel.addGestureRecognizer(explanationTap)
        
//        SMSCodeStack.axis = .horizontal
//        SMSCodeStack.distribution = .equalSpacing
//        SMSCodeStack.spacing = 15
//        SMSCodeStack.alignment = .center
        
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.backgroundColor = .zipBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.layer.masksToBounds = true
        confirmButton.titleLabel?.font = .zipSubtitle
        
        view.backgroundColor = .zipGray
//        code1.delegate = self
//        code2.delegate = self
//        code3.delegate = self
//        code4.delegate = self
//        code5.delegate = self
//        code6.delegate = self
        
//        code1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        code2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        code3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        code4.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        code5.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//        code6.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        confirmButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        smsField.keyboardType = .numberPad
        smsField.borderStyle = .roundedRect
        smsField.backgroundColor = .zipLightGray
        smsField.tintColor = .white
        smsField.textColor = .white
        smsField.textAlignment = .center
        smsField.delegate = self
//        code1.keyboardType = .numberPad
//        code2.keyboardType = .numberPad
//        code3.keyboardType = .numberPad
//        code4.keyboardType = .numberPad
//        code5.keyboardType = .numberPad
//        code6.keyboardType = .numberPad
        
        addSubviews()
        configureSubviewLayout()
        addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        smsField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        smsField.resignFirstResponder()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapResendVerificationCode(){
        DatabaseManager.shared.startAuth(phoneNumber: number, completion: { [weak self] error in
            guard error == nil else {
                self?.alert(error: error!)
                return
            }
        })
    }
    
    @objc private func textDidChange() {
        guard let text = smsField.text else {
            return
        }
        if text.count == 6 {
            smsField.resignFirstResponder()
        }
    }
    
    @objc private func didTapLoginButton(){
//        code1.resignFirstResponder()
//        code2.resignFirstResponder()
//        code3.resignFirstResponder()
//        code4.resignFirstResponder()
//        code5.resignFirstResponder()
//        code6.resignFirstResponder()
        smsField.resignFirstResponder()

        guard let smsCode = getSMSCode(),
                            !smsCode.isEmpty else {
            return
        }
        
        loginOrRegister(smsCode: smsCode)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    private func addSubviews(){
//        view.addSubview(SMSCodeStack)
//        SMSCodeStack.addArrangedSubview(code1)
//        SMSCodeStack.addArrangedSubview(code2)
//        SMSCodeStack.addArrangedSubview(code3)
//        SMSCodeStack.addArrangedSubview(code4)
//        SMSCodeStack.addArrangedSubview(code5)
//        SMSCodeStack.addArrangedSubview(code6)
        view.addSubview(smsField)
        view.addSubview(confirmButton)
        view.addSubview(stepLabel)
        view.addSubview(titleLabel)
        view.addSubview(explanationLabel)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
    }
    
    private func configureSubviewLayout() {
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stepLabel.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -5).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 125).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.5).isActive = true
        
//        SMSCodeStack.translatesAutoresizingMaskIntoConstraints = false
//        SMSCodeStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//        SMSCodeStack.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 30).isActive = true
//        SMSCodeStack.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -30).isActive = true
//        SMSCodeStack.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        smsField.translatesAutoresizingMaskIntoConstraints = false
        smsField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        smsField.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 30).isActive = true
        smsField.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -30).isActive = true
        smsField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        explanationLabel.translatesAutoresizingMaskIntoConstraints = false
        explanationLabel.topAnchor.constraint(equalTo: smsField.bottomAnchor,constant: 20).isActive = true
        explanationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        explanationLabel.widthAnchor.constraint(equalTo: view.widthAnchor,multiplier: 0.7).isActive = true
        
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.bottomAnchor.constraint(equalTo: pageStatus1.topAnchor, constant: -35).isActive = true
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        confirmButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pageStatus1.translatesAutoresizingMaskIntoConstraints = false
        pageStatus1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,constant: -5).isActive = true
        pageStatus1.heightAnchor.constraint(equalToConstant: 10).isActive = true
        pageStatus1.widthAnchor.constraint(equalTo: pageStatus1.heightAnchor).isActive = true
        pageStatus1.rightAnchor.constraint(equalTo: view.centerXAnchor,constant: -5).isActive = true
        
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.centerYAnchor.constraint(equalTo: pageStatus1.centerYAnchor).isActive = true
        pageStatus2.widthAnchor.constraint(equalTo: pageStatus1.widthAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalTo: pageStatus1.heightAnchor).isActive = true
        pageStatus2.leftAnchor.constraint(equalTo: view.centerXAnchor,constant: 5).isActive = true
        
        pageStatus1.layer.cornerRadius = 5
        pageStatus2.layer.cornerRadius = 5
        
//        code1.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        code2.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
//        code3.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
//        code4.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
//        code5.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
//        code6.widthAnchor.constraint(equalTo: code1.widthAnchor).isActive = true
    }

    
    private func continuteRegistration(){
        let vc = BasicProfileSetupViewController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func loginOrRegister(smsCode: String){
        confirmButton.isEnabled = false
        spinner.show(in: view)
        DatabaseManager.shared.verifyCode(smsCode: smsCode, completion: {[weak self] error in
            guard error == nil,
                  let strongSelf = self else {
                self?.alert(error: error!)
                return
            }
            
            DatabaseManager.shared.userExists(with: strongSelf.user.userId, completion: { [weak self] result in
                switch result {
                case .success(let exists):
                    if exists {
                        //user already exists
                        DatabaseManager.shared.loadUserProfile(given: strongSelf.user, completion: { [weak self] result in
                            switch result {
                            case .success(let user):
                                AppDelegate.userDefaults.set(user.userId, forKey: "userId")
                                AppDelegate.userDefaults.set(user.username, forKey: "username")
                                AppDelegate.userDefaults.set(user.fullName, forKey: "name")
                                AppDelegate.userDefaults.set(user.firstName, forKey: "firstName")
                                AppDelegate.userDefaults.set(user.lastName, forKey: "lastName")
                                AppDelegate.userDefaults.set(user.birthday, forKey: "birthday")
                                AppDelegate.userDefaults.set(user.picNum, forKey: "picNum")
                                if let pfpUrl = user.profilePicUrl {
                                    AppDelegate.userDefaults.set(pfpUrl.absoluteString, forKey: "profilePictureUrl")
                                } else {
                                    AppDelegate.userDefaults.set("", forKey: "profilePictureUrl")
                                }
                                
                                DatabaseManager.shared.loadUserFriendships(given: user.userId, completion: { [weak self] result in
                                    switch result {
                                    case .success(let friendships):
                                        let encoded = EncodeFriendsUserDefaults(friendships)
                                        AppDelegate.userDefaults.set(encoded, forKey: "friendships")
                                        DispatchQueue.main.async {
                                            guard let strongSelf = self else { return }
                                            strongSelf.registerForPushNotifications()
                                            let vc = LoadingViewController()
                                            vc.modalPresentationStyle = .fullScreen
                                            DispatchQueue.main.async {
                                                strongSelf.spinner.dismiss()
                                                strongSelf.confirmButton.isEnabled = true
                                            }
                                            
                                            strongSelf.present(vc, animated: true, completion: nil)
                    
                                        }
                                    case .failure(let error):
                                        strongSelf.alert(error: error)
                                    }
                                })
                            case .failure(let error):
                                strongSelf.alert(error: error)
                            }
                        })
                        
                    } else {
                        //user doens't exist
                        DispatchQueue.main.async {
                            strongSelf.spinner.dismiss()
                        }
                        strongSelf.continuteRegistration()
                    }
                case .failure(let error):
                    strongSelf.alert(error: error)
                }
               
            })
        })
    }
    
    private func alert(error: Error) {
        let alert = UIAlertController(title: "Error",
                                      message: "\(error.localizedDescription)",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: .cancel,
                                      handler: { [weak self] _ in
            self?.confirmButton.isEnabled = true
        }))
        
        present(alert, animated: true)
        spinner.dismiss()
    }
    
    func registerForPushNotifications() {
        //1
        UNUserNotificationCenter.current()
            .requestAuthorization(
                options: [.alert, .sound, .badge]) { [weak self] granted, _ in
                    print("Permission granted: \(granted)")
                    guard granted else { return }
                    self?.getNotificationSettings()
                }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    
    private func getSMSCode() -> String? {
//        var out: String? = code1.text
//        for code in SMSCodeStack.arrangedSubviews {
//
//            guard let c = code as? SMSCodeField,
//                  let text = c.text else {
//                return out
//            }
//
//            if code == code1 { continue }
//
//            out! += text
//        }
        return smsField.text
    }
    
//    @objc private func textFieldDidChange(_ textField: UITextField) {
//        switch textField {
//        case code1:
//            print("1")
//            code2.becomeFirstResponder()
//        case code2:
//            print("2")
//            code3.becomeFirstResponder()
//        case code3:
//            print("3")
//            code4.becomeFirstResponder()
//        case code4:
//            print("4")
//            code5.becomeFirstResponder()
//        case code5:
//            print("5")
//            code6.becomeFirstResponder()
//        default:
//            print("6")
//            textField.resignFirstResponder()
//        }
//    }
    
}


extension SMSCodeViewController {
    internal class SMSCodeField: UITextField {
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
            font = .zipSubtitle2
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
        guard let text = textField.text else { return true }
        if text.count + string.count > 6 { return false }
        
        return true
    }

}
