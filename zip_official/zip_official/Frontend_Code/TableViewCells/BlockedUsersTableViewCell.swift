//
//  blockedUsersTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/20/22.
//

import Foundation
import UIKit


class BlockedUserTableViewCell: AbstractUserTableViewCell {
    private let unblockButton : UIButton
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        unblockButton = UIButton()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        unblockButton.addTarget(self, action: #selector(didTapUnblock), for: .touchUpInside)
        unblockButton.setTitle("Unblock", for: .selected)
        unblockButton.setTitle("Block", for: .normal)
        unblockButton.setTitleColor(.red, for: .selected)
        unblockButton.setTitleColor(.zipBlue, for: .normal)
        unblockButton.titleLabel?.font = .zipSubtitle2

        contentView.addSubview(unblockButton)
        unblockButton.translatesAutoresizingMaskIntoConstraints = false
        unblockButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        unblockButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
        let blockedUsers = AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String] ?? []
        if blockedUsers.contains(user.userId) {
            unblockButton.isSelected = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapUnblock(){
        // selected = unblock
        if unblockButton.isSelected {
            DatabaseManager.shared.unblockUser(toUnblockUserId: user.userId, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.unblockButton.isSelected = !strongSelf.unblockButton.isSelected
            })
        } else {
            DatabaseManager.shared.blockUser(toBlockUserId: user.userId, completion: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.unblockButton.isSelected = !strongSelf.unblockButton.isSelected
            })
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unblockButton.isSelected = false
    }
    
}
