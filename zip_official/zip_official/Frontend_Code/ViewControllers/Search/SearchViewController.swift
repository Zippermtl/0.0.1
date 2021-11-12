//
//  SearchViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit

class SearchViewController: UIViewController {
    var headerView = UIView()
    var tableView = UITableView()
    
    var notificationsList: [String] = []
    var filteredList: [String] = []

    
    var searchBar: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .zipLightGray
        textField.attributedPlaceholder = NSAttributedString(string: "Search",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.zipVeryLightGray])
        textField.textColor = .white
        textField.font = .zipBody
        textField.autocorrectionType = .no
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.layer.cornerRadius = 10
        textField.leftViewMode = .always
        textField.tintColor = .white

        return textField
    }()
    
    @objc private func dismissKeyboard(){
        searchBar.resignFirstResponder()
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        configureNavBar()
        configureGestureRecognizer()
        configureSearchBar()
        addSubviews()
        configureSubviewLayout()
    }
    
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.title = "SEARCH"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func configureGestureRecognizer(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    
    //MARK: - Search Bar Config
    private func configureSearchBar(){
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
        let img = UIImageView(frame: CGRect(x: 5, y: 0, width: 25, height: 25))
        img.image = UIImage(named: "clock")
        img.contentMode = .scaleAspectFit
        iconContainer.addSubview(img)
        searchBar.leftView = iconContainer
    }

    //MARK: - AddSubviews
    private func addSubviews(){
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    
    private func configureSubviewLayout(){
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }


}
