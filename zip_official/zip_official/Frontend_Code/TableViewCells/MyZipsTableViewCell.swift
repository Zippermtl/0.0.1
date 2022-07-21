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
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        requestButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel.font = .zipTextNoti
        
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let addImg = UIImage(systemName: "plus.circle.fill", withConfiguration: largeConfig)!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let requestImg = UIImage(systemName: "arrow.forward.circle.fill", withConfiguration: largeConfig)!.withRenderingMode(.alwaysOriginal).withTintColor(.zipYellow)
        requestButton.setImage(addImg, for: .normal)
        requestButton.setImage(requestImg, for: .selected)
        
        contentView.addSubview(requestButton)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        requestButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
        
        switch user.friendshipStatus {
        case .none:
            requestButton.isHidden = false
            requestButton.isSelected = false
        case .REQUESTED_INCOMING:
            requestButton.isHidden = false
            requestButton.isSelected = false
        case .REQUESTED_OUTGOING:
            requestButton.isHidden = false
            requestButton.isSelected = true
        case .ACCEPTED:
            requestButton.isHidden = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapRequest(){
        
    }
    
}
