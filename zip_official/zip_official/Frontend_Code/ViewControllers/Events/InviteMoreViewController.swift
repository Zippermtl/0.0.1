//
//  InviteUserToEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit


class InviteMoreViewController: UIViewController {
    var users: [User]
    var usersToInvite: [User]
    var event: Event
    
    private let tableView: UITableView
    
    init(event: Event) {
        self.event = event
        usersToInvite = []
        self.tableView = UITableView()
        users = []

        super.init(nibName: nil, bundle: nil)
        
        title = "Invite Guests"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapInvite))
        
        guard let friendsips = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int] else {
            return
        }
        let zipsDict = friendsips.filter({ $0.value == 2 })
        let userIds = Array(zipsDict.keys)
        let zips = userIds.map({ User(userId: $0) })
        users = zips.filter({ !event.usersInvite.contains($0)})
        
        view.backgroundColor = .zipGray
        configureTable()
        DatabaseManager.shared.userLoadTableView(users: users, completion: { result in })
    }
    
    private func configureTable(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        
        tableView.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
    }
    
    @objc private func didTapInvite(){
        navigationController?.popViewController(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension InviteMoreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InviteTableViewCell.identifier, for: indexPath) as! InviteTableViewCell
        cell.configure(users[indexPath.row])
        users[indexPath.row].tableViewCell = cell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        
        return cell
    }
    
    
}


extension InviteMoreViewController: InviteTableViewCellDelegate {
    func inviteUser(user: User) {
        usersToInvite.append(user)
    }
    
    func uninviteUser(user: User) {
        guard let idx = usersToInvite.firstIndex(where: { $0.userId == user.userId }) else {
            return
        }
        usersToInvite.remove(at: idx)
    }
}
