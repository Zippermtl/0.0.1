//
//  CreateEventInfoViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/7/22.
//

import UIKit

class CustomizeEventViewController: UIViewController {
    var event: Event
    private let descriptionLabel: UILabel
    private var eventPicture: UIImageView
    private var descriptionField: UITextView
    private var customizeView: UIView
    
    private let addHostButton: UIButton
    private let addHostsLabel: UILabel
    private let hostCountLabel: UILabel
    
    private let changeProfilePicBtn : UIButton
    init(event: Event) {
        self.event = event
        self.descriptionField = UITextView()
        self.descriptionLabel = UILabel.zipTextFillBold()
        self.eventPicture = UIImageView()
        self.addHostButton = UIButton()
        self.addHostsLabel = UILabel.zipTextFillBold()
        self.hostCountLabel = UILabel.zipTextFillBold()
        hostCountLabel.textColor = .zipVeryLightGray
        changeProfilePicBtn = UIButton()
        if event.getType() == .Promoter {
            customizeView = PromoterTicketsView()
        } else {
            customizeView = PrivacyView()
        }
        
        
        super.init(nibName: nil, bundle: nil)
        setupKeyboardHiding()

        changeProfilePicBtn.setTitle("Change Event Cover Photo", for: .normal)
        changeProfilePicBtn.setTitleColor(.zipBlue, for: .normal)
        changeProfilePicBtn.titleLabel?.font = .zipTextFillBold
        changeProfilePicBtn.addTarget(self, action: #selector(presentPhotoActionSheet), for: .touchUpInside)
        
        descriptionField.text = "Tell us about your event here!"
        descriptionLabel.text = "Event Description:"
        addHostsLabel.text = "Add Co-hosts: "
        addHostButton.addTarget(self, action: #selector(didTapAddHosts), for: .touchUpInside)
        addHostButton.setImage(UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        
        eventPicture.contentMode = .scaleAspectFit
        eventPicture.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .medium)
        eventPicture.image = UIImage(systemName: "camera", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        eventPicture.isUserInteractionEnabled = true
        
        descriptionField.font = .zipTextFill
        descriptionField.backgroundColor = .zipLightGray
        descriptionField.tintColor = .white
        descriptionField.textColor = .zipVeryLightGray
        descriptionField.layer.cornerRadius = 15
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
        
        descriptionField.inputAccessoryView = doneToolbar
       
    }
    
    @objc func doneButtonAction(){
        descriptionField.resignFirstResponder()
    }
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var originalY : CGFloat?
    @objc private func keyboardWillShow(sender: NSNotification) {
        originalY = view.frame.origin.y
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else {
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
   
    
    private let continueButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = .zipSubtitle2
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipSubtitle2
        return btn
    }()
    
    private let pageStatus2: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus3 = StatusCheckView()
    
    var didUpdatePicture = false

    @objc private func dismissKeyboard () {
        view.endEditing(true)
    }
    
    @objc private func didTapContinueButton(){
        dismissKeyboard()
        guard descriptionField.text != nil,
              didUpdatePicture == true else {
            let alert = UIAlertController(title: "Complete All Fields To Conitnue",
                                          message: "",
                                          preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Continue",
                                          style: .cancel,
                                          handler: nil))
            
            present(alert, animated: true)
            return
        }
        
        if let event = event as? UserEvent,
            let privacyView = customizeView as? PrivacyView {
            event.allowUserInvites = privacyView.allowUserInvitesSwitch.isOn
            guard let isOpen = privacyView.isOpen() else {
                let alert = UIAlertController(title: "Pick a privacy setting ot continue",
                                              message: "",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Continue",
                                              style: .cancel,
                                              handler: nil))
                
                present(alert, animated: true)
                return
            }
            if isOpen {
                event.type = .Open
            } else {
                event.type = .Closed
            }
        } else if let promoterView = customizeView as? PromoterTicketsView {
            if promoterView.sellTicketsSwitch.isOn {
                if let event = event as? PromoterEvent  {
                    guard let price = promoterView.getPrice(),
                          let link = promoterView.getLink() else {
                        let alert = UIAlertController(title: "Add both a price and a link to conitnue",
                                                      message: "",
                                                      preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Continue",
                                                      style: .cancel,
                                                      handler: nil))
                        
                        present(alert, animated: true)
                        return
                    }
                    
                    if verifyUrl(urlString: link.absoluteString) {
                        event.price = price
                        event.buyTicketsLink = link
                    } else {
                        let alert = UIAlertController(title: "Error: URL Unavailable",
                                                            message: "Please Enter a Valid URL to continue",
                                                            preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok",
                                                            style: .cancel,
                                                            handler: nil))
                        
                        present(alert, animated: true)
                        return
                    }
                   
                }
            }
        } else {
            print("NEVER SHOULD BE HERE")
        }
        
        event.bio = descriptionField.text
        
        let vc = CompleteEventViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)

    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    @objc private func didTapAddHosts() {
        let vc = InviteTableViewController(items: User.getMyZips())
        
        vc.saveFunc = { [weak self] items in
            guard let strongSelf = self,
                  let users = items as? [User] else { return }
            for user in users {
                if !strongSelf.event.hosts.contains(user) {
                    strongSelf.event.hosts.append(user)
                }
            }
                
            DispatchQueue.main.async {
                self?.navigationController?.popViewController(animated: true)
            }
        
        }
        vc.title = "Co-Host"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .zipGray
        title = "Customize Event"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
        
        if event.bio != "" {
            descriptionField.text = event.bio
            descriptionField.textColor = .white
        }
        
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(presentPhotoActionSheet))
        eventPicture.addGestureRecognizer(photoTap)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTap)
        
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        descriptionField.delegate = self
        
        addSubviews()
        layoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let promoterView = customizeView as? PromoterTicketsView,
              let header = promoterView.tableView.tableHeaderView else {
            return
        }
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
    }


    private func addSubviews() {
        view.addSubview(eventPicture)
        view.addSubview(changeProfilePicBtn)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionField)
        view.addSubview(customizeView)
        view.addSubview(addHostsLabel)
        view.addSubview(addHostButton)
        view.addSubview(hostCountLabel)

        
        view.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)
    }

    private func layoutSubviews() {
        eventPicture.translatesAutoresizingMaskIntoConstraints = false
        eventPicture.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        eventPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventPicture.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        eventPicture.heightAnchor.constraint(equalTo: eventPicture.widthAnchor).isActive = true
        
        changeProfilePicBtn.translatesAutoresizingMaskIntoConstraints = false
        changeProfilePicBtn.topAnchor.constraint(equalTo: eventPicture.bottomAnchor, constant: 10).isActive = true
        changeProfilePicBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        eventPicture.layer.masksToBounds = true
        eventPicture.layer.cornerRadius = view.frame.width/8
        eventPicture.layer.borderColor = event.getType().color.cgColor
        eventPicture.layer.borderWidth = 2
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: changeProfilePicBtn.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        descriptionField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 10).isActive = true
        descriptionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        descriptionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        descriptionField.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        descriptionField.heightAnchor.constraint(lessThanOrEqualToConstant: 225).isActive = true

        addHostsLabel.translatesAutoresizingMaskIntoConstraints = false
        addHostsLabel.topAnchor.constraint(equalTo: descriptionField.bottomAnchor,constant: 15).isActive = true
        addHostsLabel.leftAnchor.constraint(equalTo: descriptionLabel.leftAnchor).isActive = true
        
        hostCountLabel.translatesAutoresizingMaskIntoConstraints = false
        hostCountLabel.leftAnchor.constraint(equalTo: addHostsLabel.rightAnchor,constant: 10).isActive = true
        hostCountLabel.topAnchor.constraint(equalTo: addHostsLabel.topAnchor).isActive = true
        hostCountLabel.rightAnchor.constraint(lessThanOrEqualTo: addHostButton.leftAnchor).isActive = true
        
        addHostButton.translatesAutoresizingMaskIntoConstraints = false
        addHostButton.rightAnchor.constraint(equalTo: descriptionField.rightAnchor).isActive = true
        addHostButton.centerYAnchor.constraint(equalTo: addHostsLabel.centerYAnchor).isActive = true
        
        customizeView.translatesAutoresizingMaskIntoConstraints = false
        customizeView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        customizeView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        customizeView.topAnchor.constraint(equalTo: addHostsLabel.bottomAnchor,constant: 10).isActive = true
        customizeView.bottomAnchor.constraint(equalTo: continueButton.topAnchor,constant: -10).isActive = true
        
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        continueButton.widthAnchor.constraint(equalToConstant: (view.frame.width-90)*0.67).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalToConstant: 15).isActive = true
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
        
        pageStatus1.layer.cornerRadius = 15/2
        pageStatus2.layer.cornerRadius = 15/2
        pageStatus3.layer.cornerRadius = 15/2
    }
}




