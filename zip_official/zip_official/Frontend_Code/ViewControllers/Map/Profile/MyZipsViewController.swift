//
//  MyZipsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation

class MyZipsViewController: UIViewController {
    var tableView: UITableView
    var myZips: [User]
    var tableData: [User]
    var searchBar: UISearchBar
    
    var user: User
    
    init(user: User) {
        self.user = user
        tableView = UITableView()
        myZips = MapViewController.getTestUsers()
        tableData = myZips
        searchBar = UISearchBar()
        super.init(nibName: nil, bundle: nil)
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return
        }
        
        if user.userId == userId {
            navigationItem.title = "My Zips"
        } else {
            navigationItem.title = "\(user.firstName)'s Zips"
        }

        configureTable()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        
    }

    
    private func fetchUsers(){
        user.loadFriendships(completion: { [weak self] error in
            guard error == nil,
                  let strongSelf = self else {
                return
            }
        
            strongSelf.tableData = (strongSelf.user.friendships.filter({ $0.status == .ACCEPTED }).map({ $0.receiver }))
            
        })
    }
    
    //MARK: - Table Config
    private func configureTable(){
        //upcoming events table
        tableView.register(MyZipsTableViewCell.self, forCellReuseIdentifier: MyZipsTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        tableView.backgroundColor = .clear
        
//        myZips.sort(by: { $0.name < $1.name})
        myZips.sort(by: { $0.firstName < $1.firstName})
        
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
extension MyZipsViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
}

//MARK: TableDataSource
extension MyZipsViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userProfileView = OtherProfileViewController(id: myZips[indexPath.row].userId)
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
            
        let cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell

        let user = tableData[indexPath.row]

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(user)
        return cell
    }
}


extension MyZipsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange textSearched: String) {
        if textSearched == "" {
            tableData = myZips
        } else {
            tableData = myZips.filter({ $0.fullName.contains(textSearched) || $0.username.contains(textSearched)})
        }
        tableView.reloadData()

 
    }
}





