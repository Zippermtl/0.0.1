//
//  CompleteEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 1/9/22.
//

import UIKit
import JGProgressHUD
class CompleteEventViewController: UIViewController {
    var event: Event
    var invitedUsers: [User]
    var zipList: [User]
    
    let spinner = JGProgressHUD(style: .light)

    
    init(event: Event) {
        self.event = event
        self.invitedUsers = []
        zipList = User.getMyZips()
        
        super.init(nibName: nil, bundle: nil)
        inviteAllButton.addTarget(self, action: #selector(didTapInviteAllButton), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        completeButton.addTarget(self, action: #selector(didTapCompleteButton), for: .touchUpInside)

        configureTable()
        configureTableHeader()
        addSubviews()
        layoutSubviews()
        
        fetchUsers()
    }
    
    
    private func fetchUsers() {
        for user in zipList {
            DatabaseManager.shared.userLoadTableView(user: user, completion: { [weak self] result in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    guard let strongSelf = self else { break }
                    strongSelf.zipList.removeAll(where: { $0 == user })
                    print("error loading \(user.userId) with Error: \(error)")
                }
            })

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    private let tableView = UITableView()
    
    let inviteAllButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Invite All", for: .normal)
        btn.titleLabel?.font = .zipSubtitle2
        btn.backgroundColor = .zipLightGray
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let clearButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Clear", for: .normal)
        btn.titleLabel?.font = .zipSubtitle2
        btn.backgroundColor = .zipLightGray
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let myZipsLabel: UILabel = {
        let label = UILabel()
        label.font = .zipSubtitle2
        label.textColor = .white
        label.text = "My Zips (0)"
        return label
    }()
    
    private let completeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Create Event", for: .normal)
        btn.backgroundColor = .zipBlue
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 15
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = .zipSubtitle2//.withSize(20)
        return btn
    }()
    
    private let pageStatus3: StatusCheckView = {
        let s = StatusCheckView()
        s.select()
        return s
    }()
    
    private let pageStatus1 = StatusCheckView()
    private let pageStatus2 = StatusCheckView()
    
    @objc private func didTapInviteAllButton(){
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? InviteTableViewCell {
                cell.addButton.isSelected = true
            }
        }
        
        invitedUsers = zipList
    }
    
    @objc private func didTapClearButton(){
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? InviteTableViewCell {
                cell.addButton.isSelected = false
            }
        }
    }
    
    @objc private func didTapCompleteButton(){
        completeButton.isEnabled = false
        spinner.show(in: view)
        
        let host = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String,
                        firstName: AppDelegate.userDefaults.value(forKey: "firstName") as! String,
                        lastName: AppDelegate.userDefaults.value(forKey: "lastName") as! String)
        
        event.hosts = [host]
        event.usersInvite = invitedUsers
        event.usersInvite.append(host)
        event.usersGoing = [host]
        event.ownerId = host.userId
        event.ownerName = host.fullName

        DatabaseManager.shared.createEvent(event: event, completion: { [weak self] success in
            guard let strongSelf = self else { return }
            switch success {
            case .success(let url):
                strongSelf.event.imageUrl = URL(string: url)
                DispatchQueue.main.async {
                    strongSelf.event.addToMap()
                    strongSelf.spinner.dismiss(animated: true)
                    strongSelf.completeButton.isEnabled = true
                    strongSelf.navigationController?.popToRootViewController(animated: true)
                }

            case .failure(let error):
                print(error)
                let actionSheet = UIAlertController(title: "Failed to Create Your Event",
                                                    message: "Make sure all the information you entered is correct or try again later.",
                                                    preferredStyle: .actionSheet)
                
                actionSheet.addAction(UIAlertAction(title: "Continue",
                                                    style: .cancel,
                                                    handler: nil))
                
                self?.present(actionSheet, animated: true)
                DispatchQueue.main.async {
                    self?.spinner.dismiss(animated: true)
                    self?.completeButton.isEnabled = true
                }
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myZipsLabel.text = "My Zips (\(zipList.count)):"
        view.backgroundColor = .zipGray
        title = "Invite Guests"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
    }
    
    private func configureTable(){
        tableView.register(InviteTableViewCell.self, forCellReuseIdentifier: InviteTableViewCell.identifier)
//        tableView.register(ZipListTableViewCell.self, forCellReuseIdentifier: ZipListTableViewCell.notZippedIdentifier)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorStyle = .none
    }
    
    private func configureTableHeader() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 75))
        header.addSubview(inviteAllButton)
        header.addSubview(clearButton)
        header.addSubview(myZipsLabel)
        
        inviteAllButton.translatesAutoresizingMaskIntoConstraints = false
        inviteAllButton.topAnchor.constraint(equalTo: header.topAnchor, constant: 5).isActive = true
        inviteAllButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        inviteAllButton.rightAnchor.constraint(equalTo: clearButton.leftAnchor, constant: -10).isActive = true
        inviteAllButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.topAnchor.constraint(equalTo: inviteAllButton.topAnchor).isActive = true
        clearButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -10).isActive = true
        clearButton.widthAnchor.constraint(equalTo: inviteAllButton.widthAnchor).isActive = true
        clearButton.heightAnchor.constraint(equalTo: inviteAllButton.heightAnchor).isActive = true
        
        myZipsLabel.translatesAutoresizingMaskIntoConstraints = false
        myZipsLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -5).isActive = true
        myZipsLabel.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        tableView.tableHeaderView = header
    }
    
    private func addSubviews(){
        view.addSubview(tableView)
        
        view.addSubview(completeButton)
        view.addSubview(pageStatus1)
        view.addSubview(pageStatus2)
        view.addSubview(pageStatus3)
    }
    
    private func layoutSubviews() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -5).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        completeButton.translatesAutoresizingMaskIntoConstraints = false
        completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        completeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        completeButton.widthAnchor.constraint(equalToConstant: (view.frame.width-90)*0.67).isActive = true
        completeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
        pageStatus2.translatesAutoresizingMaskIntoConstraints = false
        pageStatus2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageStatus2.heightAnchor.constraint(equalToConstant: 15).isActive = true
        pageStatus2.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus1.translatesAutoresizingMaskIntoConstraints = false
        pageStatus1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus1.rightAnchor.constraint(equalTo: pageStatus2.leftAnchor, constant: -10).isActive = true
        pageStatus1.heightAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        pageStatus1.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus3.translatesAutoresizingMaskIntoConstraints = false
        pageStatus3.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5).isActive = true
        pageStatus3.leftAnchor.constraint(equalTo: pageStatus2.rightAnchor, constant: 10).isActive = true
        pageStatus3.heightAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        pageStatus3.widthAnchor.constraint(equalTo: pageStatus2.heightAnchor).isActive = true
        
        pageStatus1.layer.cornerRadius = 15/2
        pageStatus2.layer.cornerRadius = 15/2
        pageStatus3.layer.cornerRadius = 15/2
    }
}


extension CompleteEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension CompleteEventViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zipList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InviteTableViewCell.identifier) as! InviteTableViewCell
//        let cell = tableView.dequeueReusableCell(withIdentifier: ZipListTableViewCell.notZippedIdentifier) as! ZipListTableViewCell
        let user = zipList[indexPath.row]
        user.tableViewCell = cell
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        cell.configure(user)
        cell.delegate = self
        return cell
    }
    
    
}


extension CompleteEventViewController : InviteTableViewDelegate {
    func select(cellItem: CellItem) {
        invitedUsers.append(cellItem as! User)
    }
    
    func unselect(cellItem: CellItem) {
        invitedUsers = invitedUsers.filter({ $0.userId != (cellItem as! User).userId })
    }
}
