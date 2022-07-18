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


class CreateEventViewController: UIViewController {
    var event: Event
    
    private let eventNameLabel: UILabel
    private let startTimeLabel: UILabel
    private let locationLabel: UILabel
    private let endTimeLabel: UILabel
    
    private let endDatePicker: UIDatePicker
    private let endTimePicker: UIDatePicker
    
    
    private let eventNameField: UITextField
    private let startDateField: UITextField
    private let startTimeField: UITextField
    private let endDateField: UITextField
    private let endTimeField: UITextField
    
    private let locationField: UITextField
    
    private let continueButton: UIButton
    
    private let pageStatus1: StatusCheckView
    private let pageStatus2: StatusCheckView
    private let pageStatus3: StatusCheckView
    
    init(event: Event) {
        self.event = event
        self.eventNameLabel = UILabel.zipTextFill()
        self.startTimeLabel = UILabel.zipTextFill()
        self.locationLabel = UILabel.zipTextFill()
        self.endTimeLabel = UILabel.zipTextFill()
        
        self.eventNameField = UITextField()
        self.startDateField = UITextField()
        self.startTimeField = UITextField()
        self.endDateField = UITextField()
        self.endTimeField = UITextField()
        self.locationField = UITextField()
        
        self.pageStatus1 = StatusCheckView()
        self.pageStatus2 = StatusCheckView()
        self.pageStatus3 = StatusCheckView()
        
        self.endDatePicker = UIDatePicker()
        self.endTimePicker = UIDatePicker()
        
        self.continueButton = UIButton()

        super.init(nibName: nil, bundle: nil)

        eventNameLabel.text = "Event Name:"
        startTimeLabel.text = "Start Time: "
        locationLabel.text = "Event Location"
        endTimeLabel.text = "End Time: "
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .zipBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 15
        continueButton.layer.masksToBounds = true
        continueButton.titleLabel?.font = .zipBodyBold//.withSize(20)
       
        pageStatus1.select()
        
        configureTextFields()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextFields() {
        endDatePicker.datePickerMode = .date
        endDatePicker.minuteInterval = 15
        endDatePicker.preferredDatePickerStyle = .inline
        endDatePicker.minimumDate = Date()
        endDatePicker.addTarget(self, action: #selector(endDateChanged), for: .valueChanged)

        
        endDateField.inputView = endDatePicker
        
        
        endTimePicker.datePickerMode = .time
        endTimePicker.minuteInterval = 15
        endTimePicker.preferredDatePickerStyle = .wheels
        endTimePicker.addTarget(self, action: #selector(endTimeChanged), for: .valueChanged)

        endTimeField.inputView = endTimePicker
        
        eventNameField.returnKeyType = .continue
        eventNameField.borderStyle = .roundedRect
        eventNameField.attributedPlaceholder = NSAttributedString(string: "Ex. Ezra's Birthday Bash",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                               NSAttributedString.Key.font: UIFont.zipBodyBold])
        
        eventNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        eventNameField.leftViewMode = .always
        eventNameField.backgroundColor = .zipLightGray
        eventNameField.tintColor = .white
        eventNameField.textColor = .white
        eventNameField.font = .zipBodyBold

        
        startDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        startDateField.font = .zipBody
        startDateField.borderStyle = .roundedRect
        startDateField.tintColor = .white
        startDateField.backgroundColor = .zipLightGray
        startDateField.textColor = .white
        startDateField.adjustsFontSizeToFitWidth = true
        startDateField.minimumFontSize = 10.0
        startDateField.textAlignment = .center

            
        let startDatePicker = UIDatePicker()
        startDatePicker.datePickerMode = .date
        startDatePicker.minuteInterval = 15
        startDatePicker.preferredDatePickerStyle = .inline
        
        startDatePicker.minimumDate = Date()
        startDateField.inputView = startDatePicker
            
        startDatePicker.addTarget(self, action: #selector(startDateChanged), for: .valueChanged)
        

        startTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        startTimeField.font = .zipBody
        startTimeField.borderStyle = .roundedRect
        startTimeField.tintColor = .white
        startTimeField.backgroundColor = .zipLightGray
        startTimeField.textColor = .white
        startTimeField.adjustsFontSizeToFitWidth = true
        startTimeField.minimumFontSize = 10.0
        startTimeField.textAlignment = .center
            
        let startTimePicker = UIDatePicker()
        startTimePicker.datePickerMode = .time
        startTimePicker.minuteInterval = 15
        startTimePicker.preferredDatePickerStyle = .wheels
        startTimeField.inputView = startTimePicker
            
        startTimePicker.addTarget(self, action: #selector(startTimeChanged), for: .valueChanged)
        
        
        endTimeField.attributedPlaceholder = NSAttributedString(string: "Time",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        endTimeField.font = .zipBody
        endTimeField.borderStyle = .roundedRect
        endTimeField.tintColor = .white
        endTimeField.backgroundColor = .zipLightGray
        endTimeField.textColor = .white
        endTimeField.adjustsFontSizeToFitWidth = true
        endTimeField.minimumFontSize = 10.0
        endTimeField.textAlignment = .center
        
        
        endDateField.attributedPlaceholder = NSAttributedString(string: "Date",
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        endDateField.font = .zipBody
        endDateField.borderStyle = .roundedRect
        endDateField.tintColor = .white
        endDateField.backgroundColor = .zipLightGray
        endDateField.textColor = .white
        endDateField.adjustsFontSizeToFitWidth = true
        endDateField.minimumFontSize = 10.0
        endDateField.textAlignment = .center
        
        locationField.attributedPlaceholder = NSAttributedString(string: "Enter Your Event Location",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        locationField.font = .zipBody
        locationField.borderStyle = .roundedRect
        locationField.tintColor = .white
        locationField.backgroundColor = .zipLightGray
        locationField.textColor = .white
        locationField.adjustsFontSizeToFitWidth = true
        locationField.minimumFontSize = 10.0
        
        locationField.rightViewMode = .always
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
        
        locationField.rightView = view
        
    
    }
    
    private func checkStartBeforeEnd() {
        if event.startTime > event.endTime {
            endTimeField.text = ""
            endDateField.text = ""
        }
        
        endTimePicker.minimumDate = Date(timeInterval: TimeInterval(3600), since: event.startTime)
        endDatePicker.minimumDate = event.startTime
    }
    
    @objc func startDateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        startDateField.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: sender.date, time: event.startTime) ?? event.startTime
        
        checkStartBeforeEnd()
    }

    @objc func startTimeChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        startTimeField.text = formatter.string(from: sender.date)
        
        event.startTime = combineDateWithTime(date: event.startTime, time: sender.date)!
        
        checkStartBeforeEnd()
    }
    
    @objc func endDateChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        endDateField.text = formatter.string(from: sender.date)
        
        event.endTime = combineDateWithTime(date: sender.date, time: event.endTime) ?? event.endTime
        
        let diff = Calendar.current.dateComponents([.day], from: event.startTime, to: event.endTime)
        if diff.day == 0 {
            endTimePicker.minimumDate = Date(timeInterval: TimeInterval(3600), since: event.startTime)
        } else {
            endTimePicker.minimumDate = .none
        }
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
    
    @objc private func didTapContinueButton(){
        guard eventNameField.text != "",
              startDateField.text != "",
              startTimeField.text != "",
              endTimeField.text != "",
              endDateField.text != "",
              locationField.text != "",
              let eventTitle = eventNameField.text
        else {
//                  let alert = UIAlertController(title: "Complete All Fields To Conitnue",
//                                                      message: "",
//                                                      preferredStyle: .alert)
//
//                  alert.addAction(UIAlertAction(title: "Continue",
//                                                      style: .cancel,
//                                                      handler: nil))
//
//                  present(alert, animated: true)
            return
        }
        
        event.title = eventTitle
        
        let vc = CreateEventInfoViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }


    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        eventNameField.resignFirstResponder()
        startDateField.resignFirstResponder()
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        configureNavBar()
        
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard (_:)))
        view.addGestureRecognizer(tapGesture)
        
        locationField.delegate = self
        
        addSubviews()
        layoutSubviews()
    }
    
    @objc private func didTapDismiss(){
        navigationController?.popViewController(animated: true)
    }
    
    private func configureNavBar(){
        title = "Create Event"
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
        
        view.addSubview(startTimeLabel)
        view.addSubview(startDateField)
        view.addSubview(startTimeField)
        
        view.addSubview(endTimeLabel)
        view.addSubview(endDateField)
        view.addSubview(endTimeField)
        
        view.addSubview(locationLabel)
        
        view.addSubview(locationLabel)
        view.addSubview(locationField)
     
        
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

        startTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        startTimeLabel.topAnchor.constraint(equalTo: eventNameField.bottomAnchor, constant: 40).isActive = true
        startTimeLabel.leftAnchor.constraint(equalTo: eventNameField.leftAnchor).isActive = true
        
        startDateField.translatesAutoresizingMaskIntoConstraints = false
        startDateField.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor, constant: 5).isActive = true
        startDateField.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor).isActive = true
        
