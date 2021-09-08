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

    
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "SEARCH"
        return label
    }()
    
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
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        configureSearchBar()
        addSubviews()
        configureSubviewLayout()
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
        view.addSubview(headerView)
        headerView.addSubview(searchBar)
        headerView.addSubview(pageTitleLabel)
        
        view.addSubview(tableView)
    }
    
    private func configureSubviewLayout(){
        configureHeader()


        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        
  
    }
    
    
    //MARK: - Header Config
    private func configureHeader(){
        headerView.backgroundColor = .zipGray
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10).isActive = true
        headerView.backgroundColor = .zipGray
        
        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor,constant: 20).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        //Search Bar
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 10).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        searchBar.heightAnchor.constraint(equalTo: pageTitleLabel.heightAnchor).isActive = true
    }

}
