//
//  PromoterAppViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/27/22.
//

import UIKit
import DropDown
import JGProgressHUD

class PromoterAppViewController: UIViewController {
    let infoLabel : UILabel
    let iAmLabel: UILabel
    let iAmDropDown: DropDown
    let ddButton : UIImageView
    let descLabel: UILabel
    let descTextView: UITextView
    let phoneLabel: UILabel
    let phoneCheckBox: UIButton
    let sendButton: UIButton
    let spinner = JGProgressHUD(style: .light)
    
    var iAmString: String?
    
    init() {
        infoLabel = .zipTextDetail()
        iAmLabel = .zipTextFillBold()
        iAmDropDown = DropDown()
        descLabel = .zipTextFillBold()
        descTextView = UITextView()
        phoneLabel = .zipTextFillBold()
        phoneCheckBox = UIButton()
        sendButton = UIButton()
        ddButton = UIImageView()
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .zipGray
        iAmLabel.text = "   I am a ..."
        descLabel.text = "Why do you want a promoter account"
        phoneLabel.text = "Text me about my application"
        infoLabel.text = "Promoter accounts can create events visible to everyone on the map, have special badges in their profile. They are very exclusive, file your application and you will hear back within 24 hours."
        
        
        infoLabel.textAlignment = .center
        infoLabel.lineBreakMode = .byWordWrapping
        infoLabel.numberOfLines = 0
        
        descTextView.textColor = .white
        descTextView.backgroundColor = .zipLightGray
        descTextView.font = .zipTextFill
        descTextView.layer.cornerRadius = 8
        descTextView.layer.masksToBounds = true
        descTextView.tintColor = .white
        
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        phoneCheckBox.addTarget(self, action: #selector(didTapPhoneCheck), for: .touchUpInside)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.titleLabel?.textAlignment = .center
        sendButton.titleLabel?.font = .zipTextFillBold
        sendButton.backgroundColor = .zipBlue
        sendButton.layer.cornerRadius = 8
        
        phoneCheckBox.setImage(UIImage(systemName: "checkmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .selected)
        phoneCheckBox.backgroundColor = .zipLightGray
        phoneCheckBox.layer.cornerRadius = 8
        
        ddButton.image = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(openDD))
        let chevronTap = UITapGestureRecognizer(target: self, action: #selector(openDD))
        ddButton.isUserInteractionEnabled = true
        ddButton.addGestureRecognizer(chevronTap)
        iAmLabel.isUserInteractionEnabled = true
        iAmLabel.addGestureRecognizer(labelTap)
        iAmLabel.backgroundColor = .zipLightGray
        iAmLabel.layer.cornerRadius = 8
        iAmLabel.layer.masksToBounds = true
        iAmDropDown.anchorView = iAmLabel
        iAmDropDown.dismissMode = .onTap
        iAmDropDown.direction = .bottom
        iAmDropDown.dataSource = ["Individual Promoter", "Business", "Venu", "DJ","Other (will specify in application)"]
        iAmDropDown.textFont = .zipSubtitle2
        iAmDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            iAmString = iAmDropDown.dataSource[index]
            iAmLabel.text = "   I am a " + iAmDropDown.dataSource[index]
        }
       
        
        addSubviews()
        configureSubviewLayout()
        setupKeyboardHiding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func openDD(){
        iAmDropDown.show()
    }
    
    @objc private func didTapPhoneCheck() {
        phoneCheckBox.isSelected = !phoneCheckBox.isSelected
//        phoneCheckBox.setNeedsLayout()
//        phoneCheckBox.layoutIfNeeded()
    }
    
    @objc private func didTapSendButton() {
        spinner.show(in: view)
        DatabaseManager.shared.applyForPromoter(accountType: iAmString, reason: descTextView.text, recieveTexts: phoneCheckBox.isSelected, completion: { [weak self] error in
            guard let strongSelf = self,
                  error == nil else {
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                    let alert = UIAlertController(title: "Erorr", message: "Your internet connection is unstable", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Continue", style: .cancel))
                    self?.present(alert, animated: true)
                }
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
                strongSelf.navigationController?.popViewController(animated: true)
            }
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Promoter Application"
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        scrollView.updateContentView()
//    }
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    var originalY : CGFloat?
    @objc private func keyboardWillShow(sender: NSNotification) {
        originalY = view.frame.origin.y
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextView else {
            return
        }
        
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + convertedTextFieldFrame.size.height
        
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 2) * -1
            view.frame.origin.y = newFrameY
        }
    }
    
    @objc private func keyboardWillHide(notification : NSNotification) {
        if let originalY = originalY {
            view.frame.origin.y = originalY
        }
    }

    private func addSubviews() {
        view.addSubview(infoLabel)
        view.addSubview(iAmLabel)
        iAmLabel.addSubview(ddButton)
        view.addSubview(descLabel)
        view.addSubview(descTextView)
        view.addSubview(phoneLabel)
        view.addSubview(phoneCheckBox)
        view.addSubview(sendButton)
    }

    private func configureSubviewLayout() {
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 10).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        infoLabel.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -10).isActive = true
        
        iAmLabel.translatesAutoresizingMaskIntoConstraints = false
        iAmLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        iAmLabel.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -10).isActive = true
        iAmLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor,constant: 10).isActive = true
        iAmLabel.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        ddButton.translatesAutoresizingMaskIntoConstraints = false
        ddButton.rightAnchor.constraint(equalTo: iAmLabel.rightAnchor,constant: -5).isActive = true
        ddButton.centerYAnchor.constraint(equalTo: iAmLabel.centerYAnchor).isActive = true
        
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.topAnchor.constraint(equalTo: iAmLabel.bottomAnchor,constant: 15).isActive = true
        descLabel.leftAnchor.constraint(equalTo: iAmLabel.leftAnchor).isActive = true
        
        descTextView.translatesAutoresizingMaskIntoConstraints = false
        descTextView.topAnchor.constraint(equalTo: descLabel.bottomAnchor,constant: 5).isActive = true
        descTextView.rightAnchor.constraint(equalTo: iAmLabel.rightAnchor).isActive = true
        descTextView.leftAnchor.constraint(equalTo: iAmLabel.leftAnchor).isActive = true
        descTextView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.leftAnchor.constraint(equalTo: iAmLabel.leftAnchor).isActive = true
        phoneLabel.topAnchor.constraint(equalTo: descTextView.bottomAnchor,constant: 15).isActive = true
    
        phoneCheckBox.translatesAutoresizingMaskIntoConstraints = false
        phoneCheckBox.centerYAnchor.constraint(equalTo: phoneLabel.centerYAnchor).isActive = true
        phoneCheckBox.rightAnchor.constraint(equalTo: ddButton.rightAnchor).isActive = true
        phoneCheckBox.widthAnchor.constraint(equalToConstant: 35).isActive = true
        phoneCheckBox.heightAnchor.constraint(equalTo: phoneCheckBox.widthAnchor).isActive = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendButton.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor,constant: 45).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        
    }
    
}
