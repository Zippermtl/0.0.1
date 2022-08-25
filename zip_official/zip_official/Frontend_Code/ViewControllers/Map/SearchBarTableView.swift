//
//  SearchBarTableView.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/17/22.
//

import Foundation
import UIKit

class SearchBarTableView: UITableView {    
    var header: UIView
    var allButton:UIButton
    var usersButton: UIButton
    var eventsButton: UIButton
    var searchData: [SearchObject]
    var tableData:[SearchObject]
    
    init() {
        self.header = UIView()
        self.allButton = UIButton()
        self.usersButton = UIButton()
        self.eventsButton = UIButton()
        self.searchData = []
        self.tableData = []
        
        
        super.init(frame: .zero, style: .plain)
        backgroundColor = .zipGray
        
        
        register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
        register(MyZipsTableViewCell.self, forCellReuseIdentifier: MyZipsTableViewCell.identifier)
        
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
    
    @objc private func didTapAllButton(){
        allButton.isSelected = true
        eventsButton.isSelected = false
        usersButton.isSelected = false
        
        tableData = searchData
        reloadData()
    }
    
    @objc private func didTapUsersButton() {
        allButton.isSelected = false
        eventsButton.isSelected = false
        usersButton.isSelected = true
        
        tableData = searchData.filter({ $0.isUser() })
        reloadData()
    }
    
    @objc private func didTapEventsButton() {
        allButton.isSelected = false
        eventsButton.isSelected = true
        usersButton.isSelected = false
        
        tableData = searchData.filter({ $0.isEvent() })
        reloadData()
    }
    
    public func configureTableData(){
        if allButton.isSelected {
            tableData = searchData
        } else if eventsButton.isSelected {
            tableData = searchData.filter({ $0.isEvent() })
        } else if usersButton.isSelected {
            tableData = searchData.filter({ $0.isUser() })
        }
    }
    
    
    private func configureButtons() {
        allButton.addTarget(self, action: #selector(didTapAllButton), for: .touchUpInside)
        usersButton.addTarget(self, action: #selector(didTapUsersButton), for: .touchUpInside)
        eventsButton.addTarget(self, action: #selector(didTapEventsButton), for: .touchUpInside)
        
        let underlineAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBodyBold.withSize(16),
                                                               .foregroundColor: UIColor.white,
                                                               .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBodyBold.withSize(16),
                                                               .foregroundColor: UIColor.white]
        
        let allSelected = NSAttributedString(string: "All", attributes: underlineAttributes)
        let allUnselected = NSAttributedString(string: "All", attributes: normalAttributes)
        
        let userSelected = NSAttributedString(string: "Users", attributes: underlineAttributes)
        let userUnselected = NSAttributedString(string: "Users", attributes: normalAttributes)
        
        let eventsSelected = NSAttributedString(string: "Events", attributes: underlineAttributes)
        let eventsUnselected = NSAttributedString(string: "Events", attributes: normalAttributes)
        
        allButton.setAttributedTitle(allSelected, for: .selected)
        allButton.setAttributedTitle(allUnselected, for: .normal)
        
        usersButton.setAttributedTitle(userSelected, for: .selected)
        usersButton.setAttributedTitle(userUnselected, for: .normal)
        
        eventsButton.setAttributedTitle(eventsSelected, for: .selected)
        eventsButton.setAttributedTitle(eventsUnselected, for: .normal)
        
        allButton.isSelected = true
    }
    
    private func configureHeader() {
        header.backgroundColor = .zipGray
        header.addSubview(allButton)
        header.addSubview(usersButton)
        header.addSubview(eventsButton)
        
        allButton.translatesAutoresizingMaskIntoConstraints = false
        allButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10).isActive = true
        allButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        
        usersButton.translatesAutoresizingMaskIntoConstraints = false
        usersButton.centerYAnchor.constraint(equalTo: allButton.centerYAnchor).isActive = true
        usersButton.leftAnchor.constraint(equalTo: allButton.rightAnchor, constant: 20).isActive = true
        
        eventsButton.translatesAutoresizingMaskIntoConstraints = false
        eventsButton.centerYAnchor.constraint(equalTo: usersButton.centerYAnchor).isActive = true
        eventsButton.leftAnchor.constraint(equalTo: usersButton.rightAnchor, constant: 20).isActive = true
        
        header.frame = CGRect(x: 0, y: 0, width: frame.width, height: 40)
        
        
        tableHeaderView = header
    }
}


extension SearchBarTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableData[indexPath.row].isEvent() {
            return 120
        }
        return 90
    }
}


extension SearchBarTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchObj = searchData[indexPath.row]
        if searchObj.isEvent() {
            guard let event = searchData[indexPath.row].event else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            event.tableViewCell = cell
            cell.configure(event)
            cell.backgroundColor = .zipGray
            return cell
        } else {
            guard let user = searchData[indexPath.row].user else {
                return UITableViewCell()
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: MyZipsTableViewCell.identifier, for: indexPath) as! MyZipsTableViewCell
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            user.tableViewCell = cell
            cell.configure(user)
            cell.backgroundColor = .zipGray
            return cell
        }

    }
    
}
