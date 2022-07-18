//
//  SchoolSearchViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/3/21.
//

import UIKit

protocol UpdateSchoolProtocol {
    func updateSchoolLabel(_ school: String)
}

class SchoolSearchViewController: UIViewController, UpdateSchoolProtocol {
    var delegate: UpdateSchoolProtocol?
    
    func updateSchoolLabel(_ school: String){
        delegate?.updateSchoolLabel(schoolLabel.text ?? "")
    }
    
    var searchBar = UISearchBar()
    
    var tableView = UITableView()
    var allData: [String] = ["None",
                             "McGill University",
                             "Harvard University",
                             "Vanderbilt University",
                             "Concordia University",
                             "Boston College",
                             "Boston University",
                             "Massachusetts Institue of Technology"]
    var filteredData: [String] = []
    
    
    var schoolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()


    var searching = false
        
    @objc private func didTapDoneButton(){
        updateSchoolLabel(schoolLabel.text ?? "")
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.title = "Edit School"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapDoneButton))
        
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        searchBar.backgroundColor = .red
        searchBar.delegate = self
        searchBar.tintColor = .zipGray
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        
        view.addSubview(schoolLabel)
        view.addSubview(tableView)
        view.addSubview(searchBar)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        schoolLabel.translatesAutoresizingMaskIntoConstraints = false
        schoolLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        schoolLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10).isActive = true
        schoolLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: schoolLabel.bottomAnchor, constant: 10).isActive = true
        searchBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        searchBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}


extension SchoolSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = allData.filter({$0.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
}


extension SchoolSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return filteredData.count
        }
        return allData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        if searching {
            cell.textLabel?.text = filteredData[indexPath.row]
        } else {
            cell.textLabel?.text = allData[indexPath.row]
        }

        cell.textLabel?.font = .zipBody
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .zipGray
        
        return cell
    }
    
    
}

extension SchoolSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        schoolLabel.text = tableView.cellForRow(at: indexPath)?.textLabel?.text
    }
}
