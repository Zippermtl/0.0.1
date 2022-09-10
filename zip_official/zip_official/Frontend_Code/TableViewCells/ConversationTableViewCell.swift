//
//  ConversationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/6/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: AbstractUserTableViewCell {
    private let timeStampLabel : UILabel
    private let readIcon : UIView
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        timeStampLabel = UILabel.zipTextNoti()
        readIcon = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        outlineView.backgroundColor = .zipGray
        
        timeStampLabel.textColor = .zipVeryLightGray
        
        outlineView.addSubview(timeStampLabel)
        timeStampLabel.translatesAutoresizingMaskIntoConstraints = false
        timeStampLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        timeStampLabel.rightAnchor.constraint(equalTo: outlineView.rightAnchor,constant: -10).isActive = true
        
        outlineView.addSubview(readIcon)
        readIcon.translatesAutoresizingMaskIntoConstraints = false
//        readIcon.topAnchor.constraint(equalTo: timeStampLabel.bottomAnchor,constant: 8).isActive = true
//        readIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -24).isActive = true
        readIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
        readIcon.widthAnchor.constraint(equalTo: readIcon.heightAnchor).isActive = true
        readIcon.centerYAnchor.constraint(equalTo: extraInfoLabel.centerYAnchor).isActive = true
        readIcon.rightAnchor.constraint(equalTo: timeStampLabel.rightAnchor).isActive = true
        readIcon.layer.masksToBounds = true

        readIcon.layer.cornerRadius = 6
        
        extraInfoLabel.numberOfLines = 2
        extraInfoLabel.lineBreakMode = .byWordWrapping
        extraInfoLabel.rightAnchor.constraint(equalTo: readIcon.leftAnchor,constant: -5).isActive = true
        extraInfoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    public func configure(with model: Conversation){
        if model.latestMessage.isRead {
            readIcon.backgroundColor = .clear
        } else {
            readIcon.backgroundColor = .zipBlue
        }
        
        let formatter = DateFormatter()
        let messageDate = model.latestMessage.date
        
        if Calendar.current.isDateInToday(messageDate) {
            formatter.dateFormat = "h:mm a"
        } else if messageDate.isInSameYear(as: Date()) {
            if messageDate.isInSameWeek(as: Date()) {
                formatter.dateFormat = "EEEE"
            } else {
                formatter.dateFormat = "M/dd"
            }
        } else {
            formatter.dateFormat = "yyyy-MM-dd"
        }
        timeStampLabel.text = formatter.string(from: messageDate)
        
        if Calendar.current.isDateInYesterday(messageDate) {
            timeStampLabel.text = "Yesterday"
        }
        
        extraInfoLabel.text = model.latestMessage.text
        extraInfoLabel.textColor = .zipVeryLightGray
        super.configure(model.otherUser)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func markAsRead(){
        readIcon.backgroundColor = .clear
    }
    
    
}

    
    
    

