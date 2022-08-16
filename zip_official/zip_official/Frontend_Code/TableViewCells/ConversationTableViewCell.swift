//
//  ConversationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/6/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: AbstractUserTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    public func configure(with model: Conversation){
        extraInfoLabel.text = model.latestMessage.text
        super.configure(model.otherUser)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

    
    
    

