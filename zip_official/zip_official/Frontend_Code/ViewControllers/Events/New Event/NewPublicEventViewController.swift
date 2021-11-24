//
//  NewPublicEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/11/21.
//

import UIKit
import CoreLocation


class NewPublicEventViewController: UIViewController {
    var event = Event()
    
    var longTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Long",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
        return tf
    }()
    
    var latTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Lat",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
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
        tf.minimumFontSize = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
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
        tf.minimumFontSize = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .inline

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
        tf.minimumFontSize = 10.0
        
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
    
    var doneButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Done", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        return btn
    }()
    
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
    
    @objc func didTapDone(){
        print("Uploading to Firebase")
    }

    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        doneButton.addTarget(self, action: #selector(didTapDone), for: .touchUpInside)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)

        
        addSubviews()
        
    }
    
    
    private func addSubviews() {
        view.addSubview(latTxt)
        view.addSubview(longTxt)
        view.addSubview(startTimeTxt)
        view.addSubview(dateTxt)
        view.addSubview(descriptionTxt)
        view.addSubview(doneButton)
//        view.addSubview(<#T##view: UIView##UIView#>)
//        view.addSubview(<#T##view: UIView##UIView#>)
//        view.addSubview(<#T##view: UIView##UIView#>)
//        view.addSubview(<#T##view: UIView##UIView#>)
//        view.addSubview(<#T##view: UIView##UIView#>)
//        view.addSubview(<#T##view: UIView##UIView#>)



    }
    
    override func viewDidLayoutSubviews() {
        latTxt.translatesAutoresizingMaskIntoConstraints = false
        latTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        latTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        latTxt.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        
        longTxt.translatesAutoresizingMaskIntoConstraints = false
        longTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        longTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        longTxt.topAnchor.constraint(equalTo: latTxt.bottomAnchor, constant: 20).isActive = true
        
        startTimeTxt.translatesAutoresizingMaskIntoConstraints = false
        startTimeTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        startTimeTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        startTimeTxt.topAnchor.constraint(equalTo: longTxt.bottomAnchor, constant: 20).isActive = true
        
        dateTxt.translatesAutoresizingMaskIntoConstraints = false
        dateTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        dateTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        dateTxt.topAnchor.constraint(equalTo: startTimeTxt.bottomAnchor, constant: 20).isActive = true
        
        descriptionTxt.translatesAutoresizingMaskIntoConstraints = false
        descriptionTxt.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        descriptionTxt.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        descriptionTxt.topAnchor.constraint(equalTo: dateTxt.bottomAnchor, constant: 20).isActive = true
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        doneButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        doneButton.topAnchor.constraint(equalTo: descriptionTxt.bottomAnchor, constant: 20).isActive = true

    }
    
    
    
}

