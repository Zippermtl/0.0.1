//
//  NewPrivateEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/11/21.
//

import UIKit
import CoreLocation
import RSKImageCropper
import DropDown


class NewPrivateEventViewController: UIViewController {
    static let dateIdentifier = "date"
    static let numGuestsIdentifier = "numGuests"
    static let locationIdentifier = "location"
    
    var zipList: [User] = MapViewController.getTestUsers()
    
    var event = Event()
    
    
    private var eventImage = UIImageView()
    
    private var addPictureButton: UIButton = {
        let btn = UIButton()
        
        btn.setImage(UIImage(systemName: "camera")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    private var deletePictureButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "redX")?.withTintColor(.zipVeryLightGray), for: .normal)
        return btn
    }()
    
    private var scrollView = UIScrollView()
    
    private var titleText: UITextField = {
        let tf = UITextField()
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.layer.cornerRadius = 5
        tf.adjustsFontSizeToFitWidth = true
        
        tf.minimumFontSize = 14.0;
        tf.text = "Event Title"
        tf.clearButtonMode = .whileEditing
        tf.font = .zipTitle
        tf.textAlignment = .center
        return tf
    }()
    
    //MARK: Labels
    var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .zipSubscript
        label.textColor = .zipLightGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.text = "Private events will only appear on the map for those invited"
        return label
    }()
    
    var locationLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Location: "
        return label
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Date: "
        return label
    }()
    
    var startTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Start Time: "
        return label
    }()
    
    var durationLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Duration: "
        return label
    }()

    var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        label.text = "Description:"
        return label
    }()
    
    
    //MARK: TextFields
    
    var locationTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Enter Your Event Location",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0;
        
        return tf
    }()
    
    var dateTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Date",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0;
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .inline

        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return tf
    }()
    
    var startTimeTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Start Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0;
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        return tf
    }()
    
    var durationTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Duration",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0;
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = 15
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        return tf
    }()
    
    var descriptionTxt: UITextView = {
        let tf = UITextView()
        tf.font = .zipBody
        tf.backgroundColor = .zipLightGray
        tf.tintColor = .white
        tf.textColor = .white
        tf.layer.cornerRadius = 15
        return tf
    }()
    
    var tableView = UITableView()
    
    //MARK: - Buttons/TableView
    
    let invitedAllButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Invite All", for: .normal)
        btn.titleLabel?.font = .zipBodyBold
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapInvitedAllButton), for: .touchUpInside)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Clear", for: .normal)
        btn.titleLabel?.font = .zipBodyBold
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    //MARK: - objc funcs
    @objc private func didTapInvitedAllButton(){
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? InviteTableViewCell {
                cell.addButton.isSelected = true
            }
        }
    }
    
    @objc private func didTapClearButton(){
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? InviteTableViewCell {
                cell.addButton.isSelected = false
            }
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        titleText.resignFirstResponder()
        dateTxt.resignFirstResponder()
        startTimeTxt.resignFirstResponder()
        durationTxt.resignFirstResponder()
        descriptionTxt.resignFirstResponder()
    }
    
    @objc func dateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        dateTxt.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: sender.date, time: event.startTime) ?? event.startTime
    }

    
    @objc func startTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeTxt.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: event.startTime, time: sender.date)!
    }
    
    func combineDateWithTime(date: Date, time: Date) -> Date? {
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: time)
        
        let mergedComponments = NSDateComponents()
        mergedComponments.year = dateComponents.year ?? 2021
        mergedComponments.month = dateComponents.month ?? 1
        mergedComponments.day = dateComponents.day ?? 1
        mergedComponments.hour = timeComponents.hour ?? 12
        mergedComponments.minute = timeComponents.minute ?? 0
        mergedComponments.second = timeComponents.second ?? 0
        
        return calendar.date(from: mergedComponments as DateComponents)
    }
    
    @objc func durationChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "H"
        durationTxt.text = formatter.string(from: sender.date) + " Hours "
        formatter.dateFormat = "m"
        durationTxt.text = durationTxt.text! + formatter.string(from: sender.date) + " Minutes"
    }
    
    
    @objc private func openSearch(){
        let searchVC = PopupSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        present(searchVC, animated: true, completion: nil)
    }
    
    @objc private func didTapAddImage(){
        print("add tapped")
        let picturePickerVC = UIImagePickerController()
        picturePickerVC.delegate = self
        picturePickerVC.sourceType = .photoLibrary
        picturePickerVC.modalPresentationStyle = .overCurrentContext
        present(picturePickerVC, animated: true)
    }
    
    @objc private func didTapDeleteImage(){
        print("delete tapped")
        let deleteAlert = UIAlertController(title: "Are you sure you want to delete this image?", message: "", preferredStyle: UIAlertController.Style.alert)

        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action: UIAlertAction!) in
            self?.eventImage.image = UIImage()
            self?.deletePictureButton.isHidden = true
            self?.addPictureButton.isHidden = false
        }))

        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
              print("Handle Cancel Logic here")
        }))

        present(deleteAlert, animated: true, completion: nil)
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "PRIVATE"
        view.backgroundColor = .zipGray
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)


        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        
        configureTextFields()
        configureDefaultPicture()
        configureTable()
        addSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureHeader()
        layoutSubviews()
        scrollView.updateContentView()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        registerKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.updateContentView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    //MARK: - Header Cofnig
    private func configureHeader(){
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func configureTextFields() {
        dateTxt.delegate = self
        durationTxt.delegate = self
        locationTxt.delegate = self
        
        for view in titleText.subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .zipVeryLightGray
            }
        }
    }
    
    private func configureTable(){
        tableView.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCell.identifier)
