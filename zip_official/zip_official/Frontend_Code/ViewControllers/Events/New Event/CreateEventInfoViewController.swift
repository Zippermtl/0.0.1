//
//  CreateEventInfoViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/7/22.
//

import UIKit

class CreateEventInfoViewController: UIViewController {
    var event = Event()
    weak var delegate: MaintainEventDelegate?
    
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
    
    private let maxCapacityLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Maximum Capacity:"
        return label
    }()
    
    private let capacityNumLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "0"
        return label
    }()
    
    private let yesButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Yes", for: .normal)
        btn.titleLabel?.font = .zipBody.withSize(16)
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapYes), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    private let noButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("No", for: .normal)
        btn.titleLabel?.font = .zipBody.withSize(16)
        btn.backgroundColor = .zipBlue
        btn.addTarget(self, action: #selector(didTapNo), for: .touchUpInside)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        return btn
    }()
    
    @objc private func didTapContinueButton(){
        let vc = CompleteEventViewController()
        vc.event = event
        navigationController?.pushViewController(vc, animated: true)
    }
    
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
    private var collectionView: UICollectionView?
    
//    private var eventPictureBackground = UIView()
    private var eventPicture: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.tintColor = .white
        img.image = UIImage(systemName: "plus")
        img.isUserInteractionEnabled = true
        return img
    }()

    private let icons: [UIImage?] =
    [
        UIImage(systemName: "plus"),
        UIImage(systemName: "text.book.closed.fill"),
        UIImage(systemName: "bicycle"),
        UIImage(systemName: "gamecontroller.fill"),
        UIImage(systemName: "music.mic"),
        UIImage(systemName: "music.mic"),
        UIImage(systemName: "music.mic")

    ]
    
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
    
    private let pageStatus2: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus3 = StatusCheckView()
    
    @objc private func didTapNo() {
        noButton.backgroundColor = .zipBlue
        yesButton.backgroundColor = .zipLightGray
        capacitySlider.isEnabled = false
        capacitySlider.minimumTrackTintColor = .zipVeryLightGray
        event.maxGuests = 0
    }
    
    @objc private func didTapYes() {
        noButton.backgroundColor = .zipLightGray
        yesButton.backgroundColor = .zipBlue
        capacitySlider.isEnabled = true
        capacitySlider.minimumTrackTintColor = .zipBlue
    }
    
    @objc func sliderChanged(_ sender: UISlider){
        capacityNumLabel.text = Int(sender.value).description
        event.maxGuests = Int(sender.value)
    }
    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        descriptionField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        title = "CUSTOMIZE EVENT"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        if event.description != "" {
            descriptionField.text = event.description
            descriptionField.textColor = .white
        }
        
        if event.maxGuests != 0 {
            noButton.backgroundColor = .zipVeryLightGray
            yesButton.backgroundColor = .zipBlue
            capacitySlider.value = Float(event.maxGuests)
            capacitySlider.isEnabled = true
        } else {
            noButton.backgroundColor = .zipBlue
            yesButton.backgroundColor = .zipVeryLightGray
            capacitySlider.value = 0
            capacitySlider.isEnabled = false
        }