extension CustomizeEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Event Image",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Take a Photo with Camera",
                                            style: .default,
                                            handler: { [weak self] _ in
            DispatchQueue.main.async {
                self?.presentCamera()
            }
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
        
        eventPicture.image = selectedImage
        event.image = selectedImage
        didUpdatePicture = true

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


extension CustomizeEventViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor != .white {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about your event here!"
            textView.textColor = .zipVeryLightGray
        }
        
        event.bio = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentString = (textView.text ?? "") as NSString
        let str = currentString.replacingCharacters(in: range, with: text)
        if str.count > 300 { return false }
        return true
    }
}


extension CustomizeEventViewController {
    internal class PrivacyView: UIView {
        private var privacyLabel: UILabel
        private let openClosedLabel: UILabel
        
        private var openButton: UIButton
        private var closedButton: UIButton
        private var openClosedDescriptionLabel: UILabel
        
        private var allowUserInvitesLabel: UILabel
        var allowUserInvitesSwitch: UISwitch
        
        private let OCDescriptionText: (String,String,String) = (
            "Open events are visible on the map by people who are invited or going. They are also visible on the event finder page and can be searched for." ,
            "Closed events are visibile on the map by people who are invited. They CANNOT be found on the event finder page or the search bar unless they are invited",
            "Select a privacy setting to continue"
        )
        