/*

class NewPublicEventViewController: UIViewController {
    static let dateIdentifier = "date"
    static let numGuestsIdentifier = "numGuests"
    static let locationIdentifier = "location"
    
    var event = Event()
    
    private var tableView = UITableView()
    
    private var backButton = UIButton()
    
    private var eventImage = UIImageView()
    
    private var titleText: UITextField = {
        let tf = UITextField()
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.layer.cornerRadius = 5
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        tf.text = "Event Title"
        tf.clearButtonMode = .whileEditing
        tf.font = .zipTitle
        tf.textAlignment = .center
        return tf
    }()
    
    
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipBody
        label.tintColor = .white
        label.backgroundColor = .zipLightGray
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.3
        label.isUserInteractionEnabled = true
        label.text = "Enter Your Event Location"
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSearch))
        label.addGestureRecognizer(tap)
        
        return label
    }()
    


    
    
    
    lazy var eventDateTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Date",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .inline

        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return tf
    }()
    
    lazy var eventTimeTxt: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Start Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return tf
    }()
    
    lazy var eventEndTime: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Pick Your Event Duration",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.minuteInterval = 15
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(durationChanged), for: .valueChanged)
        return tf
    }()
    
    private var numGuestsTxt: UITextField = {
        let tf = UITextField()
        tf.font = .zipBody
        tf.textColor = .white
        tf.text = "1"
        tf.backgroundColor = .zipLightGray
        tf.layer.cornerRadius = 5
        tf.textAlignment = .center
        tf.keyboardType = .numberPad
        return tf
    }()
    
    private var guestStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.addTarget(self, action: #selector(numGuestsChanged), for: .valueChanged)
        stepper.backgroundColor = .zipLightGray
        stepper.layer.cornerRadius = 5
        stepper.value = 1
        stepper.setDecrementImage(stepper.decrementImage(for: .normal), for: .normal)
        stepper.setIncrementImage(stepper.incrementImage(for: .normal), for: .normal)
        stepper.tintColor = .white
        stepper.maximumValue = 100000
        return stepper
    }()
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        titleText.resignFirstResponder()
        eventDateTxt.resignFirstResponder()
        eventTimeTxt.resignFirstResponder()
        eventEndTime.resignFirstResponder()
        numGuestsTxt.resignFirstResponder()
    }
    
    @objc func dateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        eventDateTxt.text = formatter.string(from: sender.date)
        
        event.startTime = sender.date
    }
    
    @objc func durationChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "H"
        eventEndTime.text = formatter.string(from: sender.date) + " Hours "
        formatter.dateFormat = "m"
        eventEndTime.text = eventEndTime.text! + formatter.string(from: sender.date) + " Minutes"
    }
    
    @objc func numGuestsChanged(_ sender: UIStepper){
        numGuestsTxt.text = Int(sender.value).description
        if numGuestsTxt.text == "0" {
            numGuestsTxt.text = "∞"
        }

    }
    
    @objc private func openSearch(){
        let searchVC = PopupSearchViewController()
        searchVC.modalPresentationStyle = .overCurrentContext
        present(searchVC, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        
        configureTable()
        configureDefaultPicture()
        configureTitle()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        configureHeader()
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
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        tableView.clipsToBounds = false
    }
    
    private func configureTable() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditProfileViewController.photosIdentifier)
        tableView.register(NameTableViewCell.self, forCellReuseIdentifier: NameTableViewCell.identifier)
        tableView.register(GrowingCellTableViewCell.self, forCellReuseIdentifier: GrowingCellTableViewCell.identifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: EditProfileViewController.schoolIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NewPublicEventViewController.dateIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NewPublicEventViewController.numGuestsIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NewPublicEventViewController.locationIdentifier)

        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        tableView.contentInset = UIEdgeInsets(top: -22, left: 0, bottom: 0, right: 0)
        tableView.tableHeaderView?.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        tableView.separatorStyle = .none
        
        
        eventDateTxt.delegate = self
        eventEndTime.delegate = self
        

    }

    
    private func configureDefaultPicture() {
        eventImage.image = UIImage(named: "profilepicture")
    }
    
    private func configureTitle(){
        for view in titleText.subviews {
            if let button = view as? UIButton {
                button.setImage(button.image(for: .normal)?.withRenderingMode(.alwaysTemplate), for: .normal)
                button.tintColor = .zipVeryLightGray
            }
        }
    }
}


//MARK: - Table Delegate
extension NewPublicEventViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
            switch indexPath.section {
            case 0: return view.frame.width/2 + 10
            case 1,2,3,4,5: return 40
            case 6: return 100
            default: return UITableView.automaticDimension
            }
        } else {
            return 30
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.tableView {
            return 6
        } else {
            return 1
        }
    }
}

extension NewPublicEventViewController :  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewController.photosIdentifier, for: indexPath)
            cell.backgroundColor = .zipGray
            cell.contentView.addSubview(eventImage)
            eventImage.frame = CGRect(x: view.frame.width/4, y: 5, width: view.frame.width/2, height: view.frame.width/2)
            eventImage.layer.cornerRadius = view.frame.width/4
            eventImage.layer.masksToBounds = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewPublicEventViewController.locationIdentifier, for: indexPath)
            let label = UILabel()
            label.font = .zipBody
            label.textColor = .white
            label.text = "Location: "
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true

            cell.contentView.addSubview(locationLabel)
            locationLabel.translatesAutoresizingMaskIntoConstraints = false
            locationLabel.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            locationLabel.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10).isActive = true
            locationLabel.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            locationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true

            locationLabel.layer.cornerRadius = 5
            cell.backgroundColor = .zipGray
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewPublicEventViewController.dateIdentifier, for: indexPath)
            
            let label = UILabel()
            label.font = .zipBody
            label.textColor = .white
            label.text = "Date: "
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true

            cell.contentView.addSubview(eventDateTxt)
            eventDateTxt.translatesAutoresizingMaskIntoConstraints = false
            eventDateTxt.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            eventDateTxt.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10).isActive = true
            eventDateTxt.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            eventDateTxt.heightAnchor.constraint(equalToConstant: 30).isActive = true

            cell.backgroundColor = .zipGray
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewPublicEventViewController.dateIdentifier, for: indexPath)
            
            let label = UILabel()
            label.font = .zipBody
            label.textColor = .white
            label.text = "Start Time: "
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true

            cell.contentView.addSubview(eventTimeTxt)
            eventTimeTxt.translatesAutoresizingMaskIntoConstraints = false
            eventTimeTxt.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            eventTimeTxt.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10).isActive = true
            eventTimeTxt.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            eventTimeTxt.heightAnchor.constraint(equalToConstant: 30).isActive = true

            cell.backgroundColor = .zipGray
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewPublicEventViewController.dateIdentifier, for: indexPath)
            cell.contentView.addSubview(eventEndTime)
            
            let label = UILabel()
            label.font = .zipBody
            label.textColor = .white
            label.text = "Duration: "
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true

            eventEndTime.translatesAutoresizingMaskIntoConstraints = false
            eventEndTime.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            eventEndTime.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10).isActive = true
            eventEndTime.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            eventEndTime.heightAnchor.constraint(equalToConstant: 30).isActive = true

            cell.backgroundColor = .zipGray
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewPublicEventViewController.numGuestsIdentifier, for: indexPath)
            cell.backgroundColor = .zipGray
            let label = UILabel()
            label.font = .zipBody
            label.textColor = .white
            label.text = "Max # of Guests: "
            cell.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.leftAnchor.constraint(equalTo: cell.contentView.leftAnchor, constant: 10).isActive = true
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalToConstant: label.intrinsicContentSize.width).isActive = true
            
            cell.contentView.addSubview(numGuestsTxt)
            numGuestsTxt.translatesAutoresizingMaskIntoConstraints = false
            numGuestsTxt.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 10).isActive = true
            numGuestsTxt.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            numGuestsTxt.widthAnchor.constraint(greaterThanOrEqualTo: numGuestsTxt.heightAnchor).isActive = true

            cell.contentView.addSubview(guestStepper)
            guestStepper.translatesAutoresizingMaskIntoConstraints = false
            guestStepper.rightAnchor.constraint(equalTo: cell.contentView.rightAnchor, constant: -10).isActive = true
            guestStepper.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileViewController.photosIdentifier, for: indexPath)
            cell.backgroundColor = .zipGray
            return cell
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
}



extension NewPublicEventViewController: UITextFieldDelegate {
    
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






extension NewPublicEventViewController: GrowingCellProtocol {
    func updateHeightOfRow(_ cell: GrowingCellTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = tableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func updateValue(value: String){
        
    }
}


extension NewPublicEventViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.editedImage] as? UIImage {
            eventImage.image = image
        }
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}



*/
