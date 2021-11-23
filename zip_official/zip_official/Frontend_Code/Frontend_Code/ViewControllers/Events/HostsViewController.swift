//
//  HostsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/21/21.
//

import UIKit

class HostsViewController: UIViewController {
    let tableView = UITableView()
    var hosts: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    public func configure(_ users: [User]){
        hosts = users
        for idx in 0...hosts.count-1 {
            hosts[idx].zipped = false
        }
        
        configureNavBar()
        configureTable()
        configureSubviews()
    }
    
    private func configureNavBar(){
        navigationItem.title = "HOSTS"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func configureTable(){
        //upcoming events table
        tableView.register(ZipListTableViewCell.self, forCellReuseIdentifier: ZipListTableViewCell.notZippedIdentifier)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
    }
    
    private func configureSubviews(){
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true

    }

}


extension HostsViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//MARK: TableDataSource
extension HostsViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfileView = OtherProfileViewController()
        userProfileView.configure(hosts[indexPath.row])
        userProfileView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(userProfileView, animated: true)
    }
     
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = hosts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ZipListTableViewCell.notZippedIdentifier, for: indexPath) as! ZipListTableViewCell
        
        
        cell.selectionStyle = .none
        cell.clipsToBounds = true


        cell.configure(user)
        return cell
    }
}

