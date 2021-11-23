//
//  PopupSearchViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/15/21.
//

import UIKit
import CoreLocation
import MapKit

class PopupSearchViewController: UIViewController, UISearchResultsUpdating, UINavigationBarDelegate {
    let mapView = MKMapView()
    
    let searchVC = UISearchController(searchResultsController: LocationResultsViewController())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let height: CGFloat = 75
        let navbar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height))
        navbar.backgroundColor = .zipGray
        navbar.delegate = self

        let navItem = UINavigationItem()
        navItem.title = "Title"
        navItem.leftBarButtonItem = UIBarButtonItem(title: "Left Button", style: .plain, target: self, action: nil)
        navItem.rightBarButtonItem = UIBarButtonItem(title: "Right Button", style: .plain, target: self, action: nil)

        navbar.items = [navItem]

        view.addSubview(navbar)

        
        title = "Maps"
        view.addSubview(mapView)
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
//        searchVC.searchBar.backgroundColor = .zipLightGray
//        searchVC.searchBar.placeholder = "Enter Your Event Location"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: 75, width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height - 75))

    }

    func updateSearchResults(for searchController: UISearchController) {
//        guard let query = searchController.searchBar.text,
//              !query.trimmingCharacters(in: .whitespaces).isEmpty,
//              let resultsVC = searchController.searchResultsController as? LocationResultsViewController
//        else { return }
//
//        resultsVC.delegate = self
//
//        GooglePlacesManager.shared.findPlaces(query: query) { result in
//            switch result {
//            case .success(let places):
//                DispatchQueue.main.async {
//                    resultsVC.update(with: places)
//                }
//            case .failure(let error):
//                print(error)
//            }
//
//        }
    }
}


extension PopupSearchViewController: LocationResultsViewControllerDelegate {
    func didTapPlace(with coordinate: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: false, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}
