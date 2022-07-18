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
    
    internal class EditEventLocationTableViewCell: EditTextFieldTableViewCell {
        weak var GMSDelegate: OpenGMSCellDelegate?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textView.delegate = self
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        public func configure(event: Event) {
            super.configure(label: "Location", content: event.address)
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
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? EditEventLocationTableViewCell else {
            return
        }
        
        if name.range(of: address) != nil { // if name is included in address
            cell.textView.text = name
        } else {
            cell.textView.text = name + ", " + address.split(separator: ",")[0]
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

