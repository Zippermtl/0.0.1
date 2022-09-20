//
//  MyZipsTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation
import MapKit



class MyZipsTableViewCell: AbstractUserTableViewCell {
    static let zippedIdentifier = "zippedListUser"
    static let notZippedIdentifier = "notZippedListUser"
    
    private let requestButton: UIButton
    
    let images : [UIImage]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        requestButton = UIButton()
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let addImg = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)!
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.white)
        
        let requestImg = UIImage(systemName: "arrow.forward.circle.fill", withConfiguration: largeConfig)!
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        
        let zippedImg = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)!
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipBlue)
        
        images = [addImg, requestImg, zippedImg]
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel.font = .zipTextNoti
        
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)

        contentView.addSubview(requestButton)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        requestButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
        configureRequestedButton()
    }
    
    private func configureRequestedButton() {
        requestButton.isSelected = false
        switch user.friendshipStatus {
        case .none:
            requestButton.setImage(images[0], for: .normal)
        case .REQUESTED_INCOMING:
            requestButton.setImage(images[0], for: .normal)
        case .REQUESTED_OUTGOING:
            requestButton.setImage(images[1], for: .normal)
        case .ACCEPTED:
            requestButton.setImage(images[2], for: .normal)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapRequest(){
        switch user.friendshipStatus {
        case .ACCEPTED:
            user.unfriend(completion: {[weak self] err in
                guard err == nil else {
                    return
                }
                self?.configureRequestedButton()
            })
        case .REQUESTED_OUTGOING:
            user.unsendRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.configureRequestedButton()
            })
        case .REQUESTED_INCOMING: // You have now accepted the follow request
            user.acceptRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.configureRequestedButton()
            })
        case .none:
            user.sendRequest(completion: { [weak self] err in
                guard err == nil else {
                    return
                }
                self?.configureRequestedButton()
            })
            
        }
    }
    
}
