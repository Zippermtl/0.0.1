//
//  MasterTableConfig.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/1/22.
//

import Foundation
import UIKit

public protocol CellItem {
    var isUser : Bool {get}
    var isEvent: Bool {get}
    func getId() -> String
}

protocol TableCellController {
    var delegate : TableControllerDelegate? { get set }
    static func registerCell(on tableView: UITableView, cellTypes : [CellType])
    func cellFromTableView(_ tableView: UITableView, forIndexPath indexPath: IndexPath, cellType: CellType) -> UITableViewCell
    func didSelectCell()
    func heightForRowAt(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    func fetch(completion: @escaping (Error) -> Void)
    func getItem() -> CellItem
    func filterResult(searchText: String) -> Bool
    func itemEquals(cellItem: CellItem) -> Bool
}

class CellType {
    var userType : UserCellType
    var eventType : EventCellType
    
    init(userType: UserCellType, eventType: EventCellType) {
        self.userType = userType
        self.eventType = eventType
    }
    
    init(userType: UserCellType) {
        self.userType = userType
        self.eventType = .abstract
    }
    
    init(eventType: EventCellType) {
        self.userType = .abstract
        self.eventType = eventType
    }
}

enum UserCellType {
    case abstract
    case zipRequest
    case zipList
    case message
    case invite
    case inviteToEventNotif
    case zippedBackNotif
}

enum EventCellType {
    case abstract
    case save
    case inviteTo
    case rsvp
}

class CellSectionData {
    var title: String?
    var items: [TableCellController]
    var cellType: CellType

    init(title: String?, items: [TableCellController], cellType: CellType) {
        self.title = title
        self.items = items
        self.cellType = cellType
    }
    
    init(title: String?, items: [TableCellController], cellType: UserCellType) {
        self.title = title
        self.items = items
        self.cellType = CellType(userType: cellType, eventType: .abstract)
    }
    
    init(title: String?, items: [TableCellController], cellType: EventCellType) {
        self.title = title
        self.items = items
        self.cellType = CellType(userType: .abstract, eventType: cellType)
    }
    
    init(title: String?, items: [CellItem], cellType: CellType) {
        let sectiondata = MasterTableViewController.cellControllers(with: items, title: title, cellType: cellType)
        self.title = sectiondata.title
        self.items = sectiondata.items
        self.cellType = cellType
    }
}

class MultiSectionData {
    var title: String?
    var sections : [CellSectionData]
    
    init(title: String?, sections: [CellSectionData]) {
        self.title = title
        self.sections = sections
    }
}

protocol MasterTableViewDelegate: AnyObject {
    func didTapRightBarButton()
}

protocol TableControllerDelegate : AnyObject {
    func openVC(_ vc : UIViewController)
}