//        tableView.register(ZipListTableViewCell.self, forCellReuseIdentifier: ZipListTableViewCell.notZippedIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
//        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator

    }

    //MARK: - AddSubviews
    private func addSubviews(){
        //Info
        scrollView.addSubview(infoLabel)
        
        //Title
        scrollView.addSubview(titleText)
        
        // Picture
        scrollView.addSubview(eventImage)
        scrollView.addSubview(deletePictureButton)
        eventImage.addSubview(addPictureButton)
        
        
        // Location
        scrollView.addSubview(locationLabel)
        scrollView.addSubview(locationTxt)
        
        // Date
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(dateTxt)
        
        // Start Time
        scrollView.addSubview(startTimeLabel)
        scrollView.addSubview(startTimeTxt)
        
        // Duration
        scrollView.addSubview(durationLabel)
        scrollView.addSubview(durationTxt)

        // Description
        scrollView.addSubview(descriptionLabel)
        scrollView.addSubview(descriptionTxt)
        
        // Invite Buttons
        scrollView.addSubview(invitedAllButton)
        scrollView.addSubview(clearButton)
        
        //Tableview
        scrollView.addSubview(tableView)
    }
    
    private func layoutSubviews(){
        //info label
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 5).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        
        //title
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 5).isActive = true
        titleText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Picture
        eventImage.translatesAutoresizingMaskIntoConstraints = false
        eventImage.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 10).isActive = true
        eventImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        eventImage.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        eventImage.heightAnchor.constraint(equalTo: eventImage.widthAnchor).isActive = true
        
        addPictureButton.translatesAutoresizingMaskIntoConstraints = false
        addPictureButton.centerYAnchor.constraint(equalTo: eventImage.centerYAnchor).isActive = true
        addPictureButton.centerXAnchor.constraint(equalTo: eventImage.centerXAnchor).isActive = true
        addPictureButton.heightAnchor.constraint(equalTo: eventImage.heightAnchor, multiplier: 0.5).isActive = true
        addPictureButton.widthAnchor.constraint(equalTo: addPictureButton.heightAnchor).isActive = true

        deletePictureButton.translatesAutoresizingMaskIntoConstraints = false
        deletePictureButton.topAnchor.constraint(equalTo: eventImage.topAnchor).isActive = true
        deletePictureButton.rightAnchor.constraint(equalTo: eventImage.rightAnchor).isActive = true
        deletePictureButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deletePictureButton.widthAnchor.constraint(equalTo: deletePictureButton.heightAnchor).isActive = true

        // Location
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.topAnchor.constraint(equalTo: eventImage.bottomAnchor,constant: 15).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        locationLabel.widthAnchor.constraint(equalToConstant: locationLabel.intrinsicContentSize.width).isActive = true
        
        locationTxt.translatesAutoresizingMaskIntoConstraints = false
        locationTxt.centerYAnchor.constraint(equalTo: locationLabel.centerYAnchor).isActive = true
        locationTxt.leftAnchor.constraint(equalTo: locationLabel.rightAnchor, constant: 10).isActive = true
        locationTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        // Date
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: locationTxt.bottomAnchor,constant: 10).isActive = true
        dateLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        dateTxt.translatesAutoresizingMaskIntoConstraints = false
        dateTxt.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        dateTxt.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 10).isActive = true
        dateTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        // StartTime
        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.topAnchor.constraint(equalTo: dateTxt.bottomAnchor,constant: 10).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        startTimeTxt.translatesAutoresizingMaskIntoConstraints = false
        startTimeTxt.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor).isActive = true
        startTimeTxt.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor, constant: 10).isActive = true
        startTimeTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true

        // Duration
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.topAnchor.constraint(equalTo: startTimeTxt.bottomAnchor,constant: 10).isActive = true
        durationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        durationTxt.translatesAutoresizingMaskIntoConstraints = false
        durationTxt.centerYAnchor.constraint(equalTo: durationLabel.centerYAnchor).isActive = true
        durationTxt.leftAnchor.constraint(equalTo: durationLabel.rightAnchor, constant: 10).isActive = true
        durationTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: durationLabel.bottomAnchor,constant: 10).isActive = true
        descriptionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        descriptionTxt.translatesAutoresizingMaskIntoConstraints = false
        descriptionTxt.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor,constant: 5).isActive = true
        descriptionTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        descriptionTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        descriptionTxt.heightAnchor.constraint(equalToConstant: 100).isActive = true

        // Invite Buttons
        invitedAllButton.translatesAutoresizingMaskIntoConstraints = false
        invitedAllButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        invitedAllButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        invitedAllButton.topAnchor.constraint(equalTo: descriptionTxt.bottomAnchor, constant: 10).isActive = true
        invitedAllButton.heightAnchor.constraint(equalTo: durationTxt.heightAnchor).isActive = true
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        clearButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        clearButton.topAnchor.constraint(equalTo: invitedAllButton.topAnchor).isActive = true
        clearButton.heightAnchor.constraint(equalTo: durationTxt.heightAnchor).isActive = true
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: invitedAllButton.bottomAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        if zipList.count > 8 {
            tableView.heightAnchor.constraint(equalToConstant: 8*80).isActive = true
        } else {
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(zipList.count*80)).isActive = true
        }

    }
    
    override func viewDidLayoutSubviews() {
        eventImage.layer.cornerRadius = eventImage.bounds.height/2
        eventImage.layer.masksToBounds = true
    }
    
    private func configureDefaultPicture() {
        eventImage.isUserInteractionEnabled = true
        eventImage.backgroundColor = .zipLightGray
        deletePictureButton.isHidden = true
        addPictureButton.isHidden = false
        
        deletePictureButton.addTarget(self, action: #selector(didTapDeleteImage), for: .touchUpInside)
        addPictureButton.addTarget(self, action: #selector(didTapAddImage), for: .touchUpInside)
    }

}


extension NewPrivateEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension NewPrivateEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InviteTableViewCell.identifier) as! InviteTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: ZipListTableViewCell.notZippedIdentifier) as! ZipListTableViewCell

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        cell.configure(zipList[indexPath.row])
        return cell
    }
    
    
}


extension NewPrivateEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleText {
            if textField.text == "Event Title" {
                textField.text = ""
            }
        } else if textField == locationTxt {
            textField.resignFirstResponder()
            let vc = SearchLocationViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == titleText {
            if textField.text == "" {
                textField.text = "Event Title"
            }
        }
    }
    
   
}



extension NewPrivateEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if  let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            eventImage.image = image
            addPictureButton.isHidden = true
            deletePictureButton.isHidden = false

            picker.dismiss(animated: false, completion: { [weak self] () -> Void in

                var imageCropVC : RSKImageCropViewController!
                imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
                imageCropVC.setBackgroundColor(.zipLightGray)

                imageCropVC.delegate = self

                self?.navigationController?.pushViewController(imageCropVC, animated: true)

            })

        } else {
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
}

extension NewPrivateEventViewController: RSKImageCropViewControllerDelegate {
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        eventImage.image = croppedImage
        event.image = croppedImage
        _ = navigationController?.popViewController(animated: true)
    }

    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        _ = navigationController?.popViewController(animated: true)
    }

}



extension NewPrivateEventViewController {
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow(notification:)),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide(notification:)),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.setContentOffset(CGPoint(x: 0, y: descriptionTxt.frame.height+5), animated: true)
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
