//
//  ZipListTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/26/21.
//

import UIKit
import CoreLocation


class ZipListTableViewCell: AbstractUserTableViewCell {
    static let zippedIdentifier = "zippedListUser"
    static let notZippedIdentifier = "notZippedListUser"
    
    private let requestButton: UIButton
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        requestButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel = UILabel.zipTextNoti()
        
        requestButton.addTarget(self, action: #selector(didTapRequest), for: .touchUpInside)
        
        let addImg = UIImage(systemName: "plus.circle.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let requestImg = UIImage(systemName: "arrow.forward.circle.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.zipYellow)
        requestButton.setImage(addImg, for: .normal)
        requestButton.setImage(requestImg, for: .selected)
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
        
        switch user.friendshipStatus {
        case .none:
            requestButton.isHidden = true
            requestButton.isSelected = false
        case .REQUESTED_INCOMING:
            requestButton.isHidden = true
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
