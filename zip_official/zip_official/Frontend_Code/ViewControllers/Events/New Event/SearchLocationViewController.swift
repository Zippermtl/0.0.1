//
//  SearchLocationViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/12/21.
//

import UIKit
import CoreLocation


class SearchLocationViewController: UIViewController, UISearchResultsUpdating {
    let searchVC = UISearchController(searchResultsController: LocationResultsViewController())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Location"
        searchVC.searchBar.backgroundColor = .zipLightGray
        searchVC.searchResultsUpdater = self
    }
    

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? LocationResultsViewController
        else { return }

        resultsVC.delegate = self

        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }

}


extension SearchLocationViewController: LocationResultsViewControllerDelegate {
    func didTapPlace(with coordinate: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true, completion: nil)
    }
}
