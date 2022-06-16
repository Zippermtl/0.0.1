//
//  NotificationsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit

class NotificationsViewController: UIViewController {
    var tableView = UITableView()
    
    var notificationsNew: [ZipNotification] = []
    var notificationsToday: [ZipNotification] = []
    var notificationsEarlier: [ZipNotification] = []

    
    var zipRequestsButton = UIButton()
    
    @objc private func didTapZipRequestsButton(){
        let zipRequests = ZipRequestsViewController(requests: [])
        zipRequests.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        view.window!.layer.add(transition, forKey: nil)
        present(zipRequests, animated: false, completion: nil)
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        generateData()
        
        configureNavBar()
        configureButtons()
        configureTable()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.title = "NOTIFICATIONS"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)

    }

    //MARK: - Button Config
    private func configureButtons(){
        zipRequestsButton.addTarget(self, action: #selector(didTapZipRequestsButton), for: .touchUpInside)
        zipRequestsButton.backgroundColor = .zipLightGray

        zipRequestsButton.setTitle("ZIP REQUESTS", for: .normal)
        zipRequestsButton.titleLabel?.textColor = .white
        zipRequestsButton.titleLabel?.font = .zipBodyBold
        zipRequestsButton.contentHorizontalAlignment = .left
        zipRequestsButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }

    //MARK: - AddSubviews
    private func addSubviews(){
        view.addSubview(zipRequestsButton)
        view.addSubview(tableView)
    }
    
    private func configureSubviewLayout(){
    
        // TableView
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: zipRequestsButton.bottomAnchor,constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // zip requests button
        zipRequestsButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        zipRequestsButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        zipRequestsButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        zipRequestsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    

    
    private func configureTable(){
        tableView.register(NewsNotificationTableViewCell.self, forCellReuseIdentifier: NewsNotificationTableViewCell.identifier)
        tableView.register(EventPublicTableViewCell.self, forCellReuseIdentifier: EventPublicTableViewCell.identifier)
        tableView.register(EventInviteTableViewCell.self, forCellReuseIdentifier: EventInviteTableViewCell.identifier)
        tableView.register(EventUpdateTableViewCell.self, forCellReuseIdentifier: EventUpdateTableViewCell.identifier)
        tableView.register(ZipAcceptedTableViewCell.self, forCellReuseIdentifier: ZipAcceptedTableViewCell.identifier)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zipRequestsButton.layer.cornerRadius = 15
    }
}



extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}


extension NotificationsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        view.backgroundColor = .zipLightGray
        
        let label = UILabel()
        label.font = .zipBodyBold
        label.textColor = .white
        
        switch section {
        case 0: label.text = "New"
        case 1: label.text = "Today"
        default: label.text = "Earlier"
        }
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return notificationsNew.count
        case 1:
            return notificationsToday.count
        default:
            return notificationsEarlier.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableData: [ZipNotification] = []
        switch indexPath.section {
        case 0: tableData = notificationsNew
        case 1: tableData = notificationsToday
        default: tableData = notificationsEarlier
        }
        
        switch tableData[indexPath.row].type {
        case .news:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsNotificationTableViewCell.identifier) as! NewsNotificationTableViewCell
            cell.configure(with: tableData[indexPath.row])
            return cell
        case .eventPublic:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventPublicTableViewCell.identifier) as! EventPublicTableViewCell
            cell.configure(with: tableData[indexPath.row])
            return cell
        case .eventInvite:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventInviteTableViewCell.identifier) as! EventInviteTableViewCell
            cell.configure(with: tableData[indexPath.row])
            return cell
        case .eventTimeChange, .eventAddressChange, .eventLimitedSpots:
            let cell = tableView.dequeueReusableCell(withIdentifier: EventUpdateTableViewCell.identifier) as! EventUpdateTableViewCell
            cell.configure(with: tableData[indexPath.row])
            return cell
        case .zipAccepted:
            let cell = tableView.dequeueReusableCell(withIdentifier: ZipAcceptedTableViewCell.identifier) as! ZipAcceptedTableViewCell
            cell.configure(with: tableData[indexPath.row])
            return cell
        case .zipRequest:
            // shouldn't happen because this goes somewhere else
            return UITableViewCell()
        }
    }
}



extension NotificationsViewController {
    func generateData() {
        let newsUpdate = ZipNotification(type: .news, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: false)
        let publicEvent = ZipNotification(type: .eventPublic, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: true)
        let privateEvent = ZipNotification(type: .eventInvite, image: UIImage(named: "yianni1")!, time: TimeInterval(96400), hasRead: true)
        let eventTimeChange = ZipNotification(type: .eventTimeChange, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: false)
        let eventAddressChange = ZipNotification(type: .eventAddressChange, image: UIImage(named: "launchevent")!, time: TimeInterval(200), hasRead: false)
        let eventLimitedSpots = ZipNotification(type: .eventLimitedSpots, image: UIImage(named: "launchevent")!, time: TimeInterval(2000), hasRead: false)
        let zipAccepted = ZipNotification(type: .zipAccepted, image: UIImage(named: "yianni1")!, time: TimeInterval(2000), hasRead: true)
        
        notificationsNew.append(newsUpdate)
        notificationsNew.append(eventTimeChange)
        notificationsNew.append(eventLimitedSpots)
        notificationsNew.append(eventAddressChange)
        
        notificationsToday.append(publicEvent)
        notificationsToday.append(zipAccepted)

        notificationsEarlier.append(privateEvent)
        
        
        notificationsNew.sort(by: { $0.time < $1.time})
        notificationsToday.sort(by: { $0.time < $1.time})
        notificationsEarlier.sort(by: { $0.time < $1.time})


    }
    
    
    
}
