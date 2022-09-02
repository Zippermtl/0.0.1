//
//  ZipperCellControllerFactory.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/31/22.
//

import Foundation
import UIKit




class CellControllerFactory {
    var items : [CellItem]
    var cellTypes : [CellType]

 
    
    init(items: [CellItem], cellTypes: [CellType]) {
        self.items = items
        self.cellTypes = cellTypes
    }
    
    init(users: [User], userCellTypes: [UserCellType]) {
        self.items = users
        self.cellTypes = userCellTypes.map({ CellType(userType: $0, eventType: .abstract) })
    }
    
    init(events: [Event], eventCellTypes: [EventCellType]) {
        self.items = events
        self.cellTypes = eventCellTypes.map({ CellType(userType: .abstract, eventType: $0) })
    }
    
//
//    func cellControllers(with items: [CellItem]) -> [TableCellController] {
//        return items.map { items in
//
//
//        }
//    }
//
    func registerCells(on tableView: UITableView) {
        
    }
    
}
