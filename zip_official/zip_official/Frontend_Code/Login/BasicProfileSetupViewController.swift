//
//  BasicProfileSetupViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/26/21.
//

import UIKit
import JGProgressHUD
import SwiftUI


class BasicProfileSetupViewController: UIViewController {
    
    private var allUsernames: [String] = []
    
    var user = User()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let logo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "zipperLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "FIRST NAME",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                      NSAttributedString.Key.font: UIFont.zipBodyBold])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.textAlignment = .center
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        field.font = .zipBodyBold

        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "LAST NAME",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                      NSAttributedString.Key.font: UIFont.zipBodyBold])

        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.textAlignment = .center
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        field.font = .zipBodyBold

        return field
    }()
    
    private let usernameField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.autocapitalizationType = .none
        
        field.autocorrectionType = .no
        
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "USERNAME",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                      NSAttributedString.Key.font: UIFont.zipBodyBold])

        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let atSign = UILabel()
        atSign.text = "@"
        atSign.font = .zipBodyBold
        atSign.textColor = .zipVeryLightGray
        atSign.textAlignment = .center
        view.addSubview(atSign)
        atSign.frame = CGRect(x: 10, y: 0, width: 24, height: 30)
        
        field.leftView = view
        field.leftViewMode = .always
        
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        field.rightViewMode = .always
        field.rightView = view2
        
        
        field.textAlignment = .center
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        field.font = .zipBodyBold

        return field
    }()
    
    private let birthdayField: UITextField = {
        let field = UITextField()
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 15
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "BIRTHDAY",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                      NSAttributedString.Key.font: UIFont.zipBodyBold])

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let calendar = UIImageView()
        calendar.image = UIImage(named: "events")?.withTintColor(.zipVeryLightGray)
        view.addSubview(calendar)
        calendar.frame = CGRect(x: 10, y: 3, width: 24, height: 24)
        
        field.leftView = view
        field.leftViewMode = .always
        
        let view2 = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        field.rightViewMode = .always
        field.rightView = view2
        
        field.textAlignment = .center
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        field.font = .zipBodyBold
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.date = Date(timeIntervalSinceNow: -536500000) // 17 years
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)


        field.inputView = datePicker

        return field
    }()
    
    private let continueButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("CONTINUE", for: .normal)
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
        label.text = "STEP 1"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(12)
        return label
    }()
    
    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "CREATE YOUR PROFILE"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(22)
        return label
    }()
    
    private let status1 = StatusCheckView()
    private let status2 = StatusCheckView()
    private let status3 = StatusCheckView()
    private let status4 = StatusCheckView()

    private let pageStatus1: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus2 = StatusCheckView()
    private let pageStatus3 = StatusCheckView()
    
    private let usernameErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold.withSize(12)
        label.textColor = .white
        label.text = "This username has already been taken"
        return label
    }()
    
    private let birthdayErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold.withSize(12)
        label.textColor = .white
        label.text = "You must be 17 years or older to use Zipper"
        return label
    }()
    
    
    @objc private func didTapContinueButton(){
        if  status1.status == .accept,
            status2.status == .accept,
            status3.status == .accept,
            status3.status == .accept  {
            
            guard let username = usernameField.text,
                  let firstName = firstNameField.text,
                  let lastName = lastNameField.text,
                  birthday != Date() else {
                      return
                  }
            
//            user.userId = "TestTestTest"
            user.username = username
            user.firstName = firstName
            user.lastName = lastName
            user.birthday = birthday
            

            let vc = ProfilePicSetupViewController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    var birthday = Date()
    
    @objc func dateChanged(sender: UIDatePicker){
        birthday = sender.date

        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        birthdayField.text = formatter.string(from: sender.date)
        
        if birthday > Date(timeIntervalSinceNow: -536500000) {
            status4.reject()
            birthdayErrorLabel.isHidden = false
        } else {
            status4.accept()
            birthdayErrorLabel.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        title = "REGISTRATION"
        navigationController?.navigationBar.isHidden = true

        view.backgroundColor = .zipGray
        firstNameField.delegate = self
        lastNameField.delegate = self
        usernameField.delegate = self
        birthdayField.delegate = self

        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        usernameErrorLabel.isHidden = true
        birthdayErrorLabel.isHidden = true
        
        getAllUsernames()
        
        addSubviews()
    }
    
    
    private func getAllUsernames(){
        allUsernames = []
    }
    
    
    
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(createAnAccountLabel)
        scrollView.addSubview(stepLabel)
        scrollView.addSubview(stepTitleLabel)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(birthdayField)
        scrollView.addSubview(continueButton)
        scrollView.addSubview(status1)
        scrollView.addSubview(status2)
        scrollView.addSubview(status3)
        scrollView.addSubview(status4)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)
        scrollView.addSubview(usernameErrorLabel)
        scrollView.addSubview(birthdayErrorLabel)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
        
        let tfHeight = CGFloat(30)
        let tfSpacing = CGFloat(28)
        
        createAnAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        createAnAccountLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 15).isActive = true
        createAnAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.topAnchor.constraint(equalTo: createAnAccountLabel.bottomAnchor, constant: 15).isActive = true
        stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stepTitleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 0).isActive = true
        stepTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true


        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        firstNameField.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: tfSpacing).isActive = true
        firstNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstNameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -90).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
        
        lastNameField.translatesAutoresizingMaskIntoConstraints = false
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: tfSpacing).isActive = true
        lastNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lastNameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -90).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
        
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: tfSpacing).isActive = true
        usernameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -90).isActive = true
        usernameField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
        
        birthdayField.translatesAutoresizingMaskIntoConstraints = false
        birthdayField.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: tfSpacing).isActive = true
        birthdayField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        birthdayField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -90).isActive = true
        birthdayField.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.topAnchor.constraint(equalTo: birthdayField.bottomAnchor, constant: 40).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: birthdayField.widthAnchor, multiplier: 0.67).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: tfHeight).isActive = true
        
        usernameErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameErrorLabel.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 3).isActive = true
        usernameErrorLabel.leftAnchor.constraint(equalTo: usernameField.leftAnchor).isActive = true
        
        birthdayErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        birthdayErrorLabel.topAnchor.constraint(equalTo: birthdayField.bottomAnchor, constant: 3).isActive = true
        birthdayErrorLabel.leftAnchor.constraint(equalTo: birthdayField.leftAnchor).isActive = true
        
        let statusHeightMult = CGFloat(0.5)

        status1.translatesAutoresizingMaskIntoConstraints = false
        status1.leftAnchor.constraint(equalTo: firstNameField.rightAnchor, constant: 10).isActive = true
        status1.centerYAnchor.constraint(equalTo: firstNameField.centerYAnchor).isActive = true
        status1.heightAnchor.constraint(equalTo: firstNameField.heightAnchor, multiplier: statusHeightMult).isActive = true
        status1.widthAnchor.constraint(equalTo: status1.heightAnchor).isActive = true

        status2.translatesAutoresizingMaskIntoConstraints = false
        status2.leftAnchor.constraint(equalTo: lastNameField.rightAnchor, constant: 10).isActive = true
        status2.centerYAnchor.constraint(equalTo: lastNameField.centerYAnchor).isActive = true
        status2.heightAnchor.constraint(equalTo: lastNameField.heightAnchor, multiplier: statusHeightMult).isActive = true
        status2.widthAnchor.constraint(equalTo: status2.heightAnchor).isActive = true

        status3.translatesAutoresizingMaskIntoConstraints = false
        status3.leftAnchor.constraint(equalTo: usernameField.rightAnchor, constant: 10).isActive = true
        status3.centerYAnchor.constraint(equalTo: usernameField.centerYAnchor).isActive = true
        status3.heightAnchor.constraint(equalTo: usernameField.heightAnchor, multiplier: statusHeightMult).isActive = true
        status3.widthAnchor.constraint(equalTo: status3.heightAnchor).isActive = true

        status4.translatesAutoresizingMaskIntoConstraints = false
        status4.leftAnchor.constraint(equalTo: birthdayField.rightAnchor, constant: 10).isActive = true
        status4.centerYAnchor.constraint(equalTo: birthdayField.centerYAnchor).isActive = true
        status4.heightAnchor.constraint(equalTo: birthdayField.heightAnchor, multiplier: statusHeightMult).isActive = true
        status4.widthAnchor.constraint(equalTo: status4.heightAnchor).isActive = true
        
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalTo: status1.heightAnchor, multiplier: 0.67).isActive = true
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
        
        status1.layer.cornerRadius = tfHeight/2*statusHeightMult
        status2.layer.cornerRadius = tfHeight/2*statusHeightMult
        status3.layer.cornerRadius = tfHeight/2*statusHeightMult
        status4.layer.cornerRadius = tfHeight/2*statusHeightMult
        
        pageStatus1.layer.cornerRadius = tfHeight/2*statusHeightMult*0.67
        pageStatus2.layer.cornerRadius = tfHeight/2*statusHeightMult*0.67
        pageStatus3.layer.cornerRadius = tfHeight/2*statusHeightMult*0.67
    }
}


