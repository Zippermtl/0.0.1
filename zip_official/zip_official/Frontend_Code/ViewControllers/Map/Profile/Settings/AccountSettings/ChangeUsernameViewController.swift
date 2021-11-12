//
//  ChangeUsernameViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/18/21.
//

import UIKit

class ChangeUsernameViewController: UIViewController {
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
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.layer.isHidden = true
        
        return label
    }()

    
    
    //MARK: - Buttons
    
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
    
    @objc private func didTapConfirmButton(){

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.title = "Change Username"
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Header Config

    
    //MARK: - Add Subviews
    private func addSubviews(){
        // Header
        view.addSubview(changeUsername)
        view.addSubview(errorLabel)
        view.addSubview(confirmButton)
    }
    
    //MARK: Layout Subviews
    private func configureSubviewLayout() {
       
        // Text Fields
        changeUsername.translatesAutoresizingMaskIntoConstraints = false
        changeUsername.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
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

    



