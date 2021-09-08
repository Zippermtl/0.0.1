//
//  ZipRequestsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/19/21.
//

import UIKit

class ZipRequestsViewController: UIViewController {
    var headerView = UIView()
    var tableView = UITableView()
    var requests: [Notification] = []
    
    
    // MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "ZIP REQUESTS"
        return label
    }()
    
    //MARK: - Button Config
    var backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backarrow"), for: .normal)
        btn.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return btn
    }()
    
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window!.layer.add(transition, forKey: nil)

        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        generateData()
        configureTable()
        addSubviews()
        configureSubviewLayout()
    }
    

    
    //MARK: - Table Config
    private func configureTable(){
        //upcoming events table
        tableView.register(ZipRequestTableViewCell.self, forCellReuseIdentifier: ZipRequestTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        tableView.backgroundColor = .clear
    }
    
   
    private func addSubviews(){
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        view.addSubview(backButton)
        view.addSubview(tableView)
    }
    
    private func configureSubviewLayout(){
        //header
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.bottomAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 10).isActive = true
        
        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        //Back button
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: pageTitleLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
    }
}



extension ZipRequestsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


extension ZipRequestsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ZipRequestTableViewCell.identifier) as! ZipRequestTableViewCell
        cell.configure(with: requests[indexPath.row])
        return cell
    }
}


extension ZipRequestsViewController {
    func generateData(){
        let request1 = Notification(type: .zipRequest, image: UIImage(named: "ezra1")!, time: TimeInterval(10), hasRead: false)
        let request2 = Notification(type: .zipRequest, image: UIImage(named: "yianni1")!, time: TimeInterval(10), hasRead: false)
        let request3 = Notification(type: .zipRequest, image: UIImage(named: "seung1")!, time: TimeInterval(10), hasRead: false)
        let request4 = Notification(type: .zipRequest, image: UIImage(named: "elias1")!, time: TimeInterval(10), hasRead: false)
        let request5 = Notification(type: .zipRequest, image: UIImage(named: "gabe1")!, time: TimeInterval(10), hasRead: false)
        let request6 = Notification(type: .zipRequest, image: UIImage(named: "ezra2")!, time: TimeInterval(10), hasRead: false)
        
        requests.append(request1)
        requests.append(request2)
        requests.append(request3)
        requests.append(request4)
        requests.append(request5)
        requests.append(request6)

    }
}
