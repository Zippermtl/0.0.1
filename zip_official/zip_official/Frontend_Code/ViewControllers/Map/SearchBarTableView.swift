//
//  SearchBarTableView.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/17/22.
//

import Foundation
import UIKit

struct SearchBarResult {
    var event: [Event]?
    var user: [User]?
}

class SearchBarTableView: UITableView {

    
    
//    var searchContent:
    var header: UIView
    var usersButton: UIButton
    var eventsButton: UIButton
    var eventData: [Event]
    
    init(eventData: [Event]) {
        self.header = UIView()
        self.usersButton = UIButton()
        self.eventsButton = UIButton()
        self.eventData = eventData
        
        
        super.init(frame: .zero, style: .plain)
        backgroundColor = .zipGray
        
        
        register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)

        register(UserSearchTableViewCell.self, forCellReuseIdentifier: UserSearchTableViewCell.identifier)
        register(EventSearchTableViewCell.self, forCellReuseIdentifier: EventSearchTableViewCell.identifier)
        
        delegate = self
        dataSource = self
        backgroundColor = .clear
        separatorStyle = .none
        tableHeaderView = nil
        tableFooterView = nil
        sectionIndexBackgroundColor = .zipLightGray
        separatorColor = .zipSeparator
        backgroundColor = .clear
        bounces = false

        configureButtons()
        configureHeader()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc private func didTapUsersButton() {
        eventsButton.isSelected = false
        usersButton.isSelected = true
    }
    
    @objc private func didTapEventsButton() {
        eventsButton.isSelected = true
        usersButton.isSelected = false
    }
    
    
    private func configureButtons() {
        usersButton.addTarget(self, action: #selector(didTapUsersButton), for: .touchUpInside)
        eventsButton.addTarget(self, action: #selector(didTapEventsButton), for: .touchUpInside)
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBodyBold.withSize(16),
                                                               .foregroundColor: UIColor.white,
                                                               .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBodyBold.withSize(16),
                                                               .foregroundColor: UIColor.white]
        
        let userSelected = NSAttributedString(string: "Users", attributes: underlineAttributes)
        let userUnselected = NSAttributedString(string: "Users", attributes: normalAttributes)
        
        let eventsSelected = NSAttributedString(string: "Events", attributes: underlineAttributes)
        let eventsUnselected = NSAttributedString(string: "Events", attributes: normalAttributes)
        
        usersButton.setAttributedTitle(userSelected, for: .selected)
        usersButton.setAttributedTitle(userUnselected, for: .normal)
        
        eventsButton.setAttributedTitle(eventsSelected, for: .selected)
        eventsButton.setAttributedTitle(eventsUnselected, for: .normal)
        
        usersButton.isSelected = true
    }
    
    private func configureHeader() {
        header.backgroundColor = .zipGray
        
        header.addSubview(usersButton)
        header.addSubview(eventsButton)
        
        usersButton.translatesAutoresizingMaskIntoConstraints = false
        usersButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        usersButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.centerYAnchor.constraint(equalTo: usersButton.centerYAnchor).isActive = true
        eventsButton.leftAnchor.constraint(equalTo: usersButton.rightAnchor, constant: 20).isActive = true
        
        header.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        
        
        tableHeaderView = header
    }
    
    
    
    
}


extension SearchBarTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 
    }
}


extension SearchBarTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellEvent = eventData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell
        cell.selectionStyle = .none
        cell.clipsToBounds = true
        cell.configure(cellEvent)
        cell.backgroundColor = .zipGray
        return cell
    }
    
}