//        eventPicture.image =

        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let size = (view.frame.size.width-20-10*4)/5
        layout.itemSize = CGSize(width: size, height: size)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let photoTap = UITapGestureRecognizer(target: self, action: #selector(presentPhotoActionSheet))
        eventPicture.addGestureRecognizer(photoTap)
        
//        let viewTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
//        view.addGestureRecognizer(viewTap)
        
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        descriptionField.delegate = self
        
        configureCollectionView()
        addSubviews()
        layoutSubviews()
        configureSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.updateEvent(event: event)
    }
    
    
    private func configureCollectionView() {
        guard let collectionView = collectionView else {
            return
        }
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.bounces = true
        collectionView.isScrollEnabled = true
    }
    
    private func configureSlider(){
        capacitySlider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        capacitySlider.minimumValue = 0
        capacitySlider.maximumValue = 1000
        
        capacitySlider.trackHeight = 2
        capacitySlider.minimumTrackTintColor = .zipVeryLightGray
    }

    private func addSubviews() {
        guard let collectionView = collectionView else {
            return
        }
        
        view.addSubview(eventPictureLabel)
        view.addSubview(eventPicture)
        view.addSubview(collectionView)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionField)
        view.addSubview(capacityLabel)
        view.addSubview(maxCapacityLabel)
        view.addSubview(yesButton)
        view.addSubview(noButton)
        view.addSubview(capacityNumLabel)
        view.addSubview(capacitySlider)


        view.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)



    }

    private func layoutSubviews() {
        guard let collectionView = collectionView else {
            return
        }

        eventPictureLabel.translatesAutoresizingMaskIntoConstraints = false
        eventPictureLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        eventPictureLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        eventPictureLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        // Picture
        eventPicture.image = UIImage(named: "yianni1")
        eventPicture.translatesAutoresizingMaskIntoConstraints = false
        eventPicture.topAnchor.constraint(equalTo: eventPictureLabel.bottomAnchor, constant: 10).isActive = true
        eventPicture.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventPicture.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        eventPicture.heightAnchor.constraint(equalTo: eventPicture.widthAnchor).isActive = true
        
        eventPicture.layer.masksToBounds = true
        eventPicture.layer.cornerRadius = view.frame.width/4
        eventPicture.layer.borderColor = UIColor.zipYellow.cgColor
        eventPicture.layer.borderWidth = 2
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: eventPicture.bottomAnchor, constant: 20).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: (view.frame.size.width-20-10*4)/5).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 30).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: eventPictureLabel.leftAnchor).isActive = true
        
        descriptionField.translatesAutoresizingMaskIntoConstraints = false
        descriptionField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 10).isActive = true
        descriptionField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        descriptionField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        descriptionField.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        
        capacityLabel.translatesAutoresizingMaskIntoConstraints = false
        capacityLabel.topAnchor.constraint(equalTo: descriptionField.bottomAnchor, constant: 30).isActive = true
        capacityLabel.leftAnchor.constraint(equalTo: descriptionField.leftAnchor).isActive = true
        
        maxCapacityLabel.translatesAutoresizingMaskIntoConstraints = false
        maxCapacityLabel.topAnchor.constraint(equalTo: capacityLabel.bottomAnchor, constant: 10).isActive = true
        maxCapacityLabel.leftAnchor.constraint(equalTo: capacityLabel.leftAnchor).isActive = true
        
        yesButton.translatesAutoresizingMaskIntoConstraints = false
        yesButton.leftAnchor.constraint(equalTo: maxCapacityLabel.rightAnchor, constant: 5).isActive = true
        yesButton.centerYAnchor.constraint(equalTo: maxCapacityLabel.centerYAnchor).isActive = true
        yesButton.heightAnchor.constraint(equalTo: maxCapacityLabel.heightAnchor).isActive = true
        yesButton.widthAnchor.constraint(equalTo: noButton.widthAnchor).isActive = true

        noButton.translatesAutoresizingMaskIntoConstraints = false
        noButton.leftAnchor.constraint(equalTo: yesButton.rightAnchor, constant: 5).isActive = true
        noButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        noButton.centerYAnchor.constraint(equalTo: maxCapacityLabel.centerYAnchor).isActive = true
        noButton.heightAnchor.constraint(equalTo: maxCapacityLabel.heightAnchor).isActive = true
        
        capacitySlider.translatesAutoresizingMaskIntoConstraints = false
        capacitySlider.topAnchor.constraint(equalTo: maxCapacityLabel.bottomAnchor, constant: 15).isActive = true
        capacitySlider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        capacitySlider.rightAnchor.constraint(equalTo: capacityNumLabel.leftAnchor, constant: -10).isActive = true
        
        capacityNumLabel.translatesAutoresizingMaskIntoConstraints = false
        capacityNumLabel.topAnchor.constraint(equalTo: maxCapacityLabel.bottomAnchor, constant: 15).isActive = true
        capacityNumLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
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
        print("selecting")
        if indexPath.row == 0 {
            presentPhotoActionSheet()
        } else {
            eventPicture.image = icons[indexPath.row]
            event.image = icons[indexPath.row]
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
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
