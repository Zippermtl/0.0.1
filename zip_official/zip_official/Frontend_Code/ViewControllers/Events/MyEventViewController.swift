//
//  EventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import UIKit
import MapKit
import CoreLocation
import JGProgressHUD


class MyEventViewController: EventViewController {
    
    override init(event: Event) {
        event.allowUserInvites = false
        super.init(event: event)
        
//        goingButton.layer.borderWidth = 1
           
        goingButton.setTitle("Edit", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .medium, scale: .large)
        let config2 = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)

        let shareIcon =  UIImage(systemName: "square.and.arrow.up", withConfiguration: config)!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let inviteIcon =  UIImage(systemName: "paperplane", withConfiguration: config2)!.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        messageButton.setIcon(icon: inviteIcon)
        messageButton.setTextLabel(s: "Invite")
        saveButton.setIcon(icon: shareIcon)
        saveButton.setTextLabel(s: "Share")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func configureLabels(){
        super.configureLabels()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipBody.withSize(16),
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        if event.hosts.count > 1 {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by You + \(event.hosts.count-1) more", attributes: attributes)
        } else {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by You", attributes: attributes)
        }
    }
    
    override func didTapGoingButton() {
        let vc = EditEventProfileViewController(event: event)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapSaveButton() {
            // uhhh what we doing here?
    }
    
    override func didTapMessageButton() {
        let vc = InviteMoreViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapHost() {
        let vc = UsersTableViewController(users: event.hosts)
        vc.title = "Hosts"
        navigationController?.pushViewController(vc, animated: true)
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                                               style: UIBarButtonItem.Style.done,
                                                               target: self,
                                                               action: #selector(inviteHosts))
        
    }
    
    @objc private func inviteHosts(){
        let vc = InviteHostsViewController(event: event)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didTapReportButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Event", style: .cancel, handler: { _ in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        
        present(alert, animated: true)
        
    }
}

extension MyEventViewController: UpdateFromEditProtocol {
    func update() {
        tableView.reloadData()
        title = event.title
        configureCells()
    }
}
