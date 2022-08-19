//
//  ProfilePicSetupViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/27/21.
//

import UIKit
import UIImageCropper
import JGProgressHUD

class ProfilePicSetupViewController: UIViewController {
    var user = User()
    
    let spinner = JGProgressHUD(style: .light)
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
    
    private let picBackground: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.zipBlue.cgColor
        view.layer.borderWidth = 3
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true

        let camera = UIImageView(image: UIImage(systemName: "camera")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray))
        
        camera.contentMode = .scaleAspectFill
        view.addSubview(camera)
        
        camera.translatesAutoresizingMaskIntoConstraints = false
        camera.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        camera.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        camera.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true

        return view
    }()
    
    
    private let profilePic: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
        view.layer.masksToBounds = true
        return view
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
        label.text = "STEP 2"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(12)
        return label
    }()
    
    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "PROFILE PICTURE"
        label.textColor = .white
        label.font = .zipBodyBold.withSize(22)
        return label
    }()
    
    private let pageStatus2: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus3 = StatusCheckView()
    
    private let picErrorLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold.withSize(12)
        label.textColor = .white
        label.text = "You must have a profile picture to use Zipper"
        return label
    }()
    
    
    @objc private func didTapContinueButton(){
        guard let pic = profilePic.image else {
            picErrorLabel.isHidden = false
            return
        }
        picErrorLabel.isHidden = true
        // push to final setup page
        user.pictures.append(pic)
        user.picNum = 0
        
        spinner.show(in: view)
        DatabaseManager.shared.insertUser(with: user, completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil  else {
                let actionSheet = UIAlertController(title: "Failed to create User Profile",
                                                    message: "Try again later",
                                                    preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "Continue",
                                                    style: .cancel,
                                                    handler: nil))
                
                self?.present(actionSheet, animated: true)
                return
            }
            let vc = PermissionsSetupViewController()
            vc.user = strongSelf.user
            strongSelf.navigationController?.pushViewController(vc, animated: true)
        })
    }
    
    @objc private func didTapProfilePicture(){
        presentPhotoActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
//        title = "REGISTRATION"
        navigationController?.navigationBar.isHidden = true
        picErrorLabel.isHidden = true
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        picBackground.addGestureRecognizer(tap)
        
        addSubviews()
    }
    
    private func addSubviews(){
        view.addSubview(scrollView)
        scrollView.addSubview(logo)
        scrollView.addSubview(createAnAccountLabel)
        scrollView.addSubview(stepLabel)
        scrollView.addSubview(stepTitleLabel)
        scrollView.addSubview(picBackground)
        picBackground.addSubview(profilePic)
        scrollView.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)
        scrollView.addSubview(picErrorLabel)
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.frame = view.bounds
        
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.35).isActive = true
        logo.heightAnchor.constraint(equalTo: logo.widthAnchor).isActive = true
        
        createAnAccountLabel.translatesAutoresizingMaskIntoConstraints = false
        createAnAccountLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 15).isActive = true
        createAnAccountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        stepLabel.translatesAutoresizingMaskIntoConstraints = false
        stepLabel.topAnchor.constraint(equalTo: createAnAccountLabel.bottomAnchor, constant: 15).isActive = true
        stepLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        stepTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        stepTitleLabel.topAnchor.constraint(equalTo: stepLabel.bottomAnchor, constant: 0).isActive = true
        stepTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        picBackground.translatesAutoresizingMaskIntoConstraints = false
        picBackground.topAnchor.constraint(equalTo: stepTitleLabel.bottomAnchor, constant: 20).isActive = true
        picBackground.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        picBackground.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5).isActive = true
        picBackground.heightAnchor.constraint(equalTo: picBackground.widthAnchor).isActive = true
        
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        profilePic.topAnchor.constraint(equalTo: picBackground.topAnchor).isActive = true
        profilePic.bottomAnchor.constraint(equalTo: picBackground.bottomAnchor).isActive = true
        profilePic.rightAnchor.constraint(equalTo: picBackground.rightAnchor).isActive = true
        profilePic.leftAnchor.constraint(equalTo: picBackground.leftAnchor).isActive = true

        picErrorLabel.translatesAutoresizingMaskIntoConstraints = false
        picErrorLabel.centerXAnchor.constraint(equalTo: picBackground.centerXAnchor).isActive = true
        picErrorLabel.topAnchor.constraint(equalTo: picBackground.bottomAnchor, constant: 5).isActive = true
        
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.topAnchor.constraint(equalTo: picBackground.bottomAnchor, constant: 40).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.67, constant: -60).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalToConstant: 10).isActive = true
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
        
        pageStatus1.layer.cornerRadius = 5
        pageStatus2.layer.cornerRadius = 5
        pageStatus3.layer.cornerRadius = 5
        
        picBackground.layer.cornerRadius = view.frame.width/4
        profilePic.layer.cornerRadius = view.frame.width/4
    }
}


extension ProfilePicSetupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
//        let cropper = UIImageCropper(cropRatio: 2/3)
//        cropper.picker = vc
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
        
        profilePic.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
