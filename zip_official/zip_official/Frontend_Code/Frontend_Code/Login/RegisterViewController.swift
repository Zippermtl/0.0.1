//
//  RegisterViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/5/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    private let spinner = JGProgressHUD(style: .light)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle")
        imageView.tintColor = .zipVeryLightGray
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.zipVeryLightGray.cgColor
        return imageView
    }()
    
    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "First Name...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        return field
    }()
    
    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Last Name...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white

        return field
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Username/Email Address...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white

        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.zipLightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Password...",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        field.isSecureTextEntry = true
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white

        return field
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Register", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold.withSize(20)
        return btn
    }()
    
    
    @objc private func didTapRegister(){
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRegisterButton(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              !firstName.isEmpty,
              !lastName.isEmpty,
              password.count >= 6 else {
            return
        }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard !exists else {
                //user already exists
                strongSelf.alertUserLoginError(message: "A user account for that email already exists")
                return
            }
            
            //Firebase register
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {authResult, error in
            
            

                guard authResult != nil, error == nil else {
                    print("error creating user")
                    return
                }
                
                let user = User(email: email,
                               firstName: firstName,
                               lastName: lastName)
                
                // Cash email and name
                AppDelegate.userDefaults.set(email, forKey: "email")
                AppDelegate.userDefaults.set(user.fullName, forKey: "name")

                //Set default ring values
                AppDelegate.userDefaults.setValue(2000, forKey: "BlueRing")
                AppDelegate.userDefaults.setValue(5000, forKey: "GreenRing")
                AppDelegate.userDefaults.setValue(10000, forKey: "PinkRing")
                
                DatabaseManager.shared.insertUser(with: user, completion: { success in
                    if success {
                        //upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        
                        let fileName = user.profilePictureFileName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: fileName, completion: { results in
                            switch results {
                            case .success(let downloadUrl):
                                AppDelegate.userDefaults.set(downloadUrl, forKey: "profilePictureUrl")
                                print(downloadUrl)
                            case .failure(let error):
                                print("Storage Manager Error: \(error)")
                            }
                            
                        })
                    }
                    
                })
                
                
                if let topVC = strongSelf.navigationController?.viewControllers.first as? LoginViewController {
                    topVC.locationDelegate?.startLocationTracking()
                } else {
                    print("failed to start location updates from Registration")
                }
                
                
                strongSelf.dismiss(animated: true, completion: nil)
     
            })

        })
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create a new account") {
        let alert = UIAlertController(title: "Whoops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
        print("change profile pic")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray

        emailField.delegate = self
        passwordField.delegate = self
        registerButton.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        
        imageView.addGestureRecognizer(gesture)
        
        addSubviews()
    }
    
    
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        firstNameField.translatesAutoresizingMaskIntoConstraints = false
        firstNameField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        firstNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        firstNameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        lastNameField.translatesAutoresizingMaskIntoConstraints = false
        lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 10).isActive = true
        lastNameField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        lastNameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        lastNameField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        emailField.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 10).isActive = true
        emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 10).isActive = true
        passwordField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 10).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1, constant: -20).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            didTapRegisterButton()
        }
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take a Photo with Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose a Photo From Photo Library",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                                self?.presentPhotoPicker()
        }))
        
        present(actionSheet, animated: true)

    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
