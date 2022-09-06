//
//  EventFinderTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/12/21.
//

import UIKit
import MapKit
import CoreLocation



class EventFinderTableViewCell: AbstractEventTableViewCell {
    let saveButton: UIButton
    
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
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapSaveButton() {
        if saveButton.isSelected { // case where it was already saved
            DatabaseManager.shared.markSaved(event: event, completion: { [weak self] error in
                guard error == nil,
                      let saveButton = self?.saveButton else {
                    return
                }
                saveButton.isSelected = !saveButton.isSelected
            })
        } else {
            DatabaseManager.shared.markUnsaved(event: event, completion: {[weak self] error in
                guard error == nil,
                      let saveButton = self?.saveButton else {
                    return
                }
                saveButton.isSelected = !saveButton.isSelected
            })

        }
        
    }
}
