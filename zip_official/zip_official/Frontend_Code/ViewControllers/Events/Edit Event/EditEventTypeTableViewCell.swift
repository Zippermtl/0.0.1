//
//  EventTypeTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit
extension EditEventProfileViewController {
    
    internal class EditEventTypeTableViewCell: EditProfileTableViewCell {
        static let identifier = "eventType"
        
        private var privateButton: UIButton
        private var publicButton: UIButton
  
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.privateButton = UIButton()
            self.publicButton = UIButton()
            
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .zipGray
            
            
            
            privateButton.addTarget(self, action: #selector(didTapPrivateButton), for: .touchUpInside)
            publicButton.addTarget(self, action: #selector(didTapPublicButton), for: .touchUpInside)
            
            privateButton.layer.borderWidth = 3
            privateButton.layer.borderColor = UIColor.zipBlue.cgColor
            privateButton.layer.masksToBounds = true
            privateButton.layer.cornerRadius = 10
            
            
            privateButton.setTitle("Private", for: .normal)
            privateButton.titleLabel?.textColor = .white
            privateButton.titleLabel?.font = .zipSubtitle2
            privateButton.titleLabel?.textAlignment = .center
            privateButton.contentVerticalAlignment = .center
            
            publicButton.layer.borderWidth = 3
            publicButton.layer.borderColor = UIColor.zipGreen.cgColor
            publicButton.layer.masksToBounds = true
            publicButton.layer.cornerRadius = 10
            
            publicButton.setTitle("Public", for: .normal)
            publicButton.titleLabel?.textColor = .white
            publicButton.titleLabel?.font = .zipSubtitle2
            publicButton.titleLabel?.textAlignment = .center
            publicButton.contentVerticalAlignment = .center
            
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        public func configure(event: Event) {
            switch event.getType() {
            case .Public: publicButton.backgroundColor = .zipGreen
            case .Private: privateButton.backgroundColor = .zipBlue
            default: break
            }
            super.configure(label: "Type")
        }
        
        @objc private func didTapPrivateButton(){
            privateButton.backgroundColor = .zipBlue
            publicButton.backgroundColor = .zipGray
        }
        
        @objc private func didTapPublicButton(){
            privateButton.backgroundColor = .zipGray
            publicButton.backgroundColor = .zipGreen
        }
      
        private func addSubviews(){
            rightView.addSubview(privateButton)
            rightView.addSubview(publicButton)
        }
        
        private func configureSubviewLayout(){
            privateButton.translatesAutoresizingMaskIntoConstraints = false
            privateButton.heightAnchor.constraint(equalTo: rightView.heightAnchor, multiplier: 0.5).isActive = true
            privateButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            privateButton.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            privateButton.widthAnchor.constraint(equalTo: publicButton.widthAnchor).isActive = true
            
            publicButton.translatesAutoresizingMaskIntoConstraints = false
            publicButton.centerYAnchor.constraint(equalTo: privateButton.centerYAnchor).isActive = true
            publicButton.leftAnchor.constraint(equalTo: privateButton.rightAnchor,constant: 15).isActive = true
            publicButton.rightAnchor.constraint(equalTo: rightView.rightAnchor,constant: -15).isActive = true
        }
    }
}

