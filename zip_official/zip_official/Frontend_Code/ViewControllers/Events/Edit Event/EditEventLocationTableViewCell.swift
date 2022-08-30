//
//  EditEventLocationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//
import GooglePlaces
import UIKit
protocol OpenGMSCellDelegate: AnyObject {
    func openSearch()
}

extension EditEventProfileViewController: OpenGMSCellDelegate {
    func openSearch(){
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
    
    internal class EditEventLocationTableViewCell: EditProfileTableViewCell, UITextViewDelegate {
        static let identifier = "locationCell"
        weak var GMSDelegate: OpenGMSCellDelegate?
        let textView: UITextView
        var saveFunc: ((String) -> Void)?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.textView = UITextView()

            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textView.showsHorizontalScrollIndicator = false
            textView.showsVerticalScrollIndicator = false
            textView.isScrollEnabled = false
            textView.delegate = self
            textView.bounces = false
            textView.layer.cornerRadius = 5
            textView.backgroundColor = .zipGray
            textView.font = .zipTextFill
            textView.textColor = .white
            textView.tintColor = .white
            
            rightView.addSubview(textView)
            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.topAnchor.constraint(equalTo: rightView.topAnchor).isActive = true
            textView.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            textView.rightAnchor.constraint(equalTo: rightView.rightAnchor).isActive = true
            textView.bottomAnchor.constraint(equalTo: rightView.bottomAnchor).isActive = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        public func configure(event: Event, saveFunc: @escaping (String) -> Void) {
            textView.text = event.address
            super.configure(label: "Location")
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            GMSDelegate?.openSearch()
            textView.resignFirstResponder()
        }
    }
  
    
    
}

extension EditEventProfileViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        guard let name = place.name,
              let address = place.formattedAddress else {
                  return
              }
        guard let name = place.name,
              let address = place.formattedAddress else {
                  return
              }

        event.coordinates = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        event.locationName = name
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? EditEventLocationTableViewCell else {
            return
        }
        
        if address.contains(name) {
            event.address = name
            cell.textView.text = name
        } else {
            event.address = address
            cell.textView.text = address
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        navigationController?.popViewController(animated: true)
    }
}

