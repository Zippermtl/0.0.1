//
//  ZipListViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation

class ZipListViewController: UIViewController {
    var tableView = UITableView()
    
    var event = Event()
    
    var goingZips: [User] = []
    var goingNonZips: [User] = []
    var interestedZips: [User] = []
    var interestedNonZips: [User] = []
    
    
    var goingTableData: [[User]] = [[],[]]
    var interestedTableData: [[User]] = [[],[]]
    var tableData: [[User]] = [[],[]]

    

    
    
    // MARK: - Buttons
    var goingButton = UIButton()
    var interestedButton = UIButton()
    
    
    // MARK: - Button Actions
    @objc private func didTapBackButton(){
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func didTapgoingButton(){
        goingButton.backgroundColor = .zipVeryLightGray
        interestedButton.backgroundColor = .zipLightGray
        tableData = goingTableData
        tableView.reloadData()
    }
    
    @objc private func didTapinterestedButton(){
        interestedButton.backgroundColor = .zipVeryLightGray
        goingButton.backgroundColor = .zipLightGray
        tableData = interestedTableData
        tableView.reloadData()
    }

    
    @objc private func pop(){
        print("POP")
        navigationController!.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)

        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    //MARK: - config
    public func configure(event: Event){
        self.event = event
        
        configureNavBar()
        configureTableData()
        configureTable()
        configureButtons()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: #selector(pop))
        navigationItem.backBarButtonItem?.action = #selector(pop)
        navigationItem.leftBarButtonItem?.action = #selector(pop)

        navigationItem.title = "ZIP LIST"
        

    }
    
    
    //MARK: - Table Data
    private func configureTableData() {
        goingTableData[0] = event.usersGoing.filter { $0.zipped }
        goingTableData[1] = event.usersGoing.filter { !$0.zipped }
        interestedTableData[0] = event.usersInterested.filter { $0.zipped }
        interestedTableData[1] = event.usersInterested.filter { !$0.zipped }
        tableData = goingTableData
    }
    
    //MARK: - Table Config
    private func configureTable(){
        //upcoming events table
        tableView.register(ZipListTableViewCell.self, forCellReuseIdentifier: ZipListTableViewCell.zippedIdentifier)
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
    
    //MARK: - Button Config
    private func configureButtons(){
        let width = view.frame.size.width
        goingButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        goingButton.backgroundColor = .zipVeryLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        goingButton.setTitle("GOING", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipBodyBold
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        goingButton.layer.cornerRadius = 10
        
        interestedButton = UIButton(frame: CGRect(x: 0, y: 0, width: width/2-20, height: 40))
        interestedButton.backgroundColor = .zipLightGray//UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        interestedButton.setTitle("INTERESTED", for: .normal)
        interestedButton.titleLabel?.textColor = .white
        interestedButton.titleLabel?.font = .zipBodyBold
        interestedButton.titleLabel?.textAlignment = .center
        interestedButton.contentVerticalAlignment = .center
        interestedButton.layer.cornerRadius = 10
        
        
        addButtonTargets()
    }
    
    private func addButtonTargets(){
        // topViewContainer
        goingButton.addTarget(self, action: #selector(didTapgoingButton), for: .touchUpInside)
        interestedButton.addTarget(self, action: #selector(didTapinterestedButton), for: .touchUpInside)
    }
    
    private func addSubviews(){
        view.addSubview(goingButton)
        view.addSubview(interestedButton)
        view.addSubview(tableView)
    }
    
    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
        // Public Table
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: goingButton.bottomAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Public Button
        goingButton.translatesAutoresizingMaskIntoConstraints = false
        goingButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        goingButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true

        // Private Button
        interestedButton.translatesAutoresizingMaskIntoConstraints = false
        interestedButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        interestedButton.leftAnchor.constraint(equalTo: goingButton.rightAnchor, constant: 10).isActive = true
        interestedButton.widthAnchor.constraint(equalTo: goingButton.widthAnchor).isActive = true
        interestedButton.bottomAnchor.constraint(equalTo: goingButton.bottomAnchor).isActive = true
    }

}


extension ZipListViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

//MARK: TableDataSource
extension ZipListViewController :  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfileView = OtherProfileViewController(id: tableData[indexPath.section][indexPath.row].userId)
        userProfileView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(userProfileView, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
        view.backgroundColor = .zipVeryLightGray
        
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold
        
        switch section{
        case 0: label.text = "My Zips"
        case 1: label.text = "Other"
        default: break
        }
        
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = tableData[indexPath.section][indexPath.row]

        var cell: ZipListTableViewCell
        if user.zipped {
            cell = tableView.dequeueReusableCell(withIdentifier: ZipListTableViewCell.zippedIdentifier, for: indexPath) as! ZipListTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: ZipListTableViewCell.notZippedIdentifier, for: indexPath) as! ZipListTableViewCell
        }
        
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.setNeedsLayout()
        cell.layoutIfNeeded()

        cell.configure(user)
        return cell
    }
}