        init(){
            self.allowUserInvitesSwitch = UISwitch()
            self.privacyLabel = UILabel.zipTextFill()
            self.allowUserInvitesLabel = UILabel.zipTextFillBold()
            self.openClosedLabel = UILabel.zipTextFill()
            self.openClosedDescriptionLabel = UILabel.zipTextDetail()
            self.openButton = UIButton()
            self.closedButton = UIButton()
            super.init(frame: .zero)
            allowUserInvitesLabel.text = "Guests can invite zips:"
            privacyLabel.text = "Privacy:"
            openClosedDescriptionLabel.text = OCDescriptionText.2
            
            privacyLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

            openClosedDescriptionLabel.textColor = .zipVeryLightGray
            openClosedDescriptionLabel.textAlignment = .center
            openClosedDescriptionLabel.numberOfLines = 0
            openClosedDescriptionLabel.lineBreakMode = .byWordWrapping
            
            openButton.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
            closedButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
            
            closedButton.backgroundColor = .zipLightGray
            closedButton.layer.masksToBounds = true
            closedButton.layer.cornerRadius = 10

            
            closedButton.setTitle("Closed", for: .normal)
            closedButton.titleLabel?.textColor = .white
            closedButton.titleLabel?.font = .zipSubtitle2
            closedButton.titleLabel?.textAlignment = .center
            closedButton.contentVerticalAlignment = .center
            
            openButton.backgroundColor = .zipLightGray
            openButton.layer.masksToBounds = true
            openButton.layer.cornerRadius = 10
            
            openButton.setTitle("Open", for: .normal)
            openButton.titleLabel?.textColor = .white
            openButton.titleLabel?.font = .zipSubtitle2
            openButton.titleLabel?.textAlignment = .center
            openButton.contentVerticalAlignment = .center
            
            addSubviews()
            layout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func addSubviews(){
            addSubview(privacyLabel)
            addSubview(openClosedLabel)
            addSubview(openButton)
            addSubview(closedButton)
            addSubview(openClosedDescriptionLabel)
            addSubview(allowUserInvitesLabel)
            addSubview(allowUserInvitesSwitch)
        }
        
        private func layout(){
            privacyLabel.translatesAutoresizingMaskIntoConstraints = false
            privacyLabel.topAnchor.constraint(equalTo: topAnchor).isActive = true
            privacyLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
            
            closedButton.translatesAutoresizingMaskIntoConstraints = false
            closedButton.heightAnchor.constraint(equalTo: privacyLabel.heightAnchor).isActive = true
            closedButton.centerYAnchor.constraint(equalTo: privacyLabel.centerYAnchor).isActive = true
            closedButton.leftAnchor.constraint(equalTo: privacyLabel.rightAnchor, constant: 15).isActive = true
            closedButton.widthAnchor.constraint(equalTo: openButton.widthAnchor).isActive = true
            
            openButton.translatesAutoresizingMaskIntoConstraints = false
            openButton.centerYAnchor.constraint(equalTo: closedButton.centerYAnchor).isActive = true
            openButton.leftAnchor.constraint(equalTo: closedButton.rightAnchor,constant: 15).isActive = true
            openButton.rightAnchor.constraint(equalTo: rightAnchor,constant: -15).isActive = true
            
            openClosedDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            openClosedDescriptionLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            openClosedDescriptionLabel.widthAnchor.constraint(equalTo: widthAnchor,multiplier: 0.9).isActive = true
            openClosedDescriptionLabel.topAnchor.constraint(equalTo: privacyLabel.bottomAnchor,constant: 10).isActive = true
            
            allowUserInvitesLabel.translatesAutoresizingMaskIntoConstraints = false
            allowUserInvitesLabel.topAnchor.constraint(equalTo: openClosedDescriptionLabel.bottomAnchor,constant: 15).isActive = true
            allowUserInvitesLabel.leftAnchor.constraint(equalTo: privacyLabel.leftAnchor).isActive = true
            
            
            allowUserInvitesSwitch.translatesAutoresizingMaskIntoConstraints = false
            allowUserInvitesSwitch.centerYAnchor.constraint(equalTo: allowUserInvitesLabel.centerYAnchor).isActive = true
            allowUserInvitesSwitch.rightAnchor.constraint(equalTo: openButton.rightAnchor).isActive = true
        }
        
        @objc private func didTapOpen(){
            openClosedDescriptionLabel.text = OCDescriptionText.0
            closedButton.backgroundColor = .zipLightGray
            openButton.backgroundColor = .zipBlue
            closedButton.isSelected = false
            openButton.isSelected = true
        }
        
        @objc private func didTapClose(){
            openClosedDescriptionLabel.text = OCDescriptionText.1
            closedButton.backgroundColor = .zipBlue
            openButton.backgroundColor = .zipLightGray
            closedButton.isSelected = true
            openButton.isSelected = false
        }
        
        public func isOpen() -> Bool? {
            if !openButton.isSelected && !closedButton.isSelected {
                return nil
            } else if openButton.isSelected {
                return true
            } else {
                return false
            }
        }
    }
}

extension CustomizeEventViewController {
    internal class PromoterTicketsView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
        var price: Double?
        var link: URL?
        
