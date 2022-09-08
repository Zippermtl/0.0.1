//
//  InviteTableViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/2/22.
//

import Foundation
import UIKit

protocol InviteCell : UITableViewCell {
    var delegate : InviteTableViewDelegate? { get set }
}

protocol InviteTableViewDelegate: AnyObject {
    func select(cellItem: CellItem)
    func unselect(cellItem: CellItem)
}


class InviteTableViewController : MasterTableViewController {
    var selectedItems = [String : CellItem]()
    init(items: [CellItem]) {
        super.init(cellData: items, cellType: CellType(userType: .invite, eventType: .inviteTo))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Invite", style: .plain, target: self, action: #selector(didTapInvite))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let cell = cell as? InviteCell {
            cell.delegate = self
        }
        return cell
    }
    
    @objc private func didTapInvite() {
        guard let saveFunc = saveFunc else { return }
        saveFunc(Array(selectedItems.values))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InviteTableViewController : InviteTableViewDelegate {
    func select(cellItem: CellItem) {
        selectedItems[cellItem.getId()] = cellItem
    }
    
    func unselect(cellItem: CellItem) {
        selectedItems.removeValue(forKey: cellItem.getId())
    }
}
