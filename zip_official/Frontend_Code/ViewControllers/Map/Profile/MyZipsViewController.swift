//
//  MyZipsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation
import TTSwitch

class MyZipsViewController: UIViewController {
    let userLoc = CLLocation(latitude: MapViewController.userLoc.latitude, longitude: MapViewController.userLoc.longitude)

    var headerView = UIView()
    var tableView = UITableView()
    var myZips: [User] = MapViewController.getTestUsers()
    //MARK: - Subviews
    let sortSwitch = TTSwitch()
    
    // MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "MY ZIPS"
        return label
        
    }()
        
    //MARK: - Button Config
    var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backarrow"), for: .normal)
        btn.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return btn
    }()
    
    var sortButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(sortList), for: .touchUpInside)
        btn.tag = 0
        return btn
    }()
    
    var inviteFriendsButton: UIButton = {
        let btn =  UIButton(frame: CGRect(x: 0, y: 0, width: 300, height: 25))
        btn.backgroundColor = UIColor(red: 137/255, green: 197/255, blue: 156/255, alpha: 1)
        btn.setTitle("INVITE FRIENDS", for: .normal)
        btn.titleLabel?.textColor = .white
        btn.titleLabel?.font = .zipBodyBold
        btn.titleLabel?.textAlignment = .center
        btn.contentVerticalAlignment = .center
        btn.layer.cornerRadius = btn.titleLabel!.intrinsicContentSize.height/2
        btn.addTarget(self, action: #selector(didTapInviteFriendsButton), for: .touchUpInside)

        return btn
    }()


    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func sortList(){
        if sortButton.tag == 0 {
            myZips.sort(by: { $0.name < $1.name})
            tableView.reloadData()
            sortButton.tag = 1
        } else {
            myZips.sort(by: { $0.distance < $1.distance})
            tableView.reloadData()
            sortButton.tag = 0
        }
    }

    
    @objc private func didTapInviteFriendsButton(){
        print("Invite Friends tapped")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray

        
        configureHeader()
        configureTableData()
        configureTable()
        configureSwitch()
        addSubviews()
        configureSubviewLayout()

    }
    

    private func configureHeader(){
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/6)
        headerView.backgroundColor = .zipGray
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
        
        myZips.sort(by: { $0.name < $1.name})
    }
    
    private func configureTableData(){
        for index in 0..<myZips.count {
            myZips[index].distance = Double(round(10*(userLoc.distance(from: myZips[index].location))/1000))/10
        }
    }
    
    private func configureSwitch(){
//        sortSwitch.trackImage = UIImage(named: "whiteBackground")
//        sortSwitch.thumbImage = UIImage(named: "close")
//
//
//
//
//
//        sortSwitch.clipsToBounds = true
//        sortSwitch.offString = "Abc"
//        sortSwitch.offLabel.textColor = .zipGray
//        sortSwitch.offLabel.font = .zipBody
//        sortSwitch.onString = "Off"
//        sortSwitch.onLabel.textColor = .zipGray
//        sortSwitch.onLabel.font = .zipBody
    }

    private func addSubviews(){
        // Header
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(backButton)
        headerView.addSubview(inviteFriendsButton)
        headerView.addSubview(sortSwitch)
        headerView.addSubview(sortButton)
        // Table Views
        view.addSubview(tableView)
    }
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        //Invite Friends
        inviteFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendsButton.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        inviteFriendsButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
        inviteFriendsButton.widthAnchor.constraint(equalToConstant: inviteFriendsButton.titleLabel!.intrinsicContentSize.width + 20).isActive = true
        inviteFriendsButton.heightAnchor.constraint(equalToConstant: inviteFriendsButton.titleLabel!.intrinsicContentSize.height).isActive = true
        
        //Back button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: pageTitleLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
        
        sortSwitch.translatesAutoresizingMaskIntoConstraints = false
        sortSwitch.topAnchor.constraint(equalTo: pageTitleLabel.topAnchor, constant: 7).isActive = true
        sortSwitch.bottomAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: -7).isActive = true
        sortSwitch.widthAnchor.constraint(equalToConstant: 65).isActive = true
        sortSwitch.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -20).isActive = true
        sortSwitch.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
        
        sortButton.translatesAutoresizingMaskIntoConstraints = false
        sortButton.topAnchor.constraint(equalTo: pageTitleLabel.topAnchor).isActive = true
        sortButton.bottomAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor).isActive = true
        sortButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
        sortButton.heightAnchor.constraint(equalToConstant: 20).isActive = true

        sortButton.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -20).isActive = true
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
        return myZips.count
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let userProfileView = OtherProfileViewController()
        userProfileView.configure(myZips[indexPath.row])
        userProfileView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        self.view.window!.layer.add(transition, forKey: nil)
        present(userProfileView, animated: false, completion: nil)
        
//        self.dismiss(animated: false, completion: nil)
    }
    
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell

        let user = myZips[indexPath.row]

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(user)
        return cell
    }
}





