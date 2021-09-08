//
//  ChangePasswordViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    //MARK: - Subviews
    var headerView = UIView()
    
    var oldPassword: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = .zipLightGray
        textField.placeholder = "Old Password"
        textField.textColor = .zipVeryLightGray
        textField.font = .zipBody
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.borderStyle = .roundedRect
        textField.tintColor = .white
        
        return textField
    }()
    
    var newPassword: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = .zipLightGray
        textField.placeholder = "New Password"
        textField.textColor = .zipVeryLightGray
        textField.font = .zipBody
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.borderStyle = .roundedRect
        textField.tintColor = .white

        return textField
    }()
    
    var confirmPassword: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.backgroundColor = .zipLightGray
        textField.placeholder = "Confirm New Password"
        textField.textColor = .zipVeryLightGray
        textField.font = .zipBody
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.borderStyle = .roundedRect
        textField.tintColor = .white

        
        return textField
    }()


    //MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "SETTINGS"
        return label
    }()
    
    private var pageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "Change Password"
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.layer.isHidden = true
        
        
        
        
        
        
        return label
    }()

    
    
    //MARK: - Buttons
    let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backarrow"), for: .normal)
        btn.addTarget(self, action: #selector(didTapBackButton), for: .touchDown)
        return btn
    }()
    
    var confirmButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .zipBlue
        btn.setTitle("CONFIRM", for: .normal)
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textColor = .white
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(didTapConfirmButton), for: .touchDown)
        return btn
    }()
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)

    }
    
    @objc private func didTapConfirmButton(){
//        if oldPassword.text != getPassword(){
//            errorLabel.text = "Your passwords is incorrect"
//            errorLabel.isHidden = false
//        } else {

        if newPassword.text == confirmPassword.text {
            //update password in backend
        } else {
            errorLabel.text = "Your passwords must match"
            errorLabel.isHidden = false
            
        }

//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        configureHeader()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Header Config
    private func configureHeader(){
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/6)
        headerView.backgroundColor = .zipGray
    }
    
    //MARK: - Add Subviews
    private func addSubviews(){
        // Header
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(backButton)
        headerView.addSubview(pageSubtitleLabel)
        
        view.addSubview(oldPassword)
        view.addSubview(newPassword)
        view.addSubview(confirmPassword)
        view.addSubview(errorLabel)
        view.addSubview(confirmButton)



        
    }
    
    //MARK: Layout Subviews
    private func configureSubviewLayout() {
        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        // Page Subtitle
        pageSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageSubtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        pageSubtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true

        // Back Button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalTo: pageTitleLabel.heightAnchor).isActive = true
        backButton.heightAnchor.constraint(equalTo: backButton.widthAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
        
        // Text Fields
        oldPassword.translatesAutoresizingMaskIntoConstraints = false
        oldPassword.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        oldPassword.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        oldPassword.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true

        newPassword.translatesAutoresizingMaskIntoConstraints = false
        newPassword.topAnchor.constraint(equalTo: oldPassword.bottomAnchor, constant: 10).isActive = true
        newPassword.leftAnchor.constraint(equalTo: oldPassword.leftAnchor).isActive = true
        newPassword.rightAnchor.constraint(equalTo: oldPassword.rightAnchor).isActive = true
        
        confirmPassword.translatesAutoresizingMaskIntoConstraints = false
        confirmPassword.topAnchor.constraint(equalTo: newPassword.bottomAnchor, constant: 10).isActive = true
        confirmPassword.leftAnchor.constraint(equalTo: oldPassword.leftAnchor).isActive = true
        confirmPassword.rightAnchor.constraint(equalTo: oldPassword.rightAnchor).isActive = true
        
        //Error Label
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.topAnchor.constraint(equalTo: confirmPassword.bottomAnchor, constant: 10).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: oldPassword.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: oldPassword.rightAnchor).isActive = true
        
        //Confirm Button
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.topAnchor.constraint(equalTo: confirmPassword.bottomAnchor, constant: 50).isActive = true
        confirmButton.leftAnchor.constraint(equalTo: oldPassword.leftAnchor).isActive = true
        confirmButton.rightAnchor.constraint(equalTo: oldPassword.rightAnchor).isActive = true
    }

}


extension ChangePasswordViewController: UITextFieldDelegate {
    
}
