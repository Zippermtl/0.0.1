//
//  EventTypeTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//
import UIKit


protocol EventTypeCellDelegate: AnyObject {
    func isOpen()
    func isClosed()

}

extension EditEventProfileViewController {
    
    
    internal class EditEventTypeTableViewCell: EditProfileTableViewCell {
        static let identifier = "eventType"
        
        private let OCDescriptionText: (String,String,String) = (
            "Open events are visible on the map by people who are invited or going. They are also visible on the event finder page and can be searched for." ,
            "Closed events are visibile on the map by people who are invited. They CANNOT be found on the event finder page or the search bar unless they are invited",
            "Select a privacy setting to continue"
        )
        
        private var closedButton: UIButton
        private var openButton: UIButton
        private let descriptionLabel: UILabel
        
        weak var delegate: EventTypeCellDelegate?
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            self.closedButton = UIButton()
            self.openButton = UIButton()
            self.descriptionLabel = .zipTextDetail()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            contentView.backgroundColor = .zipGray
            descriptionLabel.text = OCDescriptionText.0
            descriptionLabel.textColor = .zipVeryLightGray
            descriptionLabel.textAlignment = .center
            descriptionLabel.numberOfLines = 0
            descriptionLabel.lineBreakMode = .byWordWrapping
            
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
            case .Open:
                openButton.backgroundColor = .zipBlue
                descriptionLabel.text = OCDescriptionText.0
            case .Closed:
                closedButton.backgroundColor = .zipBlue
                descriptionLabel.text = OCDescriptionText.1
            default: break
            }
            super.configure(label: "Privacy")
        }
        
        @objc private func didTapOpen(){
            closedButton.backgroundColor = .zipLightGray
            openButton.backgroundColor = .zipBlue
            descriptionLabel.text = OCDescriptionText.0
            closedButton.isSelected = false
            openButton.isSelected = true
            delegate?.isOpen()
        }
        
        @objc private func didTapClose(){
            closedButton.backgroundColor = .zipBlue
            openButton.backgroundColor = .zipLightGray
            descriptionLabel.text = OCDescriptionText.1
            closedButton.isSelected = true
            openButton.isSelected = false
            delegate?.isClosed()
        }
      
        private func addSubviews(){
            rightView.addSubview(closedButton)
            rightView.addSubview(openButton)
            rightView.addSubview(descriptionLabel)
        }
        
        private func configureSubviewLayout(){
            closedButton.translatesAutoresizingMaskIntoConstraints = false
            closedButton.heightAnchor.constraint(equalTo: titleLabel.heightAnchor).isActive = true
            closedButton.topAnchor.constraint(equalTo: rightView.topAnchor,constant: 5).isActive = true
            closedButton.leftAnchor.constraint(equalTo: rightView.leftAnchor).isActive = true
            closedButton.widthAnchor.constraint(equalTo: openButton.widthAnchor).isActive = true
            
            openButton.translatesAutoresizingMaskIntoConstraints = false
            openButton.centerYAnchor.constraint(equalTo: closedButton.centerYAnchor).isActive = true
            openButton.leftAnchor.constraint(equalTo: closedButton.rightAnchor,constant: 15).isActive = true
            openButton.rightAnchor.constraint(equalTo: rightView.rightAnchor,constant: -15).isActive = true
            
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.leftAnchor.constraint(equalTo: closedButton.leftAnchor).isActive = true
            descriptionLabel.rightAnchor.constraint(equalTo: openButton.rightAnchor).isActive = true
            descriptionLabel.topAnchor.constraint(equalTo: closedButton.bottomAnchor,constant: 5).isActive = true
            descriptionLabel.bottomAnchor.constraint(equalTo: rightView.bottomAnchor,constant: -5).isActive = true
        }
    }
}

