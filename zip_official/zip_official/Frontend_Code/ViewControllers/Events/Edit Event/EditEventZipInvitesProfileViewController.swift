//
//  EditEventZipInvitesProfileViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/29/22.
//

import Foundation
import UIKit


extension EditEventProfileViewController {
    internal class EditCanInviteZipsTableViewCell: EditProfileTableViewCell {
        
        static let identifier = "editCanInviteCell"
        
        private let allowSwitch: UISwitch
        private var event: Event!
        
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            allowSwitch = UISwitch()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            allowSwitch.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
            addSubviews()
            configureSubviewLayout()
        }
        
        @objc private func didTapSwitch(){
            event.allowUserInvites = allowSwitch.isOn
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func configure(event: Event) {
            self.event = event
            allowSwitch.isOn = event.allowUserInvites
            super.configure(label: "Guests Can Invite Zips")
        }
        
        private func addSubviews(){
            rightView.addSubview(allowSwitch)
        }
        
        private func configureSubviewLayout() {
            allowSwitch.translatesAutoresizingMaskIntoConstraints = false
            allowSwitch.topAnchor.constraint(equalTo: rightView.topAnchor, constant: 5).isActive = true
            allowSwitch.bottomAnchor.constraint(equalTo: rightView.bottomAnchor,constant: -5).isActive = true
            allowSwitch.rightAnchor.constraint(equalTo: rightView.rightAnchor,constant: -10).isActive = true
        }
    }
}
