//
//  InviteUserToEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit

protocol SelectedEventProtocol: AnyObject {
    func addEvent(event: Event)
    func removeEvent(event: Event)
}

class InviteUserToEventViewController: UIViewController {
    var events: [Event]
    var eventsToInvite: [Event]
    
    private let tableView: UITableView
    
    var user: User
   
    
    init(user: User) {
        self.user = user
        let hostedIds = AppDelegate.userDefaults.value(forKey: "hostedEvents") as? [String] ?? []
        self.events = hostedIds.map({ Event(eventId: $0) })
        eventsToInvite = []
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
        title = "Events"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite",
                                                            style: UIBarButtonItem.Style.done,
                                                            target: self,
                                                            action: #selector(didTapInvite))
        
        view.backgroundColor = .zipGray
        configureTable()
        loadEvents()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadEvents() {
        var doneCount = 0
        let totalEventCount = events.count
        for event in events {
            DatabaseManager.shared.eventLoadTableView(event: event, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let event):
                    doneCount+=1
                    if event.usersInvite.contains(strongSelf.user) || event.endTime <= Date() {
                        strongSelf.events.removeAll(where: { $0 == event })
                    }
                    
                    if doneCount == totalEventCount {
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                    }
                case .failure(let error):
                    doneCount+=1
                    guard let strongSelf = self else { break }
                    strongSelf.events.removeAll(where: { $0 == event })
                    if doneCount == totalEventCount {
                        DispatchQueue.main.async {
                            strongSelf.tableView.reloadData()
                        }
                    }
                    
                    print("error loading event with id: \(event.eventId) with Error: \(error)")
                }
                
            })
        }
    }
    
    
    private func configureTable(){
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.register(EventSelectTableViewCell.self, forCellReuseIdentifier: EventSelectTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = nil
        tableView.tableFooterView = nil
        tableView.sectionIndexBackgroundColor = .zipLightGray
        tableView.separatorColor = .zipSeparator
    }
    
    @objc private func didTapInvite(){
        var idx = 0
        for event in eventsToInvite {
            DatabaseManager.shared.inviteUsers(event: event, users: [user], completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    idx+=1
                    return
                }
                idx+=1
                if idx == strongSelf.eventsToInvite.count {
                    DispatchQueue.main.async {
                        strongSelf.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension InviteUserToEventViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventSelectTableViewCell.identifier, for: indexPath) as! EventSelectTableViewCell
        let cellEvent = events[indexPath.row]
        cell.configure(cellEvent)
        cellEvent.tableViewCell = cell
        cell.delegate = self
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        return cell
    }
    
    
}


extension InviteUserToEventViewController: SelectedEventProtocol {
    func addEvent(event: Event) {
        eventsToInvite.append(event)
    }
    
    func removeEvent(event: Event) {
        guard let idx = eventsToInvite.firstIndex(where: { $0.eventId == event.eventId }) else {
            return
        }
        eventsToInvite.remove(at: idx)
    }
    
    private class EventSelectTableViewCell: AbstractEventTableViewCell {
        static let identifier = "invite"
        
        private let selectButton: UIButton
        weak var delegate: SelectedEventProtocol?

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            selectButton = UIButton()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            let lightConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .large)
            let boldConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
            let plus = UIImage(systemName: "circle", withConfiguration: lightConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            let check = UIImage(systemName: "checkmark.circle.fill",withConfiguration: boldConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
            selectButton.setImage(plus, for: .normal)
            selectButton.setImage(check, for: .selected)
            
            selectButton.addTarget(self, action: #selector(didTapSelect), for: .touchUpInside)
            
            configureSubviewLayout()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func configureSubviewLayout() {
            contentView.addSubview(selectButton)
            
            selectButton.translatesAutoresizingMaskIntoConstraints = false
            selectButton.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
            selectButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
        }
        
        
        @objc private func didTapSelect(){
            selectButton.isSelected = !selectButton.isSelected

            if selectButton.isSelected {
                delegate?.addEvent(event: event!)
            } else {
                delegate?.removeEvent(event: event!)

            }
        }
    
    }
}
