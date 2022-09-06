//
//  NewChatViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/4/21.
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {
    public var completion: ((User) -> Void)?

    private let spinner = JGProgressHUD(style: .light)
    
    private var allUsers : [User]
    
    private var results =  [User]()
    
    private var hasFetched = false

    init() {
        self.allUsers = User.getMyZips()
        print(allUsers)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for Users..."
        
        let tf = searchBar.value(forKey: "searchField") as? UITextField
        tf?.textColor = .white
        
        return searchBar
    }()
    
    @objc private func dismissSelf(){
        dismiss(animated: true, completion : nil)
    }
    
    let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(MyZipsTableViewCell.self, forCellReuseIdentifier: MyZipsTableViewCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .zipLightGray
        label.font = .zipSubtitle2
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noResultsLabel)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.backgroundColor = .zipGray
        searchBar.delegate = self
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.frame.width/4,
                                      y: (view.frame.height-200)/2,
                                      width: view.frame.width/2,
                                      height: 200)
    }

}

extension NewChatViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.replacingOccurrences(of: " ", with: "").isEmpty else {
            results = allUsers
            return
        }
                
        results.removeAll()
        spinner.show(in: view)
        
        filterUsers(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        
        filterUsers(with: text)
    }
    
    func filterUsers(with term: String) {
        spinner.dismiss()
        
        self.results = allUsers.filter({
            $0.firstName.lowercased().hasPrefix(term.lowercased()) ||
            $0.lastName.lowercased().hasPrefix(term.lowercased()) ||
            $0.username.lowercased().hasPrefix(term.lowercased())
        })
        
        loadUsers()
        updateUI()
    }
    
    func loadUsers(){
        for user in results {
            DatabaseManager.shared.userLoadTableView(user: user, completion: { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    guard let strongSelf = self else { break }
                    strongSelf.results.removeAll(where: { $0 == user })
                    print("error loading \(user.userId) with Error: \(error)")
                }
            })
        }
        
    }
    
    func updateUI() {
        if results.isEmpty {
            noResultsLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noResultsLabel.isHidden = true
            tableView.isHidden = false
        }
        tableView.reloadData()
    }
}


extension NewChatViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Start Conversation
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }

    
}

extension NewChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell
        cell.configure(user)
        user.tableViewCell = cell
        return cell
    }
    
    
}
