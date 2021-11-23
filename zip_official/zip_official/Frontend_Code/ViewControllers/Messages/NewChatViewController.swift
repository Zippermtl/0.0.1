//
//  NewChatViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/4/21.
//

import UIKit
import JGProgressHUD

class NewChatViewController: UIViewController {
    public var completion: ((SearchResult) -> Void)?

    private let spinner = JGProgressHUD(style: .light)
    
    private var users = [[String: String]]()
    
    private var results =  [SearchResult]()
    
    private var hasFetched = false

    
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
        table.register(NewConversationTableViewCell.self, forCellReuseIdentifier: NewConversationTableViewCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .zipLightGray
        label.font = .zipBody
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
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        searchUsers(query: text)
    }
    
    func searchUsers(query: String){
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        } else {
            // if not, fetch then filter
            DatabaseManager.shared.getAllusers(completion: { [weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
                
            })
        }
        
        
    }
    
    func filterUsers(with term: String) {
        // update the UI: either show results or show no results
        guard let currentUserId = AppDelegate.userDefaults.value(forKey: "userId") as? String, hasFetched else {
            return
        }
                
        spinner.dismiss()
        
        let results: [SearchResult] = users.filter({
            guard let id = $0["id"],
                  id != currentUserId else {
                      return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let id = $0["id"],
                  let name = $0["name"] else {
                      return nil
                  }
            return SearchResult(name: name, id: id)
        })
                      
        self.results = results
        
        updateUI()
        
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
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationTableViewCell.identifier, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: model)
        return cell
    }
    
    
}


struct SearchResult {
    let name: String
    let id: String
    
}
