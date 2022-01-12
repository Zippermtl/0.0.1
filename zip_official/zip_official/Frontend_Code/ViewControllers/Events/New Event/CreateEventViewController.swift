//
//  CreateEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/6/22.
//

import UIKit
import CoreLocation
import RSKImageCropper
import DropDown
import GooglePlaces

protocol MaintainEventDelegate: AnyObject {
    func updateEvent(event: Event)
}

class CreateEventViewController: UIViewController {
    var event = Event()

    private let eventNameLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Event Name:"
        return label
    }()
    
    private let dateAndTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Date/Time: "
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Event Location:"
        return label
    }()
    
    private let privacyLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "Private Event?"
        return label
    }()
    
    private let endTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        label.text = "End Time: "
        label.isHidden = true
        return label
    }()
    
    private let privacySwitch = UISwitch()

    private let eventNameField: UITextField = {
        let field = UITextField()
        field.returnKeyType = .continue
        field.borderStyle = .roundedRect
        field.attributedPlaceholder = NSAttributedString(string: "Ex. Ezra's Birthday Bash",
                                                         attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                      NSAttributedString.Key.font: UIFont.zipBodyBold])
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .zipLightGray
        field.tintColor = .white
        field.textColor = .white
        field.font = .zipBodyBold
        return field
    }()
    
    var dateField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Date",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        tf.textAlignment = .center

        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .inline

        datePicker.minimumDate = Date()
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return tf
    }()
    
    var startTimeField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        tf.textAlignment = .center
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .wheels
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        return tf
    }()
    
    var endTimeField: UITextField = {
        let tf = UITextField()
        tf.isHidden = true
        tf.attributedPlaceholder = NSAttributedString(string: "Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        tf.textAlignment = .center
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.minuteInterval = 15
        datePicker.preferredDatePickerStyle = .wheels
        tf.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)
        return tf
    }()
    
    private var locationField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(string: "Enter Your Event Location",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        tf.font = .zipBody
        tf.borderStyle = .roundedRect
        tf.tintColor = .white
        tf.backgroundColor = .zipLightGray
        tf.textColor = .white
        tf.adjustsFontSizeToFitWidth = true
        tf.minimumFontSize = 10.0
        
        tf.rightViewMode = .always
        let view = UIView()
        let symbol = UIImage(systemName: "chevron.right")?
                                .withRenderingMode(.alwaysOriginal)
                                .withTintColor(.zipVeryLightGray)
        let btn = UIImageView(image: symbol)
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        btn.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        btn.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        btn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
        
        tf.rightView = view
        
        return tf
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
    
    private let closeEndTimeButton: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.setImage(UIImage(systemName: "xmark")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray), for: .normal)
        return btn
    }()
    
    private let pageStatus1: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus2 = StatusCheckView()
    private let pageStatus3 = StatusCheckView()
    
    @objc func dateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateField.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: sender.date, time: event.startTime) ?? event.startTime
    }

    @objc func startTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeField.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: event.startTime, time: sender.date)!
    }
    
    @objc func endTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        endTimeField.text = formatter.string(from: sender.date)
        
        event.endTime = combineDateWithTime(date: event.startTime, time: sender.date)!
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
    
    private let addEndTimeButton: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        btn.setAttributedTitle(NSMutableAttributedString(string: "Add End Time +", attributes: attributes), for: .normal)
        return btn
    }()
    
    @objc private func didTapContinueButton(){
        let vc = CreateEventInfoViewController()
        vc.delegate = self
        vc.event = event
        navigationController?.pushViewController(vc, animated: true)
    }

    
    @objc private func didTapAddEndTimeButton(){
        addEndTimeButton.isHidden = true
        endTimeField.isHidden = false
        endTimeLabel.isHidden = false
        closeEndTimeButton.isHidden = false
    }
    
    @objc private func didTapCloseEndTimeButton(){
        addEndTimeButton.isHidden = false
        endTimeField.isHidden = true
        endTimeLabel.isHidden = true
        closeEndTimeButton.isHidden = true
    }
    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        eventNameField.resignFirstResponder()
        dateField.resignFirstResponder()
        startTimeField.resignFirstResponder()
        endTimeField.resignFirstResponder()

    }
    
    @objc private func openSearch(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        // Customize VC
        autocompleteController.navigationController?.navigationBar.tintColor = .zipGray
        autocompleteController.navigationItem.searchController?.searchBar.tintColor = .zipLightGray
        autocompleteController.primaryTextHighlightColor = .white
        autocompleteController.primaryTextColor = .zipVeryLightGray
        autocompleteController.secondaryTextColor = .zipVeryLightGray
        autocompleteController.tableCellSeparatorColor = .zipVeryLightGray
        autocompleteController.tableCellBackgroundColor = .zipGray
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField (
            rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.addressComponents.rawValue) |
            UInt(GMSPlaceField.formattedAddress.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue)

        )
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        navigationController?.pushViewController(autocompleteController, animated: true)
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        event.isPublic = !sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        configureNavBar()
        privacySwitch.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
        addEndTimeButton.addTarget(self, action: #selector(didTapAddEndTimeButton), for: .touchUpInside)
        closeEndTimeButton.addTarget(self, action: #selector(didTapCloseEndTimeButton), for: .touchUpInside)
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        
        locationField.delegate = self
        
        addSubviews()
        layoutSubviews()
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    private func configureNavBar(){
        title = "CREATE EVENT"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
    }
    
    private func addSubviews(){
        view.addSubview(eventNameLabel)
        view.addSubview(eventNameField)
        view.addSubview(dateAndTimeLabel)
        view.addSubview(dateField)
        view.addSubview(startTimeField)
        view.addSubview(addEndTimeButton)
        view.addSubview(locationLabel)
        view.addSubview(dateAndTimeLabel)
        view.addSubview(endTimeLabel)
        view.addSubview(endTimeField)
        view.addSubview(closeEndTimeButton)
        view.addSubview(locationLabel)
        view.addSubview(locationField)
        view.addSubview(privacyLabel)
        view.addSubview(privacySwitch)
        
        view.addSubview(continueButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)

    }
    
    private func layoutSubviews() {
        eventNameLabel.translatesAutoresizingMaskIntoConstraints = false
        eventNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        eventNameLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        eventNameLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
        eventNameField.translatesAutoresizingMaskIntoConstraints = false
        eventNameField.topAnchor.constraint(equalTo: eventNameLabel.bottomAnchor, constant: 10).isActive = true
        eventNameField.leftAnchor.constraint(equalTo: eventNameLabel.leftAnchor).isActive = true
        eventNameField.rightAnchor.constraint(equalTo: eventNameLabel.rightAnchor).isActive = true

        dateAndTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateAndTimeLabel.topAnchor.constraint(equalTo: eventNameField.bottomAnchor, constant: 40).isActive = true
        dateAndTimeLabel.leftAnchor.constraint(equalTo: eventNameField.leftAnchor).isActive = true
        
        dateField.translatesAutoresizingMaskIntoConstraints = false
        dateField.leftAnchor.constraint(equalTo: dateAndTimeLabel.rightAnchor, constant: 5).isActive = true
        dateField.centerYAnchor.constraint(equalTo: dateAndTimeLabel.centerYAnchor).isActive = true
        
        startTimeField.translatesAutoresizingMaskIntoConstraints = false
        startTimeField.leftAnchor.constraint(equalTo: dateField.rightAnchor, constant: 5).isActive = true
        startTimeField.centerYAnchor.constraint(equalTo: dateAndTimeLabel.centerYAnchor).isActive = true
        
        addEndTimeButton.translatesAutoresizingMaskIntoConstraints = false
        addEndTimeButton.topAnchor.constraint(equalTo: dateAndTimeLabel.bottomAnchor, constant: 10).isActive = true
        addEndTimeButton.leftAnchor.constraint(equalTo: dateAndTimeLabel.leftAnchor).isActive = true
        
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.topAnchor.constraint(equalTo: dateField.bottomAnchor, constant: 10).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: closeEndTimeButton.rightAnchor, constant: 10).isActive = true
        
        endTimeField.translatesAutoresizingMaskIntoConstraints = false
        endTimeField.centerYAnchor.constraint(equalTo: endTimeLabel.centerYAnchor).isActive = true
        endTimeField.leftAnchor.constraint(equalTo: startTimeField.leftAnchor).isActive = true
        
        closeEndTimeButton.translatesAutoresizingMaskIntoConstraints = false
        closeEndTimeButton.centerYAnchor.constraint(equalTo: endTimeLabel.centerYAnchor).isActive = true
        closeEndTimeButton.leftAnchor.constraint(equalTo: eventNameLabel.leftAnchor).isActive = true
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.topAnchor.constraint(equalTo: addEndTimeButton.bottomAnchor, constant: 40).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: addEndTimeButton.leftAnchor).isActive = true
        
        locationField.translatesAutoresizingMaskIntoConstraints = false
        locationField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10).isActive = true
        locationField.leftAnchor.constraint(equalTo: locationLabel.leftAnchor).isActive = true
        locationField.rightAnchor.constraint(equalTo: eventNameLabel.rightAnchor).isActive = true
        
        privacyLabel.translatesAutoresizingMaskIntoConstraints = false
        privacyLabel.topAnchor.constraint(equalTo: locationField.bottomAnchor, constant: 40).isActive = true
        privacyLabel.leftAnchor.constraint(equalTo: locationField.leftAnchor).isActive = true
        
        privacySwitch.translatesAutoresizingMaskIntoConstraints = false
        privacySwitch.centerYAnchor.constraint(equalTo: privacyLabel.centerYAnchor).isActive = true
        privacySwitch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        
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

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == locationField {
            textField.resignFirstResponder()
            openSearch()
        }
    }
}


extension CreateEventViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let name = place.name,
              let address = place.formattedAddress else {
                  return
              }
        
        if name.range(of: address) != nil { // if name is included in address
            locationField.text = name
        } else {
            locationField.text = name + ", " + address.split(separator: ",")[0]
        }
        
        event.coordinates = place.coordinate
        event.address = address
        event.locationName = name
        navigationController?.popViewController(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.popViewController(animated: true)
    }
}

extension CreateEventViewController: MaintainEventDelegate {
    func updateEvent(event: Event) {
        self.event = event
    }
}
