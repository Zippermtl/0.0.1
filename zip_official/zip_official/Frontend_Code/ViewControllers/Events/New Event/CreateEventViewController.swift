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
import MapKit


class CreateEventViewController: UIViewController {
    var event: Event
    
    private let mapView: MKMapView
    private let eventNameLabel: UILabel
    private let startTimeLabel: UILabel
    private let locationLabel: UILabel
    private let endTimeLabel: UILabel
    
    
    private let eventNameField: UITextField
    private let datePicker: EventDatePickerView
    private let locationField: UITextField
    
    private let continueButton: UIButton
    
    private let pageStatus1: StatusCheckView
    private let pageStatus2: StatusCheckView
    private let pageStatus3: StatusCheckView
    
    init(event: Event) {
        self.event = event
        event.eventId = event.createEventId

        self.datePicker = EventDatePickerView(event: event)
        
        self.mapView = MKMapView()
        self.eventNameLabel = UILabel.zipTextFillBold()
        self.startTimeLabel = UILabel.zipTextFillBold()
        self.locationLabel = UILabel.zipTextFillBold()
        self.endTimeLabel = UILabel.zipTextFillBold()
        
        self.locationField = UITextField()
        self.eventNameField = UITextField()

        
        self.pageStatus1 = StatusCheckView()
        self.pageStatus2 = StatusCheckView()
        self.pageStatus3 = StatusCheckView()
        
        
        self.continueButton = UIButton()

        super.init(nibName: nil, bundle: nil)
        mapView.delegate = self
        mapView.isUserInteractionEnabled = false
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: "pin")
        
        eventNameLabel.text = "Event Name:"
        startTimeLabel.text = "Start Time: "
        locationLabel.text = "Event Location"
        endTimeLabel.text = "End Time: "
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.backgroundColor = .zipBlue
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.layer.cornerRadius = 15
        continueButton.layer.masksToBounds = true
        continueButton.titleLabel?.font = .zipSubtitle2
       
        
        pageStatus1.select()
        configureTextFields()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        eventNameField.inputAccessoryView = doneToolbar
        locationField.inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction(){
        eventNameField.resignFirstResponder()
        locationField.resignFirstResponder()
    }
    
    
    private func configureTextFields() {
        
        
        eventNameField.returnKeyType = .continue
        eventNameField.borderStyle = .roundedRect
        eventNameField.attributedPlaceholder = NSAttributedString(string: "Ex. Ezra's Birthday Bash",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray,
                                                                               NSAttributedString.Key.font: UIFont.zipTextFill])
        
        eventNameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        eventNameField.leftViewMode = .always
        eventNameField.backgroundColor = .zipLightGray
        eventNameField.tintColor = .white
        eventNameField.textColor = .white
        eventNameField.font = .zipTextFill

        locationField.font = .zipTextFill
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

    
    @objc private func didTapContinueButton(){
        guard eventNameField.text != "",
              datePicker.isSet,
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
        
        let vc = CustomizeEventViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }


    
    @objc private func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
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
    

    
    private func configureNavBar(){
        title = "Create Event"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func addSubviews(){
        view.addSubview(eventNameLabel)
        view.addSubview(eventNameField)
        
        view.addSubview(startTimeLabel)
        view.addSubview(datePicker)
        view.addSubview(endTimeLabel)

        
        view.addSubview(locationLabel)
        
        view.addSubview(locationLabel)
        view.addSubview(locationField)
     
        view.addSubview(mapView)
        
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
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.startDateField.centerYAnchor.constraint(equalTo: startTimeLabel.centerYAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: startTimeLabel.rightAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        endTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        endTimeLabel.centerYAnchor.constraint(equalTo: datePicker.endDateField.centerYAnchor).isActive = true
        endTimeLabel.leftAnchor.constraint(equalTo: startTimeLabel.leftAnchor).isActive = true
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.topAnchor.constraint(equalTo: endTimeLabel.bottomAnchor, constant: 40).isActive = true
        locationLabel.leftAnchor.constraint(equalTo: endTimeLabel.leftAnchor).isActive = true
        
        locationField.translatesAutoresizingMaskIntoConstraints = false
        locationField.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10).isActive = true
        locationField.leftAnchor.constraint(equalTo: locationLabel.leftAnchor).isActive = true
        locationField.rightAnchor.constraint(equalTo: eventNameLabel.rightAnchor).isActive = true
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: locationField.bottomAnchor, constant: 30).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor,constant: 20).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -20).isActive = true
        mapView.bottomAnchor.constraint(equalTo: continueButton.topAnchor,constant: -20).isActive = true

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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == eventNameField {
            let currentString = (textField.text ?? "") as NSString
            let str = currentString.replacingCharacters(in: range, with: string)
            if str.count > 30 { return false }
        }
        return true
    }
}


extension CreateEventViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let name = place.name,
              let address = place.formattedAddress else {
                  return
              }

  
        
        if address.contains(name) {
            locationField.text = name
            event.address = name
        } else {
            locationField.text = address
            event.address = address
        }
        event.coordinates = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        event.locationName = name
        zoomToEventLocation()
        navigationController?.popViewController(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.popViewController(animated: true)
    }
}


extension CreateEventViewController: MKMapViewDelegate {
    private func zoomToEventLocation(){
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = event.coordinates.coordinate
        mapView.addAnnotation(annotation)
        print("adding annotation")
        let zoomRegion = MKCoordinateRegion(center: event.coordinates.coordinate, latitudinalMeters: 2000,longitudinalMeters: 2000)
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        let imgView = UIImageView(image: UIImage(named: "locationpin"))
        imgView.contentMode = .scaleAspectFit
        annotationView?.addSubview(imgView)
        imgView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return annotationView
    }
}


