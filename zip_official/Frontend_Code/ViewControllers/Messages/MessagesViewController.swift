//
//  MessagesViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit


class MessagesViewController: UIViewController {
    static let title = "MessagesVC" 

    var tableView = UITableView()
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
//        searchBar.delegate = self
        configureNavigation()
        configureTable()
        addSubviews()
        configureSubviewLayout()
    }
    
    
    //MARK: - Configure Navigation
    private func configureNavigation(){
        title = "MESSAGES"
        navigationController?.navigationBar.barTintColor = .zipGray
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.zipTitle.withSize(27),
             NSAttributedString.Key.foregroundColor: UIColor.white]
    }


    

    //MARK: - AddSubviews
    private func addSubviews(){
        view.addSubview(tableView)
    }
    
    private func configureSubviewLayout(){
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    
    }
    
    
    //MARK: Table Config
    private func configureTable(){
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
}


extension MessagesViewController: UITableViewDelegate {
    
}

extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.text = "John Smith"
        cell.textLabel?.textColor = .white
        cell.backgroundColor = .zipGray
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        //show chat messages
        let vc = ChatViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
