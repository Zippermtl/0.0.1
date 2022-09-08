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
           
      
        
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
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
    
    override func configureGoingButton() {
        goingButton.setTitle("Edit", for: .normal)
        goingButton.titleLabel?.textColor = .white
        goingButton.titleLabel?.font = .zipSubtitle2
        goingButton.titleLabel?.textAlignment = .center
        goingButton.contentVerticalAlignment = .center
        goingButton.backgroundColor = .zipLightGray
    }
    
    override func configureInviteButton() {
        goingButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
    }
    
    override func configureLabels(){
        super.configureLabels()
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextPrompt4,
                                                         .foregroundColor: UIColor.zipVeryLightGray,
                                                         .underlineStyle: NSUnderlineStyle.single.rawValue]
        if event.hosts.count > 1 {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by You + \(event.hosts.count-1) more", attributes: attributes)
        } else {
            hostLabel.attributedText = NSAttributedString(string: "Hosted by You", attributes: attributes)
        }
    }
    
    override func didTapGoingButton() {
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot edit expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        if event.getType() == .Promoter {
            let vc = EditPromoterViewController(event: event)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = EditEventProfileViewController(event: event)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didTapSaveButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Copy Event Link", style: .default, handler: { _ in
            UIPasteboard.general.string = ""
            
        }))
    }
    
    override func didTapMessageButton() {
        didTapInviteButton()
    }
    
    var originalHosts = [Event]()
    
    override func didTapHost() {
        let vc = MasterTableViewController(sectionData: [event.hostingSection])
        vc.title = "Hosts"
        vc.delegate = self
        vc.dispearingRightButton = true
        vc.saveFunc = uninviteHosts
        let selfUser = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)
        if selfUser.userId == event.ownerId {
            vc.defaultRightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                                       style: UIBarButtonItem.Style.done,
                                                       target: self,
                                                       action: #selector(inviteHosts))
            let uninviteConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Remove", { item in
                vc.impactedItems.append(item)
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                                style: .done,
                                                                                target: vc,
                                                                                action: #selector(vc.saveFuncTarget))
            }, [selfUser])
            vc.trailingCellSwipeConfiguration = [uninviteConfig]

        }


        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    private func uninviteHosts(cellItems: [CellItem]) {
        let users = cellItems as! [User]
        DatabaseManager.shared.uninviteHosts(event: event, users: users, completion: { [weak self] error in
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.reloadEvent()
            }
        })
    }
    
    private func uninviteUsers(cellItems: [CellItem]) {
        let users = cellItems as! [User]
        DatabaseManager.shared.uninviteUsers(event: event, users: users, completion: { [weak self] error in
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.reloadEvent()
            }
        })
    }
    
    @objc private func inviteHosts(){
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot add hosts to expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let possibleHosts = User.getMyZips().filter({ !event.hosts.contains($0) })
        let vc = InviteTableViewController(items: possibleHosts)
        vc.saveFunc = { [weak self] items in
            guard let strongSelf = self else { return }
            let users = items.map({ $0 as! User })
            
            DatabaseManager.shared.inviteHosts(event: strongSelf.event, users: users, completion: { [weak self] error in
                guard let strongSelf = self,
                      error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.configureLabels()
                    strongSelf.navigationController?.popViewController(animated: true)
                    if let vc = self?.navigationController?.topViewController as? MasterTableViewController {
                        if let sectionData = self?.event.hostingSection {
                            vc.reload(multiSectionData: [MultiSectionData(title: nil, sections: [sectionData])])
                        }
                    }
                }
            })
        }
        vc.title = "Invite Co-Hosts"
        navigationController?.pushViewController(vc, animated: true)
    }
    
 
    
    override func didTapParticipantsButton() {
        let vc = MasterTableViewController(sectionData: event.getParticipants())
        vc.title = "Participants"
        vc.delegate = self
        vc.dispearingRightButton = true
        let selfUser = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)
        vc.saveFunc = uninviteUsers
        let uninviteConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Uninvite", { item in
            vc.impactedItems.append(item)
            vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                   style: .done,
                                                                   target: vc,
                                                                   action: #selector(vc.saveFuncTarget))
        }, [selfUser])
        vc.trailingCellSwipeConfiguration = [uninviteConfig]
        navigationController?.pushViewController(vc, animated: true)
    }
    

    override func didTapReportButton() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete Event", style: .default, handler: { [weak self] _ in
            guard let event = self?.event else {
                return
            }
            
            if event.endTime <= Date() {
                let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot invite people to expired events", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(alert, animated: true)
                return
            }
            
            DatabaseManager.shared.deleteEvent(eventId: event.eventId, completion: { [weak self] error in
                guard error == nil else {
                    let failedToCancel = UIAlertController(title: "Oops! Something went wrong.", message: "Failed to delete event.", preferredStyle: .alert)
                    failedToCancel.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self?.present(failedToCancel, animated: true)
                    return
                }
                
                if let annotation = event.annotationView?.annotation {
                    event.mapView?.removeAnnotation(annotation)
                }
                self?.navigationController?.popViewController(animated: true)
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            
        }))
        
        present(alert, animated: true)
        
    }
}

extension MyEventViewController: UpdateFromEditEventProtocol {
    func update(event: Event) {
        self.event = event
        
        reloadEvent()
    }
}

extension MyEventViewController: MasterTableViewDelegate {
    func didTapRightBarButton() {
        
       
        
    }
}
