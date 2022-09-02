//
//  ZipRequestTableViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/16/22.
//

import UIKit

protocol InvitedCell : UITableViewCell {
    var delegate : InvitedTableViewDelegate? {get set}
    var iPath : IndexPath {get set}
    func setIndexPath(indexPath: IndexPath)
}

protocol InvitedTableViewDelegate : AnyObject {
    func removeCell(indexPath : IndexPath)
}

class InvitedTableViewController : MasterTableViewController {
    weak var FPCDelegate: FPCTableDelegate?
    
    var items : [CellItem]
    init(cellItems : [CellItem]) {
        self.items = cellItems
        super.init(cellData: cellItems, cellType: CellType(userType: .zipRequest, eventType: .rsvp))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as? InvitedCell else {
            fatalError("Passed InvitedTableView a non invited cell")
        }
        
        cell.delegate = self
        return cell
    }
}

extension InvitedTableViewController : InvitedTableViewDelegate {
    func removeCell(indexPath: IndexPath) {

//        tableView.beginUpdates()
//        tableView.deleteRows(at: [indexPath], with: .top)
//        tableView.endUpdates()
//        if let delegate = FPCDelegate {
//            print("Updating")
//            delegate.updateLabel(cellItems: items)
//        }
    }
}
