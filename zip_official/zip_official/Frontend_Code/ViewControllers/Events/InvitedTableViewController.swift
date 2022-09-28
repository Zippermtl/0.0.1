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
    var noItemsLabel : UILabel
    weak var FPCEventDelegate: FPCTableDelegate?
    weak var FPCZipDelegate: FPCTableDelegate?

    var items : [CellItem]
    var removeCells: Bool
    init(cellItems : [CellItem], removeCells: Bool = true) {
        self.items = cellItems
        self.noItemsLabel = UILabel.zipSubtitle2()
        self.removeCells = removeCells
        noItemsLabel.textColor = .zipVeryLightGray
        super.init(cellData: cellItems, cellType: CellType(userType: .zipRequest, eventType: .rsvp))
        initConfig()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initConfig() {
        view.addSubview(noItemsLabel)
        noItemsLabel.translatesAutoresizingMaskIntoConstraints = false
        noItemsLabel.topAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noItemsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.bringSubviewToFront(noItemsLabel)
        
       
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = super.tableView(tableView, cellForRowAt: indexPath) as? InvitedCell else {
            fatalError("Passed InvitedTableView a non invited cell")
        }
        if removeCells {
            cell.delegate = self
        }
        
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let num = super.numberOfSections(in: tableView)
        if num == 0 { noItemsLabel.isHidden = false }
        else { noItemsLabel.isHidden = true }
        return num
    }
    
    func reload(cellItems: [CellItem], fetchTable: Bool = true) {
        super.reload(cellItems: cellItems, cellType: CellType(userType: .zipRequest, eventType: .rsvp), fetchTable: fetchTable)
        self.items = cellItems
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "empty")
        view?.contentView.frame = CGRect(x: 0, y: 0, width: 50, height: 1)
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func removeItem(cellItem: CellItem) {
        if let idx = items.firstIndex(where: { item in
            if item.isUser && cellItem.isUser {
                return item as! User == cellItem as! User
            } else if item.isEvent  && cellItem.isEvent {
                return item as! Event == cellItem as! Event
            }
            return false
        }) {
            items.remove(at: idx)
            reload(cellItems: items)
        }
    }


    func addItem(cellItem: CellItem) {
        items.append(cellItem)
        reload(cellItems: items)
    }
}

extension InvitedTableViewController : InvitedTableViewDelegate {
    func removeCell(indexPath: IndexPath) {
        items.remove(at: indexPath.row)
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        reload(cellItems: items)
        tableView.reloadData()
        tableView.endUpdates()
        if let delegate = FPCZipDelegate {
            delegate.updateZipsLabel(cellItems: items)
        } else if let delegate = FPCEventDelegate {
            delegate.updateEventsLabel(cellItems: items)
        }
    }
}
