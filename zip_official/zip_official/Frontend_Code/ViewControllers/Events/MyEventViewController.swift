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
        
        let vc = EditEventProfileViewController(event: event)
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
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
    
    override func didTapHost() {
        let vc = MasterTableViewController(sectionData: [event.hostingSection])
        vc.title = "Hosts"
        vc.delegate = self
        vc.dispearingRightButton = true
        let selfUser = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)
        if selfUser.userId == event.ownerId {
            vc.defaultRightBarButton = UIBarButtonItem(image: UIImage(systemName: "plus")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
                                                       style: UIBarButtonItem.Style.done,
                                                       target: self,
                                                       action: #selector(inviteHosts))
            let uninviteConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Remove", { [weak self] item in
                guard let event = self?.event,
                      item.isUser,
                      let user = item as? User
                else {
                    return
                    
                }

                if let hostIdx = event.hosts.firstIndex(of: user) {
                    event.hosts.remove(at: hostIdx)
                }

                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                                style: .done,
                                                                                target: vc,
                                                                                action: #selector(vc.didTapRightBarButton))
            }, [selfUser])
            vc.trailingCellSwipeConfiguration = [uninviteConfig]

        }


        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func inviteHosts(){
        if event.endTime <= Date() {
            let alert = UIAlertController(title: "This Event Has Ended", message: "You cannot add hosts to expired events", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let possibleHosts = User.getMyZips().filter({ !event.hosts.contains($0) })
        let vc = InviteTableViewController(items: possibleHosts) { [weak self] items in
            guard let event = self?.event else { return }
            let hosts = items.map({ $0 as! User })
            for user in hosts {
                if !event.usersInvite.contains(user) {
                    event.usersInvite.append(user)
                }
            }
            event.hosts += hosts
            DatabaseManager.shared.updateEvent(event: event, completion: { [weak self] error in
                guard error == nil else {
                    let alert = UIAlertController(title: "Error Inviting Users",
                                                  message: "\(error!.localizedDescription)",
                                                  preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Ok",
                                                  style: .cancel,
                                                  handler: { _ in }))
                    DispatchQueue.main.async {
                        self?.present(alert, animated: true)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.configureLabels()
                    self?.navigationController?.popViewController(animated: true)
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
        let zipListView = MasterTableViewController(sectionData: event.getParticipants())
        zipListView.title = "Participants"
        zipListView.delegate = self
        zipListView.dispearingRightButton = true
        let selfUser = User(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String)
        let uninviteConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Uninvite", { [weak self] item in
            guard let event = self?.event,
                  item.isUser,
                  let user = item as? User
            else {
                return
                
            }
            if let goingIdx = event.usersGoing.firstIndex(of: user) {
                event.usersGoing.remove(at: goingIdx)
            } else if let notGoingIdx = event.usersNotGoing.firstIndex(of: user) {
                event.usersGoing.remove(at: notGoingIdx)
            }
            
            if let inviteIdx = event.usersInvite.firstIndex(of: user) {
                event.usersInvite.remove(at: inviteIdx)
            }
            
            if let hostIdx = event.hosts.firstIndex(of: user) {
                event.hosts.remove(at: hostIdx)
            }
            
            zipListView.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                                            style: .done,
                                                                            target: zipListView,
                                                                            action: #selector(zipListView.didTapRightBarButton))
        }, [selfUser])
        zipListView.trailingCellSwipeConfiguration = [uninviteConfig]
        navigationController?.pushViewController(zipListView, animated: true)
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
        DatabaseManager.shared.updateEvent(event: event, completion: { [weak self] error in
            guard error == nil else {
                return
            }
            self?.reloadEvent()
        })
    }
}
