//
//  ZipAcceptedTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/15/22.
//

import UIKit

class ZipAcceptedTableViewCell: AbstractUserTableViewCell {
    private let messageButton: UIButton
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        messageButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        extraInfoLabel.font = .zipTextNoti
        
        messageButton.addTarget(self, action: #selector(didTapMessage), for: .touchUpInside)
        messageButton.backgroundColor = .zipBlue
        messageButton.setTitle("Message", for: .normal)
        messageButton.setTitleColor(.white, for: .normal)
        messageButton.titleLabel?.font = .zipTextNoti
        
        contentView.addSubview(messageButton)
        messageButton.translatesAutoresizingMaskIntoConstraints = false
        messageButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        messageButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -30).isActive = true
        messageButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    override func configure(_ user: User) {
        super.configure(user)
        extraInfoLabel.text = "@" + user.username
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapMessage(){
        
    }

}
