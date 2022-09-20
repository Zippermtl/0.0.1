//
//  File.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/10/22.
//

import Foundation
import UIKit

class RecurringEventViewController : EventViewController {
    
    override init(event: Event) {
        super.init(event: event)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .light, scale: .large)
        let config2 = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let globeIcon =  UIImage(systemName: "globe", withConfiguration: config)!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let phoneIcon =  UIImage(systemName: "phone", withConfiguration: config2)!.withRenderingMode(.alwaysOriginal).withTintColor(.white)

        messageButton.setIcon(icon: globeIcon)
        messageButton.setTextLabel(s: "Website")
        participantsButton.setIcon(icon: phoneIcon)
        participantsButton.setTextLabel(s: "Call")
        if let rEvent = event as? RecurringEvent {
            eventTypeLabel.textColor = rEvent.category.color
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didTapMessageButton() {
         guard let event = event as? RecurringEvent,
              let websiteString = event.website,
              let url = URL(string: websiteString)
        else {
            
            return
        }
        UIApplication.shared.open(url)
    }
    
    override func didTapSaveButton() {
        
    }
    
    override func didTapParticipantsButton() {
        guard let event = event as? RecurringEvent,
              let phoneNumber = event.phoneNumber else {
            return
            
        }
        
        
        
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
        
    }
    
    override func didTapHost() {
        
    }
    
    override func configureInviteButton() {
        
    }
    
    override func updateTime() {
        
    }
    
    override func configureLoadedEvent() {
        super.configureLoadedEvent()
        if let rEvent = event as? RecurringEvent {
            eventTypeLabel.textColor = rEvent.category.color
        }
    }
    
    override func fetchEvent(completion: (() -> Void)? = nil) {
        configureLoadedEvent()
        
        event.getImage(completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.eventPhotoView.sd_setImage(with: url)
                if let completion = completion {
                    completion()
                }
            case .failure(let error):
                print("error loading recurring event image in vc Error: ",error)
                if let completion = completion {
                    completion()
                }
            }
            
        })
    }
    
    override func configureLabels() {
        guard let event = event as? RecurringEvent,
              let venu = event.venu
        else { return }
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.zipTextNoti,
                                                         .foregroundColor: UIColor.zipVeryLightGray]
        
        hostLabel.attributedText = NSAttributedString(string: "Happening at \(venu)", attributes: attributes)
        
        eventTypeLabel.text = event.category.rawValue
        eventTypeLabel.textColor = event.category.color
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        let start = formatter.string(from: event.startTime)
        let end = formatter.string(from: event.endTime)
        countDownLabel.text = start + " - " + end
        
        titleLabel.text = event.title
        navigationItem.titleView = titleLabel
        
    }
    
    override func configureTableHeaderLayout() {
        tableHeader.addSubview(eventPhotoView)
        eventPhotoView.translatesAutoresizingMaskIntoConstraints = false
        eventPhotoView.topAnchor.constraint(equalTo: tableHeader.topAnchor, constant: 20).isActive = true
        eventPhotoView.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        eventPhotoView.heightAnchor.constraint(equalToConstant: view.frame.width/3).isActive = true
        eventPhotoView.widthAnchor.constraint(equalTo: eventPhotoView.heightAnchor).isActive = true
        
        eventPhotoView.layer.masksToBounds = true
        eventPhotoView.layer.cornerRadius = view.frame.width/6
      
        tableHeader.addSubview(countDownLabel)
        countDownLabel.translatesAutoresizingMaskIntoConstraints = false
        countDownLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        countDownLabel.topAnchor.constraint(equalTo: eventPhotoView.bottomAnchor, constant: 5).isActive = true
        
        tableHeader.addSubview(eventTypeLabel)
        eventTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        eventTypeLabel.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor).isActive = true
        eventTypeLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true

        tableHeader.addSubview(hostLabel)
        hostLabel.translatesAutoresizingMaskIntoConstraints = false
        hostLabel.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        hostLabel.topAnchor.constraint(equalTo: eventTypeLabel.bottomAnchor,constant: 5).isActive = true
                
        tableHeader.addSubview(participantsButton)
        participantsButton.translatesAutoresizingMaskIntoConstraints = false
        participantsButton.centerXAnchor.constraint(equalTo: tableHeader.centerXAnchor).isActive = true
        participantsButton.topAnchor.constraint(equalTo: hostLabel.bottomAnchor, constant: 20).isActive = true

        participantsButton.setIconDimension(width: 60)

        tableHeader.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: tableHeader.rightAnchor, constant: -55).isActive = true
        saveButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        saveButton.setIconDimension(width: 60)
        
        tableHeader.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.leftAnchor.constraint(equalTo: tableHeader.leftAnchor, constant: 55).isActive = true
        messageButton.topAnchor.constraint(equalTo: participantsButton.topAnchor).isActive = true
        messageButton.setIconDimension(width: 60)
        
        tableHeader.translatesAutoresizingMaskIntoConstraints = false
//        tableHeader.topAnchor.constraint(equalTo: eventPhotoView.topAnchor).isActive = true
        tableHeader.bottomAnchor.constraint(equalTo: participantsButton.bottomAnchor, constant: 20).isActive = true
        tableHeader.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        
        
        participantsButton.layer.cornerRadius = 30
        saveButton.layer.cornerRadius = 30
        messageButton.layer.cornerRadius = 30
                
        saveButton.iconAddTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        messageButton.iconAddTarget(self, action: #selector(didTapMessageButton), for: .touchUpInside)
        participantsButton.iconAddTarget(self, action: #selector(didTapParticipantsButton), for: .touchUpInside)
        
        tableView.tableHeaderView = tableHeader
        
        tableHeader.setNeedsLayout()
        tableHeader.layoutIfNeeded()

        let height = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        var frame = tableHeader.frame
        frame.size.height = height
        tableHeader.frame = frame

        tableView.tableHeaderView = tableHeader
    }
    
    override func configureCells() {
        guard let event = event as? RecurringEvent else { return }
        cellConfigurations.removeAll()
        let addressString = NSMutableAttributedString(string: event.address)
        let distanceString = NSMutableAttributedString(string: event.getDistanceString())
        let dateString =  NSMutableAttributedString(string: event.startTime.dayOfWeek() ?? "Today")
        
        cellConfigurations.append((addressString,
                                    UIImage(systemName: "map")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)))
        
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        cellConfigurations.append((distanceString,
                                    UIImage(named: "zip.mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white).withConfiguration(pinConfig)))
       
        cellConfigurations.append((dateString,
                                    UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)))

        cellConfigurations.append((NSMutableAttributedString(string: event.bio), nil))
    }
}