        startTimeField.translatesAutoresizingMaskIntoConstraints = false
        startTimeField.leftAnchor.constraint(equalTo: startDateField.rightAnchor, constant: 10).isActive = true
        startTimeField.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor).isActive = true
        
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.topAnchor.constraint(equalTo: startDateField.bottomAnchor, constant: 20).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: startTimeLabel.leftAnchor).isActive = true
        
        endDateField.translatesAutoresizingMaskIntoConstraints = false
        endDateField.leftAnchor.constraint(equalTo: startDateField.leftAnchor).isActive = true
        endDateField.centerYAnchor.constraint(equalTo: endTimeLabel.centerYAnchor).isActive = true
        
        endTimeField.translatesAutoresizingMaskIntoConstraints = false
        endTimeField.centerYAnchor.constraint(equalTo: endDateField.centerYAnchor).isActive = true
        endTimeField.leftAnchor.constraint(equalTo: startTimeField.leftAnchor).isActive = true
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 40).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: endTimeLabel.leftAnchor).isActive = true
        
        locationField.translatesAutoresizingMaskIntoConstraints = false
        locationField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10).isActive = true
        locationField.leftAnchor.constraint(equalTo: locationLabel.leftAnchor).isActive = true
        locationField.rightAnchor.constraint(equalTo: eventNameLabel.rightAnchor).isActive = true
        
        
        
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
        event.coordinates = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
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

