//
//  NewPrivateEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/11/21.
//

import UIKit
import CoreLocation



class NewPrivateEventViewController: UIViewController {
    static let dateIdentifier = "date"
    static let numGuestsIdentifier = "numGuests"
    static let locationIdentifier = "location"
    
    var zipList: [User] = MapViewController.getTestUsers()
    
    var event = Event()
    
    
    private var backButton = UIButton()
    private var eventImage = UIImageView()
    
    private var scrollView = UIScrollView()
    
    private var titleText: UITextField = {
        let tf = UITextField()
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.layer.cornerRadius = 5
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0;
        tf.text = "Event Title"
        tf.clearButtonMode = .whileEditing
        tf.font = .zipTitle
        tf.textAlignment = .center
        return tf
    }()
    
    //MARK: Labels
    
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
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Date",
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
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
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
    
    let zippedButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Invite All", for: .normal)
        btn.titleLabel?.font = .zipBodyBold
        btn.backgroundColor = .zipLightGray
        btn.addTarget(self, action: #selector(didTapZippedButton), for: .touchUpInside)
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
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc private func didTapZippedButton(){
        print("Zipped Tapped")
    }
    
    @objc private func didTapClearButton(){
        print("clear Tappeed")
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
        formatter.timeStyle = .short
        dateTxt.text = formatter.string(from: sender.date)
        
        event.startTime = sender.date
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        scrollView.isScrollEnabled = true
        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height*1.5)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
            
        registerKeyboardNotifications()
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
        backButton.setImage(UIImage(named: "backarrow"), for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        view.addSubview(backButton)
        view.addSubview(titleText)

        titleText.delegate = self
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleText.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        titleText.widthAnchor.constraint(equalToConstant: view.frame.width/2).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: 46.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: titleText.centerYAnchor).isActive = true
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 5).isActive = true
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func configureTextFields() {
        dateTxt.delegate = self
        durationTxt.delegate = self
        
        for view in titleText.subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .zipVeryLightGray
            }
        }
    }
    
    private func configureTable(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCell.identifier)
        tableView.backgroundColor = .red
    }

    //MARK: - AddSubviews
    private func addSubviews(){
        // Picture
        scrollView.addSubview(eventImage)
        
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
        scrollView.addSubview(zippedButton)
        scrollView.addSubview(clearButton)
        
        //Tableview
        scrollView.addSubview(tableView)
    }
    
    private func layoutSubviews(){
        // Picture
        eventImage.frame = CGRect(x: view.frame.width/4, y: 5, width: view.frame.width/2, height: view.frame.width/2)
        eventImage.layer.cornerRadius = view.frame.width/4
        eventImage.layer.masksToBounds = true
        
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
        zippedButton.translatesAutoresizingMaskIntoConstraints = false
        zippedButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        zippedButton.rightAnchor.constraint(equalTo: view.centerXAnchor, constant: -5).isActive = true
        zippedButton.topAnchor.constraint(equalTo: descriptionTxt.bottomAnchor, constant: 10).isActive = true
        zippedButton.heightAnchor.constraint(equalTo: durationTxt.heightAnchor).isActive = true
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        clearButton.leftAnchor.constraint(equalTo: view.centerXAnchor, constant: 5).isActive = true
        clearButton.topAnchor.constraint(equalTo: zippedButton.topAnchor).isActive = true
        clearButton.heightAnchor.constraint(equalTo: durationTxt.heightAnchor).isActive = true
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: zippedButton.bottomAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
    }
    
    private func configureDefaultPicture() {
        eventImage.image = UIImage(named: "profilepicture")
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
        cell.selectionStyle = .none
        print("adding cell")
        cell.configure(with: zipList[indexPath.row])
        return cell
    }
    
    
}



extension NewPrivateEventViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == titleText {
            if textField.text == "Event Title" {
                textField.text = ""
            }
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
        if let image = info[.editedImage] as? UIImage {
            eventImage.image = image
        }
//        tableView.reloadData()
        dismiss(animated: true, completion: nil)
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
