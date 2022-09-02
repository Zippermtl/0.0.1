//
//  InviteUserToEventViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/7/22.
//

import UIKit

class EventInviteTableViewCell: AbstractEventTableViewCell, InviteCell {
    private let selectButton: UIButton
    weak var delegate: InviteTableViewDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        selectButton = UIButton()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let lightConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .light, scale: .large)
        let boldConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large)
        let plus = UIImage(systemName: "circle", withConfiguration: lightConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        let check = UIImage(systemName: "checkmark.circle.fill",withConfiguration: boldConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
        selectButton.setImage(plus, for: .normal)
        selectButton.setImage(check, for: .selected)
        
        selectButton.addTarget(self, action: #selector(didTapSelect), for: .touchUpInside)
        
        configureSubviewLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureSubviewLayout() {
        contentView.addSubview(selectButton)
        
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        selectButton.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
        selectButton.rightAnchor.constraint(equalTo: participantsLabel.rightAnchor).isActive = true
    }
    
    
    @objc private func didTapSelect(){
        selectButton.isSelected = !selectButton.isSelected

        if selectButton.isSelected {
            delegate?.select(cellItem: event)
        } else {
            delegate?.unselect(cellItem: event)

        }
    }

}