extension BasicProfileSetupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == firstNameField {
            guard let text = textField.text else {
                status1.clear()
                return
            }
            
            if !text.isEmpty {
                status1.accept()
            } else {
                status1.clear()
            }
            
        } else if textField == lastNameField {
            guard let text = textField.text else {
                status2.clear()
                return
            }
            
            if !text.isEmpty {
                status2.accept()
            } else {
                status2.clear()
            }
            
        } else if textField == usernameField {

            guard let text = textField.text else {
                status3.clear()
                return
            }
            textField.text = text.lowercased()
            
            if allUsernames.contains(text) {
                status3.reject()
                usernameErrorLabel.isHidden = false
               
            } else {
      
                status3.accept()
                usernameErrorLabel.isHidden = true
                
            }
            
        } else if textField == birthdayField {
            guard textField.text != nil else {
                status4.clear()
                return
            }
        }


    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString = (textField.text ?? "") as NSString
        let str = currentString.replacingCharacters(in: range, with: string)
        if textField == usernameField {
            if str.count > 20 { return false }
            let ACCEPTABLE_CHARACTERS = "abcdefghijklmnopqrstuvwxyz0123456789_."
            return checkAcceptable(string: string, acceptableChars: ACCEPTABLE_CHARACTERS)
        } else if textField == firstNameField || textField == lastNameField {
            if str.count > 20 { return false }
            let ACCEPTABLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-"
            return checkAcceptable(string: string, acceptableChars: ACCEPTABLE_CHARACTERS)
        }
        return true
    }
    
    func checkAcceptable(string: String, acceptableChars: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: acceptableChars).inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
}


/*
 CHARACTER LIMITS
 First Name: 15
 Last Name: 15
 Bio: 300
 Event Title: 30
 Event Description: 300
 Username: 20
 */
