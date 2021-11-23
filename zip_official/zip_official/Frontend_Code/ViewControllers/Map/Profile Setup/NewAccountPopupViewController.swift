//
//  NewAccountPopupViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 11/2/21.
//

import UIKit

protocol NewAccountDelegate {
    func completeProfile()
}

class NewAccountPopupViewController: UIViewController {
    var delegate: NewAccountDelegate?
    
    let outlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .zipGray
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "COMPLETE YOUR PROFILE"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .zipBodyBold
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Personalize your profile by adding more pictures, a bio, interests, school, and more!"
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .zipBodyBold.withSize(16)
        return label
    }()
    
    private let completeProfileButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("GO TO MY\nPROFILE", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.lineBreakMode = .byWordWrapping
        btn.titleLabel?.textAlignment = .center

        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold.withSize(18)
        return btn
    }()
    
    private let finishLaterButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Finish Later", for: .normal)
        btn.backgroundColor = .clear
        btn.setTitleColor(.zipVeryLightGray, for: .normal)

        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        let underlineAttributedString = NSAttributedString(string: "StringWithUnderLine", attributes: underlineAttribute)
        btn.titleLabel?.attributedText = underlineAttributedString
        
        
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold.withSize(16)
        return btn
    }()
    
    @objc private func didTapFinishLater(){
        dismiss(animated: true)
    }
    
    @objc private func didTapGoToProfile(){
        let vc = CompleteProfileViewController()

        vc.user.userId = AppDelegate.userDefaults.value(forKey: "userId") as! String
        vc.user.username = AppDelegate.userDefaults.value(forKey: "username") as! String
        vc.user.firstName = AppDelegate.userDefaults.value(forKey: "firstName") as! String
        vc.user.lastName = AppDelegate.userDefaults.value(forKey: "lastName") as! String
        vc.user.birthday = AppDelegate.userDefaults.value(forKey: "birthday") as! Date


        guard let urlString = AppDelegate.userDefaults.value(forKey: "profilePictureUrl") as? String,
              let url = URL(string: urlString) else {
            return
        }
        
        
        let getDataTask = URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                vc.user.pictures.append(UIImage(data: data) ?? UIImage())
                vc.collectionView?.reloadData()
            }
            
        })
        getDataTask.resume()
        
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: {
            
            
        })
//        delegate?.completeProfile()
//        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.isOpaque = false
        finishLaterButton.addTarget(self, action: #selector(didTapFinishLater), for: .touchUpInside)
        completeProfileButton.addTarget(self, action: #selector(didTapGoToProfile), for: .touchUpInside)

        addSubviews()
    }
    
    private func addSubviews(){
        view.addSubview(outlineView)
        outlineView.addSubview(titleLabel)
        outlineView.addSubview(descriptionLabel)
        outlineView.addSubview(completeProfileButton)
        outlineView.addSubview(finishLaterButton)
    }
    
    
    override func viewDidLayoutSubviews() {
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        outlineView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        outlineView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -100).isActive = true
        outlineView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: finishLaterButton.bottomAnchor, constant: 20).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 20).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: outlineView.widthAnchor, constant: -10).isActive = true

        completeProfileButton.translatesAutoresizingMaskIntoConstraints = false
        completeProfileButton.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true
        completeProfileButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20).isActive = true
        completeProfileButton.widthAnchor.constraint(equalTo: outlineView.widthAnchor, constant: -100).isActive = true
        
        finishLaterButton.translatesAutoresizingMaskIntoConstraints = false
        finishLaterButton.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true
        finishLaterButton.topAnchor.constraint(equalTo: completeProfileButton.bottomAnchor, constant: 20).isActive = true

    }
    
    



}
