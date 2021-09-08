//
//  ChangeUsernameViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/18/21.
//

import UIKit

class ChangeUsernameViewController: UIViewController {
    var headerView = UIView()
    
    var changeUsername: UITextField = {
        let textField = UITextField()
//        textField.isSecureTextEntry = true
        textField.backgroundColor = .zipLightGray
        textField.placeholder = "New Username"
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
        label.text = "Change Username"
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
        
        view.addSubview(changeUsername)
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
        changeUsername.translatesAutoresizingMaskIntoConstraints = false
        changeUsername.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        changeUsername.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        changeUsername.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true

        //Error Label
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.topAnchor.constraint(equalTo: changeUsername.bottomAnchor, constant: 10).isActive = true
        errorLabel.leftAnchor.constraint(equalTo: changeUsername.leftAnchor).isActive = true
        errorLabel.rightAnchor.constraint(equalTo: changeUsername.rightAnchor).isActive = true
        
        //Confirm Button
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.topAnchor.constraint(equalTo: changeUsername.bottomAnchor, constant: 30).isActive = true
        confirmButton.leftAnchor.constraint(equalTo: changeUsername.leftAnchor).isActive = true
        confirmButton.rightAnchor.constraint(equalTo: changeUsername.rightAnchor).isActive = true
    }

}

    



