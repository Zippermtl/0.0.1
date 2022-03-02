//
//  MyZipsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation

class MyZipsViewController: UIViewController {
    var userLoc = CLLocation()

    var tableView = UITableView()
    var myZips: [User] = MapViewController.getTestUsers()
    
    //MARK: - Subviews
    
    // MARK: - Labels

    
        
    //MARK: - Button Config
//    let sortSwtich: UISwitch = {
//        let sortSwitch = UISwitch(frame: .zero)
//        sortSwitch.isOn = false
//        sortSwitch.addTarget(self, action: #selector(sortList), for: .valueChanged)
//        return sortSwitch
//    }()
    
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
    @objc private func sortList(_ sender: UISwitch){
        if !sender.isOn {
//            myZips.sort(by: { $0.name < $1.name})
            myZips.sort(by: { $0.firstName < $1.firstName})

            tableView.reloadData()
        } else {
            myZips.sort(by: { $0.distance < $1.distance})
            tableView.reloadData()
        }
    }
    
    @objc private func didTapInviteFriendsButton(){
        print("Invite Friends tapped")
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        let loc = AppDelegate.userDefaults.value(forKey: "userLoc") as! [Double]
        userLoc = CLLocation(latitude: loc[0], longitude: loc[1])
        
        configureNavBar()
        configureTableData()
        configureSwitch()
        configureTable()
        configureSubviewLayout()
    }
    
    private func configureNavBar() {
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.title = "MY ZIPS"
        
        let sortSwitch = UISwitch(frame: .zero)
        sortSwitch.isOn = false
        sortSwitch.addTarget(self, action: #selector(sortList(_:)), for: .valueChanged)
        let barBtn = UIBarButtonItem(customView: sortSwitch)
        
        navigationItem.rightBarButtonItem = barBtn
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
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        view.addSubview(inviteFriendsButton)
        view.addSubview(tableView)
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: inviteFriendsButton.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        //Invite Friends
        inviteFriendsButton.translatesAutoresizingMaskIntoConstraints = false
        inviteFriendsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inviteFriendsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        inviteFriendsButton.widthAnchor.constraint(equalToConstant: inviteFriendsButton.titleLabel!.intrinsicContentSize.width + 20).isActive = true
        inviteFriendsButton.heightAnchor.constraint(equalToConstant: inviteFriendsButton.titleLabel!.intrinsicContentSize.height).isActive = true
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
        
        let userProfileView = OtherProfileViewController(user: myZips[indexPath.row], needsLoadUser: true)
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

        let user = myZips[indexPath.row]

        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(user)
        return cell
    }
}