        var tableView: UITableView
        var sellTicketsSwitch: UISwitch
        let priceField: UITextField
        let linkField: UITextField

        init(){
            tableView = UITableView()
            sellTicketsSwitch = UISwitch()
            priceField = UITextField()
            linkField = UITextField()
            super.init(frame: .zero)
            tableView.bounces = false
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.separatorColor = .none
            
            priceField.delegate = self
            priceField.backgroundColor = .zipLightGray
            priceField.borderStyle = .roundedRect
            priceField.keyboardType = .decimalPad
            
            linkField.delegate = self
            linkField.backgroundColor = .zipLightGray
            linkField.borderStyle = .roundedRect

            sellTicketsSwitch.addTarget(self, action: #selector(didTapSwitch(sender:)), for: .valueChanged)
            
            addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            tableView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            tableView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        }
        
        
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func getPrice() -> Double? {
            return sellTicketsSwitch.isOn ? price : nil
        }
        
        public func getLink() -> URL? {
            return  sellTicketsSwitch.isOn ? link : nil
        }
        
        @objc private func didTapSwitch(sender: UISwitch) {
            let indexPaths : [IndexPath] = [IndexPath(row: 0, section: 0),IndexPath(row: 1, section: 0)]
            switch sender.isOn {
            case true:
                tableView.insertRows(at: indexPaths, with: .automatic)
            case false:
                tableView.deleteRows(at: indexPaths, with: .automatic)
            }
        }
        
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let header = UIView()
            let sellTicketsLabel = UILabel.zipTextFill()
            sellTicketsLabel.text = "Sell Tickets:"
            
            header.addSubview(sellTicketsLabel)
            header.addSubview(sellTicketsSwitch)

            sellTicketsLabel.translatesAutoresizingMaskIntoConstraints = false
            sellTicketsLabel.centerYAnchor.constraint(equalTo: sellTicketsSwitch.centerYAnchor).isActive = true
            sellTicketsLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
            sellTicketsLabel.leftAnchor.constraint(equalTo: header.leftAnchor,constant: 10).isActive = true
            
            sellTicketsSwitch.translatesAutoresizingMaskIntoConstraints = false
            sellTicketsSwitch.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
            sellTicketsSwitch.bottomAnchor.constraint(equalTo: header.bottomAnchor,constant: -5).isActive = true
            sellTicketsSwitch.rightAnchor.constraint(equalTo: header.rightAnchor,constant: -20).isActive = true
            return header
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return sellTicketsSwitch.isOn ? 2 : 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if indexPath.row == 0 {
                return getPriceCell()
            } else {
                return getLinkCell()
            }
        }
        
