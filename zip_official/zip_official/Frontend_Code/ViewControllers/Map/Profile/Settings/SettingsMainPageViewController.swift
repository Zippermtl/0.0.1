//
//  SettingsPageViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/14/21.
//

import UIKit
import FirebaseAuth

class SettingsPageViewController: UIViewController {
    var settingsCatagories: [String] = ["Account", "Notifications", "Privacy","Help"]
    
    // MARK: - SubViews
    var tableView = UITableView()
    var logoutButton = UIButton()

    
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }

    @objc private func didTapSyncContactsButton(){
        print("Sync Contacts tapped")
    }
    
    @objc private func didTapLogoutButton(){
        print("logout tapped")
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }
            catch {
                print("Failed to Logout User")
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray

        configureNavBar()
        configureTable()
        configureButtons()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - NavBar config
    private func configureNavBar(){
        navigationItem.title = "SETTINGS"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    
    //MARK: - Table Config
    private func configureTable(){
        tableView.register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .zipGray
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 2))
        tableView.tableHeaderView?.backgroundColor = .zipSeparator
        tableView.tableFooterView = nil
        tableView.bounces = false
        tableView.sectionIndexBackgroundColor = .zipLightGray

    }
    
    //MARK: - Button Configt
    private func configureButtons() {
//        syncContactsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 25))
//        syncContactsButton.backgroundColor = UIColor(red: 137/255, green: 197/255, blue: 156/255, alpha: 1)
//        syncContactsButton.setTitle("SYNC CONTACTS", for: .normal)
//        syncContactsButton.titleLabel?.textColor = .white
//        syncContactsButton.titleLabel?.font = .zipBodyBold
//        syncContactsButton.titleLabel?.textAlignment = .center
//        syncContactsButton.contentVerticalAlignment = .center
//        syncContactsButton.layer.cornerRadius = syncContactsButton.titleLabel!.intrinsicContentSize.height/2
        
        logoutButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        logoutButton.backgroundColor = UIColor(red: 254/255, green: 97/255, blue: 127/255, alpha: 1)
        logoutButton.setTitle("LOG OUT", for: .normal)
        logoutButton.titleLabel?.textColor = .white
        logoutButton.titleLabel?.font = .zipBodyBold.withSize(15)
        logoutButton.titleLabel?.textAlignment = .center
        logoutButton.contentVerticalAlignment = .center
        logoutButton.layer.cornerRadius = logoutButton.titleLabel!.intrinsicContentSize.height/2
        
        logoutButton.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
    }


    // MARK: - Add Subviews
    private func addSubviews(){
        // Header

        
        // Table Views
        view.addSubview(tableView)
        view.addSubview(logoutButton)
    }
    
    private func configureSubviewLayout() {
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: logoutButton.topAnchor, constant: 10).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

       
        
//        syncContactsButton.translatesAutoresizingMaskIntoConstraints = false
//        syncContactsButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
//        syncContactsButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
//        syncContactsButton.widthAnchor.constraint(equalToConstant: syncContactsButton.titleLabel!.intrinsicContentSize.width + 20).isActive = true
//        syncContactsButton.heightAnchor.constraint(equalToConstant: syncContactsButton.titleLabel!.intrinsicContentSize.height).isActive = true

        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        logoutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoutButton.widthAnchor.constraint(equalToConstant: logoutButton.titleLabel!.intrinsicContentSize.width + 20).isActive = true
        logoutButton.heightAnchor.constraint(equalToConstant: logoutButton.titleLabel!.intrinsicContentSize.height).isActive = true
    }
}


extension SettingsPageViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsCategoryView = SettingsCategoryViewController()
        settingsCategoryView.configure(indexPath.row)
        settingsCategoryView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        
        view.window!.layer.add(transition, forKey: nil)
        
        navigationController?.pushViewController(settingsCategoryView, animated: true)
    }
}

//MARK: TableDataSource

extension SettingsPageViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsCatagories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell
        guard let catagory = SettingsCategory(rawValue: indexPath.row) else { return UITableViewCell() }
        
        cell.clipsToBounds = true
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        let outlineView = UIView()
        let width = cell.frame.width
        let height = cell.frame.height
        outlineView.frame = CGRect(x: 10, y: 10, width: width-20, height: height-20)
        outlineView.layer.cornerRadius = 15
        outlineView.backgroundColor = .zipLightGray
        cell.addSubview(outlineView)

        let catagoryLabel = UILabel()
        catagoryLabel.text = catagory.description.uppercased()
        catagoryLabel.textColor = .white
        catagoryLabel.font = .zipBodyBold
        outlineView.addSubview(catagoryLabel)
        
        catagoryLabel.translatesAutoresizingMaskIntoConstraints = false
        catagoryLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        catagoryLabel.centerXAnchor.constraint(equalTo: outlineView.centerXAnchor).isActive = true

        return cell
    }
}
