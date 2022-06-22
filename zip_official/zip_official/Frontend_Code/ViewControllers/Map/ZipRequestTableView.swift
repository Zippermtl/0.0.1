//
//  ZipRequestTableViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/16/22.
//

import UIKit

protocol FPCTableDelegate: AnyObject {
    func updateRequestsLabel(requests: [ZipRequest])
    func updateEventsLabel(events: [Event])
}


class ZipRequestTableView: UITableView {
    var requests: [ZipRequest]
    weak var FPCDelegate: FPCTableDelegate?
    
    init(requests: [ZipRequest]){
        self.requests = requests
        super.init(frame: .zero, style: .plain)

        register(ZipRequestTableViewCell.self, forCellReuseIdentifier: ZipRequestTableViewCell.identifier)
        register(UITableViewCell.self, forCellReuseIdentifier: "noRequests")
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

}


extension ZipRequestTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requests.count != 0 {
            return requests.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if requests.count != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: ZipRequestTableViewCell.identifier) as! ZipRequestTableViewCell
            cell.configure(with: requests[indexPath.row])
            cell.delegate = self
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "noRequests")!
            cell.backgroundColor = .clear
            cell.selectionStyle = .none
            var content = cell.defaultContentConfiguration()
            content.textProperties.color = .zipVeryLightGray
            content.textProperties.font = .zipBody.withSize(16)
            content.textProperties.alignment = .center
            content.text = "You have no requests"
            cell.contentConfiguration = content
            return cell
        }
    }
    
}



extension ZipRequestTableView: UpdateZipRequestsTableDelegate {
    func deleteEventsRow(_ sender: UIButton) {
        //nil
    }
    
    func deleteZipRequestRow(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: self)
        guard let indexPath = indexPathForRow(at: point) else {
            return
        }
        requests.remove(at: indexPath.row)
        
        FPCDelegate?.updateRequestsLabel(requests: requests)

        if requests.count == 0 {
            reloadData()
        } else {
            beginUpdates()
            deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .top)
            endUpdates()
        }
    }
}



