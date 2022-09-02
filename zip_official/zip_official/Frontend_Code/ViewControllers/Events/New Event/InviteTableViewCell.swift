//
//  EventInviteTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/28/21.
//

import UIKit



class InviteTableViewCell: AbstractUserTableViewCell, InviteCell {
    weak var delegate: InviteTableViewDelegate?
    
    public var addButton: UIButton
    
    
    @objc private func didTapAdd(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
            delegate?.unselect(cellItem: user)
        } else {
            sender.isSelected = true
            user.isInivted = true
            delegate?.select(cellItem: user)
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        addButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel.font = .zipTextNoti
        
        let plus = UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        let check = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
        addButton.setImage(plus, for: .normal)
        addButton.setImage(check, for: .selected)
        addButton.contentVerticalAlignment = .fill
        addButton.contentHorizontalAlignment = .fill
        addButton.imageView?.contentMode = .scaleAspectFill
        
        contentView.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        addButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
        
        addButton.addTarget(self, action: #selector(didTapAdd(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
    }
}
