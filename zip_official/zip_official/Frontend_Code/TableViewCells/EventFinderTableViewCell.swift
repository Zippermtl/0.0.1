//
//  EventFinderTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/12/21.
//

import UIKit
import MapKit
import CoreLocation

protocol SaveEventCellProtocol : AnyObject {
    func saveEvent(event: Event)
    func unsaveEvent(event: Event)
}

class EventFinderTableViewCell: AbstractEventTableViewCell {
    let saveButton: UIButton
    weak var delegate : SaveEventCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.saveButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let saveimg = UIImage(systemName: "bookmark.circle", withConfiguration: largeConfig)!
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        
        saveButton.setImage(saveimg, for: .normal)
        saveButton.setImage(saveimg.withTintColor(.zipBlue), for: .selected)
        
        saveButton.addTarget(self, action: #selector(didTapSaveButton), for: .touchUpInside)
        
        
        contentView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        saveButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
    }
    
    
    override func configure(_ event: Event) {
        super.configure(event)

        let myEvents = User.getUDEvents(toKey: .hostedEvents) + User.getUDEvents(toKey: .pastHostEvents)
        
        if myEvents.contains(event) {
            saveButton.isHidden = true
        } else {
            saveButton.isHidden = false
        }
        
        let savedEvents = User.getUDEvents(toKey: .savedEvents)
        if savedEvents.contains(event) {
            saveButton.isSelected = true
        } else {
            saveButton.isSelected = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapSaveButton() {
        if !saveButton.isSelected { // case where it was already saved
            event.markSaved(completion: { [weak self] error in
                guard error == nil,
                      let saveButton = self?.saveButton else {
                    return
                }
                saveButton.isSelected = !saveButton.isSelected
                DispatchQueue.main.async { [weak self] in
                    guard let event = self?.event,
                          let delegate = self?.delegate else { return }
                    delegate.saveEvent(event: event)
                }
            })
            
        } else {
            event.markUnsaved(completion: { [weak self] error in
                guard error == nil,
                      let saveButton = self?.saveButton else {
                    return
                }
                saveButton.isSelected = !saveButton.isSelected
                DispatchQueue.main.async { [weak self] in
                    guard let event = self?.event,
                          let delegate = self?.delegate else { return }
                    delegate.unsaveEvent(event: event)
                }
            })

        }
        
    }
}
