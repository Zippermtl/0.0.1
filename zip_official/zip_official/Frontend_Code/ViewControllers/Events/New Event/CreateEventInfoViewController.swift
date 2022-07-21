//
//  CreateEventInfoViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/7/22.
//

import UIKit

class CreateEventInfoViewController: UIViewController {
    var event: Event
    
    init(event: Event) {
        self.event = event
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let continueButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipBodyBold//.withSize(20)
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
    
    private let eventPictureLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Event Picture:"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Event Description:"
        return label
        
    }()
    
    private let capacityLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Event Capacity:"
        return label
    }()
    
    
    private let capacityNumField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Date",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.returnKeyType = .continue
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        
        return tf
    }()

    
    let capacitySlider = ResizeSlider()
    
    var descriptionField: UITextView = {
        let tf = UITextView()
        tf.font = .zipBody
        tf.backgroundColor = .zipLightGray
        tf.text = "Tell us about your event here!"
        tf.tintColor = .white
        tf.textColor = .zipVeryLightGray
        tf.layer.cornerRadius = 15
        return tf
    }()
    
//    private var eventPictureBackground = UIView()
    private var eventPicture: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold, scale: .medium)
        img.image = UIImage(systemName: "camera", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        img.isUserInteractionEnabled = true
        return img
    }()

    private let icons: [UIImage?] =
    [
        UIImage(systemName: "plus"),
        UIImage(named: "defaultEventIcon"),
        UIImage(named: "defaultEventIcon"),
        UIImage(named: "defaultEventIcon"),
        UIImage(named: "defaultEventIcon"),
        UIImage(named: "defaultEventIcon"),
        UIImage(named: "defaultEventIcon")

//        UIImage(systemName: "text.book.closed.fill"),
//        UIImage(systemName: "bicycle"),
//        UIImage(systemName: "gamecontroller.fill"),
//        UIImage(systemName: "music.mic"),
//        UIImage(systemName: "music.mic"),
//        UIImage(systemName: "music.mic")

    ]

    
    @objc func sliderChanged(_ sender: UISlider){
        dismissKeyboard()
        if sender.value == 501 {
            capacityNumField.text = "∞"
            event.maxGuests = 0
        } else {
            capacityNumField.text = Int(sender.value).description
            event.maxGuests = Int(sender.value)
        }
        
    }
    
    @objc private func dismissKeyboard () {
        descriptionField.resignFirstResponder()
        capacityNumField.resignFirstResponder()
    }
    
    @objc private func didTapContinueButton(){
        if event.getType() == .Public {
            continueButton.isEnabled = false
            let host = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String,
                            firstName: AppDelegate.userDefaults.value(forKey: "firstName") as! String,
                            lastName: AppDelegate.userDefaults.value(forKey: "lastName") as! String)
            
            event.hosts = [host]
                    
            //MARK: Fuckmyass is the variable which contains the string of the url of the picture
            // the code below was written by Yianni and was originally if success a else b has been
            // rewritten to be switch: case success a case failure b
            // note this is with a and b being code blocks excluding the code obviously written by me
            DatabaseManager.shared.createEvent(event: event, completion: { [weak self] success in
                switch success {
                case .success(let a):
                    let actionSheet = UIAlertController(title: "Successfull Created an Event",
                                                        message: "View your event in your profile",
                                                        preferredStyle: .actionSheet)
                    
                    actionSheet.addAction(UIAlertAction(title: "Continue",
                                                        style: .cancel,
                                                        handler: nil))
                    
                    self?.present(actionSheet, animated: true)
                    self?.dismiss(animated: true, completion: nil)
                    self?.continueButton.isEnabled = true
                case .failure(let error):
                    print(error)
                    let actionSheet = UIAlertController(title: "Failed to Create Your Event",
                                                        message: "Make sure all the information you entered is correct or try again later.",
                                                        preferredStyle: .actionSheet)
                    
                    actionSheet.addAction(UIAlertAction(title: "Continue",
                                                        style: .cancel,
                                                        handler: nil))
                    
                    self?.present(actionSheet, animated: true)
                }
            })

        } else {
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
            
            event.description = descriptionField.text
            
            let vc = CompleteEventViewController(event: event)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        title = "Customize Event"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if event.description != "" {
            descriptionField.text = event.description
            descriptionField.textColor = .white
        }
        
        if event.maxGuests != 0 {
            capacitySlider.value = Float(event.maxGuests)
        } else {
            if event.isPublic() {
                capacitySlider.value = 501
                capacityNumField.text = "∞"
            } else {
                capacitySlider.value = 100
                capacityNumField.text = "100"
            }
            
        }
        
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(presentPhotoActionSheet))
        eventPicture.addGestureRecognizer(photoTap)
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(viewTap)
        
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        descriptionField.delegate = self
        
        addSubviews()
        layoutSubviews()
        configureSlider()
    }
    
    private func configureSlider(){
        capacitySlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        capacitySlider.minimumValue = 1
        capacitySlider.maximumValue = 501
        
        capacitySlider.trackHeight = 2
        capacitySlider.minimumTrackTintColor = .zipVeryLightGray
    }

    private func addSubviews() {
        view.addSubview(eventPictureLabel)
        view.addSubview(eventPicture)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionField)
        view.addSubview(capacityLabel)
        view.addSubview(capacityNumField)
        view.addSubview(capacitySlider)
        
        view.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)

    }

    private func layoutSubviews() {
        eventPictureLabel.translatesAutoresizingMaskIntoConstraints = false
        eventPictureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        eventPictureLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        eventPictureLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        // Picture

        eventPicture.translatesAutoresizingMaskIntoConstraints = false
        eventPicture.topAnchor.constraint(equalTo: eventPictureLabel.bottomAnchor, constant: 10).isActive = true
        eventPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventPicture.widthAnchor.constraint(equalToConstant: view.frame.width/4).isActive = true
        eventPicture.heightAnchor.constraint(equalTo: eventPicture.widthAnchor).isActive = true
        
        eventPicture.layer.masksToBounds = true
        eventPicture.layer.cornerRadius = view.frame.width/8
        eventPicture.layer.borderColor = UIColor.zipYellow.cgColor
        eventPicture.layer.borderWidth = 2
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: eventPicture.bottomAnchor, constant: 20).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: eventPictureLabel.leftAnchor).isActive = true
        
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        descriptionField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 10).isActive = true
        descriptionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        descriptionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        descriptionField.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        capacityLabel.translatesAutoresizingMaskIntoConstraints = false
        capacityLabel.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 30).isActive = true
        capacityLabel.leftAnchor.constraint(equalTo: descriptionField.leftAnchor).isActive = true
        
        capacitySlider.translatesAutoresizingMaskIntoConstraints = false
        capacitySlider.topAnchor.constraint(equalTo: capacityLabel.bottomAnchor, constant: 15).isActive = true
        capacitySlider.leftAnchor.constraint(equalTo: capacityNumField.rightAnchor, constant: 10).isActive = true
        capacitySlider.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        capacityNumField.translatesAutoresizingMaskIntoConstraints = false
        capacityNumField.topAnchor.constraint(equalTo: capacityLabel.bottomAnchor, constant: 15).isActive = true
        capacityNumField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
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



