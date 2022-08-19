//
//  ZipRequestsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/19/21.
//

import UIKit

class EventInvitesViewController: UIViewController {
    var tableView: EventInvitesTableView
    var events: [Event]
    
    @objc private func didTapDismiss(){
        dismiss(animated: true)
    }
    
    init(events: [Event]){
        self.events = events
        self.tableView = EventInvitesTableView(events: events)
        
        super.init(nibName: nil, bundle: nil)
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let dismissButton = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        dismissButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: config)?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        title = "Event Invites"
    }
}
