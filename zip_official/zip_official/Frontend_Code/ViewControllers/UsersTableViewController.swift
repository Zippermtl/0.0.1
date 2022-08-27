//
//  MyZipsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation

class UserCellSectionData {
    var title: String
    var users: [User]
    
    init(title: String, users: [User]) {
        self.title = title
        self.users = users
    }
}


class UsersTableViewController: UIViewController {
    var tableView: UITableView
    var sections: [UserCellSectionData]
    var tableData: [UserCellSectionData]
    var searchBar: UISearchBar
    
    var noCellsLabel: String?
    
 
    
    init(users: [User]) {
        tableView = UITableView()
        sections = [UserCellSectionData(title: "", users: users)]
        tableData = sections
        searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        configureTable()
        configureSubviewLayout()
        if !users.isEmpty {
            fetchUsers()
        }
    }
    
    init(sectionData: [UserCellSectionData]) {
        sections = []
        for section in sectionData {
            sections.append(section)
        }

        tableView = UITableView()
        tableData = sectionData
        searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        configureTable()
        configureSubviewLayout()
        fetchUsers()
        
        
    }
    
//    init
    
    public func reload(users: [User]) {
        sections = [UserCellSectionData(title: "", users: users)]
        tableData = sections
        tableView.reloadData()
        fetchUsers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }

    
    private func fetchUsers() {
        for section in sections {
            for user in section.users {
                DatabaseManager.shared.userLoadTableView(user: user, completion: { [weak self] result in
                    switch result {
                    case .success(_):
                        break
                    case .failure(let error):
                        guard let strongSelf = self else { break }
                        for section in strongSelf.sections {
                            section.users.removeAll(where: { $0 == user })
                        }
                        strongSelf.tableData = strongSelf.sections
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                        print("error loading \(user.userId) with Error: \(error)")
                    }
                })
            }
        }
    }
    
    
    //MARK: - Table Config
    private func configureTable(){
        //upcoming events table
        tableView.register(MyZipsTableViewCell.self, forCellReuseIdentifier: MyZipsTableViewCell.identifier)
        tableView.register(sectionHeader.self, forHeaderFooterViewReuseIdentifier: sectionHeader.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        tableView.backgroundColor = .clear
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
//        myZips.sort(by: { $0.name < $1.name})
        for section in sections {
            section.users.sort(by: { $0.firstName < $1.firstName})
        }

        configureSearchbar()
    }
    
    private func configureSearchbar(){
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.barStyle = .black
        searchBar.backgroundColor = .zipGray
        searchBar.barTintColor = .zipGray

        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
    }
    

    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        view.addSubview(tableView)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

    
}


//MARK: - TableDelegate
extension UsersTableViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

//MARK: TableDataSource
extension UsersTableViewController :  UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].users.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if sections.count == 1 { return UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1)) }
        let sectionData = tableData[section]
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeader.identifier) as! sectionHeader
        sectionHeader.section = section
        sectionHeader.configure(section: sectionData)
        sectionHeader.backgroundColor = .zipVeryLightGray
        return sectionHeader
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc : UIViewController
        let cellId = tableData[indexPath.section].users[indexPath.row].userId
        if cellId == AppDelegate.userDefaults.value(forKey: "userId") as! String {
            vc = ProfileViewController(id: cellId)
        } else {
            vc = OtherProfileViewController(id: cellId)
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell
        let section = tableData[indexPath.section]
        let user = section.users[indexPath.row]
        user.tableViewCell = cell

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(user)
        return cell
    }
}


extension UsersTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        if textSearched == "" {
            tableData = sections
            print(tableData[0].users)
            print("sections = ", sections)
            print("tableData = ", tableData)
            tableView.reloadData()
        } else {
            tableData = []
            for section in sections {
                let usersInSection = section.users.filter({ $0.fullName.contains(textSearched) || $0.username.contains(textSearched)})
                if !usersInSection.isEmpty {
                    tableData.append(UserCellSectionData(title: section.title, users: usersInSection))
                }
            }
            
            print("sections = ", sections)
            print("tableData = ", tableData)

            tableView.reloadData()
        }
    }
}


extension UsersTableViewController {
    fileprivate class sectionHeader: UITableViewHeaderFooterView {
        static let identifier = "sectionHeader"
        weak var delegate: NotificationSectionHeaderDelegate?
        var section: Int?
        var sectionLabel: UILabel
        
        override init(reuseIdentifier: String?) {
            sectionLabel = UILabel.zipTextFill()
            super.init(reuseIdentifier: reuseIdentifier)
            let bg = UIView()
            addSubview(bg)
            bg.addSubview(sectionLabel)

            bg.backgroundColor = .zipLightGray
            bg.translatesAutoresizingMaskIntoConstraints = false
            bg.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            bg.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            bg.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            bg.heightAnchor.constraint(equalTo: sectionLabel.heightAnchor,constant: 8).isActive = true
            
            sectionLabel.translatesAutoresizingMaskIntoConstraints = false
            sectionLabel.centerYAnchor.constraint(equalTo: bg.centerYAnchor).isActive = true
            sectionLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 10).isActive = true
        }
        
        public func configure(section: UserCellSectionData){
            sectionLabel.text = section.title
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}




