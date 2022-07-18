//
//  FPCEventTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/1/22.
//

import UIKit

class FPCEventTableViewCell: AbstractEventTableViewCell {
    static let identifier = "fpc"
    
    private let acceptButton: UIButton
    private let rejectButton: UIButton
    weak var delegate: UpdateZipRequestsTableDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        acceptButton = UIButton()
        rejectButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let goingIcon = UIImage(systemName: "checkmark.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipYellow)
        acceptButton.setImage(goingIcon, for: .normal)
        
 
        let interestedIcon = UIImage(systemName: "xmark.circle.fill", withConfiguration: largeConfig)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.zipVeryLightGray)
        rejectButton.setImage(interestedIcon, for: .normal)
        
        acceptButton.addTarget(self, action: #selector(didTapAcceptButton), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(didTapRejectButton), for: .touchUpInside)
        
        configureSubviewLayout()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviewLayout() {
        contentView.addSubview(acceptButton)
        contentView.addSubview(rejectButton)
        
        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        acceptButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
        
        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.bottomAnchor.constraint(equalTo: acceptButton.bottomAnchor).isActive = true
        rejectButton.rightAnchor.constraint(equalTo: acceptButton.leftAnchor, constant: -10).isActive = true
    }
    
    
    @objc private func didTapRejectButton(){
        delegate?.deleteEventsRow(rejectButton)
    }
    
    @objc private func didTapAcceptButton() {
        delegate?.deleteEventsRow(acceptButton)
    }

}
