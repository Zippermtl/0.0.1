//
//  ZipRequestTableViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/16/22.
//

import UIKit


class EventInvitesTableView: UITableView {
    var events: [Event]
    weak var FPCDelegate: FPCTableDelegate?
    
    init(events: [Event]){
        self.events = events
        super.init(frame: .zero, style: .plain)

        register(FPCEventTableViewCell.self, forCellReuseIdentifier: FPCEventTableViewCell.identifier)
        register(UITableViewCell.self, forCellReuseIdentifier: "noEvents")
        delegate = self
        dataSource = self
        backgroundColor = .clear
        separatorStyle = .none
        tableHeaderView = nil
        tableFooterView = nil
        sectionIndexBackgroundColor = .zipLightGray
        separatorColor = .zipSeparator
        backgroundColor = .clear
        isScrollEnabled = false
        bounces = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateEvents(events: [Event]) {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else { return }
        self.events = events.filter({ !$0.hosts.contains(User(userId: userId))})
        FPCDelegate?.updateEventsLabel(events: self.events)
        reloadData()
    }
}


extension EventInvitesTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if events.count != 0 {
            return events.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        FPCDelegate?.openEvent(event: events[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if events.count != 0 {
            let cellEvent = events[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: FPCEventTableViewCell.identifier, for: indexPath) as! FPCEventTableViewCell
            cell.delegate = self
            cellEvent.tableViewCell = cell
            cell.selectionStyle = .none
            cell.clipsToBounds = true
            cell.configure(cellEvent)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noEvents")!
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .zipVeryLightGray
            content.textProperties.font = .zipBody.withSize(16)
            content.textProperties.alignment = .center
            content.text = "You have no pending event Invites"
            cell.contentConfiguration = content
            return cell
        }
    
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        }
    }
    
}



extension EventInvitesTableView: UpdateZipRequestsTableDelegate {
    func deleteEventsRow(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self)
        guard let indexPath = indexPathForRow(at: point) else {
            return
        }
        
        events.remove(at: indexPath.row)
        FPCDelegate?.updateEventsLabel(events: events)
        if events.count == 0 {
            reloadData()
        } else {
            beginUpdates()
            deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .top)
            endUpdates()
        }
    }
    
    func deleteZipRequestRow(_ sender: UIButton) {
        //nil
    }
}