        private func getPriceCell() -> UITableViewCell {
            let cell = UITableViewCell()
            let priceLabel = UILabel.zipTextFillBold()
            priceLabel.text = "Price"
            
            let view = cell.contentView
            view.backgroundColor = .zipGray
            view.addSubview(priceLabel)
            view.addSubview(priceField)
            
            priceLabel.translatesAutoresizingMaskIntoConstraints = false
            priceLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
            priceLabel.centerYAnchor.constraint(equalTo: priceField.centerYAnchor).isActive = true
            priceLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true

            
            priceField.translatesAutoresizingMaskIntoConstraints = false
            priceField.topAnchor.constraint(equalTo: view.topAnchor,constant: 5).isActive = true
            priceField.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -5).isActive = true
            priceField.leftAnchor.constraint(equalTo: priceLabel.rightAnchor, constant: 10).isActive = true
            priceField.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true

            return cell
        }
        
        private func getLinkCell() -> UITableViewCell {
            let cell = UITableViewCell()
            let linkLabel = UILabel.zipTextFillBold()
            linkLabel.text = "Link"
            
            let view = cell.contentView
            view.backgroundColor = .zipGray
            view.addSubview(linkLabel)
            view.addSubview(linkField)
            
            linkLabel.translatesAutoresizingMaskIntoConstraints = false
            linkLabel.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 10).isActive = true
            linkLabel.centerYAnchor.constraint(equalTo: linkField.centerYAnchor).isActive = true
            linkLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
            
            linkField.translatesAutoresizingMaskIntoConstraints = false
            linkField.topAnchor.constraint(equalTo: view.topAnchor,constant: 5).isActive = true
            linkField.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -5).isActive = true
            linkField.leftAnchor.constraint(equalTo: linkLabel.rightAnchor, constant: 10).isActive = true
            linkField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
            
            return cell
        }
        
        func addDoneButtonOnKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
            doneToolbar.barStyle = .default
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
            
            let items = [flexSpace, done]
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            linkField.inputAccessoryView = doneToolbar
            priceField.inputAccessoryView = doneToolbar
        }
        
        @objc func doneButtonAction(){
            priceField.resignFirstResponder()
            linkField.resignFirstResponder()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            if textField == priceField {
                if textField.text == "" || textField.text == nil {
                    textField.text = "$"
                }
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if textField == priceField {
                guard let text = textField.text else {
                    price = nil
                    return
                }
                if text == "$" {
                    textField.text = nil
                }
                let priceString = text.suffix(text.count-1)
                price = Double(priceString)
                
                guard let price = price else {
                    textField.text = nil
                    return
                }
                textField.text = "$" + String(format: "%.2f", price)

            } else {
                guard let text = textField.text else {
                    link = nil
                    return
                }
                link = URL(string: text)
            }
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if textField == priceField {
                let invalidCharacters = CharacterSet(charactersIn: "0123456789.").inverted
                return string.rangeOfCharacter(from: invalidCharacters) == nil
            }
            
            return true
        }


    }
    
}


extension UIResponder {
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }

}
