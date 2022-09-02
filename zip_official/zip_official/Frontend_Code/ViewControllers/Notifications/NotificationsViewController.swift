//
//  NotificationsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/21.
//

import UIKit

class NotificationsViewController: UIViewController {
    var tableView = UITableView()
    
    var notificationsToday: [ZipNotification] = []
    var notificationsEarlier: [ZipNotification] = []

    private let tableHeader: UIView
    private let zipRequestButton: UIButton
    private let eventInvitesButton: UIButton

        
    @objc private func didTapZipRequestsButton(){
        let vc = InvitedTableViewController(cellItems: User.getMyRequests())
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapEventInvites() {
        
    }
    
    
    init() {
        zipRequestButton = UIButton()
        eventInvitesButton = UIButton()
        tableHeader = UIView()
        super.init(nibName: nil, bundle: nil)

        zipRequestButton.setTitle("Zip Requests (\(User.getMyRequests().count))", for: .normal)
//        super.init(nibName: nil, bundle: nil)
//        if let friendsips = AppDelegate.userDefaults.value(forKey: "friendships") as? [String: Int] {
//            let zipsDict = friendsips.filter({ $0.value == FriendshipStatus.REQUESTED_INCOMING.rawValue })
//            let userIds = Array(zipsDict.keys)
//            zipRequestButton.setTitle("Zip Requests (\(userIds.count))", for: .normal)
//        } else {
//            zipRequestButton.setTitle("Zip Requests (0)", for: .normal)
//        }
        
        zipRequestButton.addTarget(self, action: #selector(didTapZipRequestsButton), for: .touchUpInside)
        zipRequestButton.backgroundColor = .clear
        zipRequestButton.titleLabel?.textColor = .white
        zipRequestButton.titleLabel?.font = .zipSubtitle2
        zipRequestButton.contentHorizontalAlignment = .left
        zipRequestButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
        eventInvitesButton.setTitle("Event Invites (not implemented)", for: .normal)
        eventInvitesButton.addTarget(self, action: #selector(didTapEventInvites), for: .touchUpInside)
        eventInvitesButton.backgroundColor = .clear
        eventInvitesButton.titleLabel?.textColor = .white
        eventInvitesButton.titleLabel?.font = .zipSubtitle2
        eventInvitesButton.contentHorizontalAlignment = .left
        eventInvitesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        
  
        configureNavBar()
        configureTable()
        configureTableHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        
        generateData()
        
        
    }
    
    //MARK: - Nav Bar Config
    private func configureNavBar(){
        navigationItem.title = "Notifications"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }

    
    private func configureTable(){
//        tableView.register(NewsNotificationTableViewCell.self, forCellReuseIdentifier: NewsNotificationTableViewCell.identifier)
//        tableView.register(EventPublicTableViewCell.self, forCellReuseIdentifier: EventPublicTableViewCell.identifier)
//        tableView.register(EventInviteTableViewCell.self, forCellReuseIdentifier: EventInviteTableViewCell.identifier)
//        tableView.register(EventUpdateTableViewCell.self, forCellReuseIdentifier: EventUpdateTableViewCell.identifier)
//        tableView.register(ZipAcceptedTableViewCell.self, forCellReuseIdentifier: ZipAcceptedTableViewCell.identifier)
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()
    }
    
    private func configureTableHeader() {
        tableHeader.backgroundColor = .zipGray
        let disclosureIndicator = UIImageView()
        let disclosureIndicator2 = UIImageView()
        let sep = UIView()
        
        sep.backgroundColor = .zipVeryLightGray
        disclosureIndicator.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        disclosureIndicator2.image = UIImage(systemName: "chevron.right")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        tableHeader.addSubview(disclosureIndicator)
        tableHeader.addSubview(zipRequestButton)
        tableHeader.addSubview(disclosureIndicator2)
        tableHeader.addSubview(eventInvitesButton)
        tableHeader.addSubview(sep)

        disclosureIndicator.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicator.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -15).isActive = true
        disclosureIndicator.centerYAnchor.constraint(equalTo: zipRequestButton.centerYAnchor).isActive = true
        
        disclosureIndicator2.translatesAutoresizingMaskIntoConstraints = false
        disclosureIndicator2.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -15).isActive = true
        disclosureIndicator2.centerYAnchor.constraint(equalTo: eventInvitesButton.centerYAnchor).isActive = true

        zipRequestButton.translatesAutoresizingMaskIntoConstraints = false
        zipRequestButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor).isActive = true
        zipRequestButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor).isActive = true
        zipRequestButton.topAnchor.constraint(equalTo: tableHeader.topAnchor).isActive = true
        
