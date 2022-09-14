//
//  EventCellController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/31/22.
//

import Foundation
import UIKit


class EventCellController: TableCellController {
   
    
    
    weak var delegate : TableControllerDelegate?

    fileprivate let event : Event
    
    fileprivate let cellType : EventCellType
    
    func getItem() -> CellItem {
        return event
    }

    init(item : CellItem, cellType: CellType) {
        if item.isUser {
            fatalError("Passed an User to a EventCellController")
        }
        self.event = item as! Event
        self.cellType = cellType.eventType
    }
    
    static func registerCell(on tableView: UITableView, cellTypes: [CellType]) {
        for cellType in cellTypes {
            switch cellType.eventType {
            case .abstract: tableView.register(AbstractEventTableViewCell.self, forCellReuseIdentifier: AbstractEventTableViewCell.identifier)
            case .save: tableView.register(EventFinderTableViewCell.self, forCellReuseIdentifier: EventFinderTableViewCell.identifier)
            case .inviteTo: tableView.register(EventInviteTableViewCell.self, forCellReuseIdentifier: EventInviteTableViewCell.identifier)
            case .rsvp: tableView.register(FPCEventTableViewCell.self, forCellReuseIdentifier: FPCEventTableViewCell.identifier)
            }
        }
    }
    
    func cellFromTableView(_ tableView: UITableView, forIndexPath indexPath: IndexPath, cellType: CellType) -> UITableViewCell {
        var cell : AbstractEventTableViewCell
        switch cellType.eventType {
        case .abstract: cell = tableView.dequeueReusableCell(withIdentifier: AbstractEventTableViewCell.identifier, for: indexPath) as! AbstractEventTableViewCell
        case .save: cell = tableView.dequeueReusableCell(withIdentifier: EventFinderTableViewCell.identifier, for: indexPath) as! EventFinderTableViewCell
        case .inviteTo: cell = tableView.dequeueReusableCell(withIdentifier: EventInviteTableViewCell.identifier, for: indexPath) as! EventInviteTableViewCell
        case .rsvp: cell = tableView.dequeueReusableCell(withIdentifier: FPCEventTableViewCell.identifier, for: indexPath) as! FPCEventTableViewCell
        }
        
        cell.selectionStyle = .none
        event.tableViewCell = cell
        cell.configure(event)
        return cell
    }
    
    func didSelectCell() {
        print("TAPPED EVENT = ", event)
        var vc : UIViewController
        if event.hosts.contains(User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)) {
            vc = MyEventViewController(event: event)
        } else {
            vc = EventViewController(event: event)
        }
        delegate?.openVC(vc)
    }
    
    func heightForRowAt(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func fetch(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.loadEvent(event: event, completion: { result in
            switch result {
            case .success(let event):
                guard let cell = event.tableViewCell else { return }
                cell.configure(event)
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func fetchImage(completion: @escaping (Error?) -> Void) {
        DatabaseManager.shared.getImages(Id: event.eventId, indices: event.eventCoverIndex, event: true, completion: { [weak self] res in
            guard let strongSelf = self else { return }
            switch res{
            case .success(let url):
                if url.count != 0 {
                    strongSelf.event.imageUrl = url[0]
                }
                if let cell = strongSelf.event.tableViewCell {
                    cell.configureImage(strongSelf.event)
                }
                completion(nil)
            case .failure(let error):
                completion(error)
            }
        })
    }
    
    func filterResult(searchText: String) -> Bool {
        return event.title.lowercased().contains(searchText)
            || event.ownerName.lowercased().contains(searchText)
            || event.address.lowercased().contains(searchText)
    }
    
    func itemEquals(cellItem: CellItem) -> Bool {
        if self.getItem().isEvent != cellItem.isEvent { return false }
        return (getItem() as! Event) == (cellItem as! Event)
    }
}