extension CreateEventInfoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            presentPhotoActionSheet()
        } else {
            eventPicture.image = icons[indexPath.row]
            event.image = icons[indexPath.row]
            didUpdatePicture = true
        }
    }
}

extension CreateEventInfoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return icons.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .zipGray
        let cellWidth = (view.frame.size.width-20-10*4)/5
        
        let circleBg = UIView()
        circleBg.backgroundColor = .zipLightGray
        circleBg.layer.cornerRadius = cellWidth/2
        circleBg.layer.masksToBounds = true
        
        let imgView = UIImageView()
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        imgView.image = icons[indexPath.row]?.withConfiguration(largeConfig)
        imgView.tintColor = .white
        imgView.backgroundColor = .clear
        imgView.layer.masksToBounds = true
        
        circleBg.addSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.centerXAnchor.constraint(equalTo: circleBg.centerXAnchor).isActive = true
        imgView.centerYAnchor.constraint(equalTo: circleBg.centerYAnchor).isActive = true
        
        cell.contentView.addSubview(circleBg)
        circleBg.translatesAutoresizingMaskIntoConstraints = false
        circleBg.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
        circleBg.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
        circleBg.widthAnchor.constraint(equalToConstant: cellWidth).isActive = true
        circleBg.heightAnchor.constraint(equalTo: circleBg.widthAnchor).isActive = true

        
        return cell
    }
    
    
}



extension CreateEventInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
        eventPicture.image = selectedImage
        event.image = selectedImage
        didUpdatePicture = true

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension CreateEventInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cs = NSCharacterSet(charactersIn: "0123456789").inverted
        let filtered = string.components(separatedBy: cs).joined(separator: "")
        return (string == filtered)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let numString = textField.text,
              let num = Float(numString) else {
            return
        }
        
        capacitySlider.value = num
        sliderChanged(capacitySlider)
    }
}

extension CreateEventInfoViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .zipVeryLightGray {
            textView.text = nil
            textView.textColor = .white
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Tell us about your event here!"
            textView.textColor = .zipVeryLightGray
        }
        
        event.description = textView.text
    }
}