        sep.translatesAutoresizingMaskIntoConstraints = false
        sep.topAnchor.constraint(equalTo: zipRequestButton.bottomAnchor).isActive = true
        sep.leftAnchor.constraint(equalTo: tableHeader.leftAnchor).isActive = true
        sep.leftAnchor.constraint(equalTo: tableHeader.rightAnchor).isActive = true
        sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        eventInvitesButton.translatesAutoresizingMaskIntoConstraints = false
        eventInvitesButton.topAnchor.constraint(equalTo: sep.bottomAnchor).isActive = true
        eventInvitesButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor).isActive = true
        eventInvitesButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor).isActive = true
        eventInvitesButton.bottomAnchor.constraint(equalTo: tableHeader.bottomAnchor).isActive = true
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
        tableHeader.bottomAnchor.constraint(equalTo: eventInvitesButton.bottomAnchor).isActive = true
        tableHeader.topAnchor.constraint(equalTo: zipRequestButton.topAnchor).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        tableView.tableHeaderView = tableHeader

    }
}



extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}


extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
        view.backgroundColor = .zipSeparator
        return view
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 30))
        view.backgroundColor = .zipGray
        
        let label = UILabel()
        label.font = .zipSubtitle2
        label.textColor = .zipVeryLightGray
        
        switch section {
        case 0: label.text = "Today"
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
            return notificationsToday.count
        default:
            return notificationsEarlier.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var tableData: [ZipNotification] = []
        switch indexPath.section {
        case 0: tableData = notificationsToday
        default: tableData = notificationsEarlier
        }
        
//        switch tableData[indexPath.row].subtype {
//        case .news_update:
//            let cell = tableView.dequeueReusableCell(withIdentifier: NewsNotificationTableViewCell.identifier) as! NewsNotificationTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//
//        case .accepted_zip_request:
//            let cell = tableView.dequeueReusableCell(withIdentifier: ZipAcceptedTableViewCell.identifier) as! ZipAcceptedTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .event_invite:
//
//        case .public_event:
//
//        case .one_day_reminder:
//
//        case .change_to_event_info:
//
//        case .event_live:
//
//        case .zip_request, .message, .message_request:
//            break
//        }
//        case .news:
//            let cell = tableView.dequeueReusableCell(withIdentifier: NewsNotificationTableViewCell.identifier) as! NewsNotificationTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .eventPublic:
//            let cell = tableView.dequeueReusableCell(withIdentifier: EventPublicTableViewCell.identifier) as! EventPublicTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .eventInvite:
//            let cell = tableView.dequeueReusableCell(withIdentifier: EventInviteTableViewCell.identifier) as! EventInviteTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .eventTimeChange, .eventAddressChange, .eventLimitedSpots:
//            let cell = tableView.dequeueReusableCell(withIdentifier: EventUpdateTableViewCell.identifier) as! EventUpdateTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .zipAccepted:
//            let cell = tableView.dequeueReusableCell(withIdentifier: ZipAcceptedTableViewCell.identifier) as! ZipAcceptedTableViewCell
//            cell.configure(with: tableData[indexPath.row])
//            return cell
//        case .zipRequest:
//            // shouldn't happen because this goes somewhere else
//            return UITableViewCell()
//        }

        return UITableViewCell()
    }
}



extension NotificationsViewController {
    func generateData() {
//        let newsUpdate = ZipNotification(type: .news, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: false)
//        let publicEvent = ZipNotification(type: .eventPublic, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: true)
//        let privateEvent = ZipNotification(type: .eventInvite, image: UIImage(named: "yianni1")!, time: TimeInterval(96400), hasRead: true)
//        let eventTimeChange = ZipNotification(type: .eventTimeChange, image: UIImage(named: "launchevent")!, time: TimeInterval(10), hasRead: false)
//        let eventAddressChange = ZipNotification(type: .eventAddressChange, image: UIImage(named: "launchevent")!, time: TimeInterval(200), hasRead: false)
//        let eventLimitedSpots = ZipNotification(type: .eventLimitedSpots, image: UIImage(named: "launchevent")!, time: TimeInterval(2000), hasRead: false)
//        let zipAccepted = ZipNotification(type: .zipAccepted, image: UIImage(named: "yianni1")!, time: TimeInterval(2000), hasRead: true)
//
//        notificationsNew.append(newsUpdate)
//        notificationsNew.append(eventTimeChange)
//        notificationsNew.append(eventLimitedSpots)
//        notificationsNew.append(eventAddressChange)
//
//        notificationsToday.append(publicEvent)
//        notificationsToday.append(zipAccepted)
//
//        notificationsEarlier.append(privateEvent)
//
//
//        notificationsNew.sort(by: { $0.time < $1.time})
//        notificationsToday.sort(by: { $0.time < $1.time})
//        notificationsEarlier.sort(by: { $0.time < $1.time})


    }
    
    
    
}
