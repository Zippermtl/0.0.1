//
//  SearchLocationViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/12/21.
//

import UIKit
import CoreLocation


class SearchLocationViewController: UIViewController {
    let searchVC = UISearchController(searchResultsController: LocationResultsViewController())
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Event Location"
        view.backgroundColor = .zipGray
        searchVC.searchBar.backgroundColor = .zipLightGray
        searchVC.searchBar.tintColor = .white
        searchVC.searchResultsUpdater = self
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        navigationItem.searchController = searchVC
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}


extension SearchLocationViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? LocationResultsViewController
        else {
            return
        }
            
        LocationSearchManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print("Faield to find location \(error)")
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





