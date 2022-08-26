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
        
        private var closedButton: UIButton
        private var openButton: UIButton
  
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.closedButton = UIButton()
            self.openButton = UIButton()
            
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .zipGray
            
            closedButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
            openButton.addTarget(self, action: #selector(didTapOpen), for: .touchUpInside)
            
            closedButton.backgroundColor = .zipLightGray

          
            closedButton.layer.masksToBounds = true
            closedButton.layer.cornerRadius = 10
            
            
            closedButton.setTitle("Closed", for: .normal)
            closedButton.titleLabel?.textColor = .white
            closedButton.titleLabel?.font = .zipSubtitle2
            closedButton.titleLabel?.textAlignment = .center
            closedButton.contentVerticalAlignment = .center
            
            openButton.backgroundColor = .zipLightGray
            openButton.layer.masksToBounds = true
            openButton.layer.cornerRadius = 10
            
            openButton.setTitle("Open", for: .normal)
            openButton.titleLabel?.textColor = .white
            openButton.titleLabel?.font = .zipSubtitle2
            openButton.titleLabel?.textAlignment = .center
            openButton.contentVerticalAlignment = .center
            
            addSubviews()
            configureSubviewLayout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
        public func configure(event: Event) {
            switch event.getType() {
            case .Open: openButton.backgroundColor = .zipBlue
            case .Closed: closedButton.backgroundColor = .zipBlue
            default: break
            }
            super.configure(label: "Type")
        }
        
        @objc private func didTapOpen(){
            closedButton.backgroundColor = .zipLightGray
            openButton.backgroundColor = .zipBlue
            closedButton.isSelected = false
            openButton.isSelected = true
        }
        
        @objc private func didTapClose(){
            closedButton.backgroundColor = .zipBlue
            openButton.backgroundColor = .zipLightGray
            closedButton.isSelected = true
            openButton.isSelected = false
        }
      
        private func addSubviews(){
            rightView.addSubview(closedButton)
            rightView.addSubview(openButton)
        }
        
        private func configureSubviewLayout(){
            closedButton.translatesAutoresizingMaskIntoConstraints = false
            closedButton.heightAnchor.constraint(equalTo: rightView.heightAnchor, multiplier: 0.5).isActive = true
            closedButton.centerYAnchor.constraint(equalTo: rightView.centerYAnchor).isActive = true
            closedButton.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            closedButton.widthAnchor.constraint(equalTo: openButton.widthAnchor).isActive = true
            
            openButton.translatesAutoresizingMaskIntoConstraints = false
            openButton.centerYAnchor.constraint(equalTo: closedButton.centerYAnchor).isActive = true
            openButton.leftAnchor.constraint(equalTo: closedButton.rightAnchor,constant: 15).isActive = true
            openButton.rightAnchor.constraint(equalTo: rightView.rightAnchor,constant: -15).isActive = true
        }
    }
}

