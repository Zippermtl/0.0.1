//
//  ConversationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/6/21.
//

import UIKit
import SDWebImage

class NewConversationTableViewCell: AbstractUserTableViewCell {
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func configure(_ user: User) {
        super.configure(user)
        StorageManager.shared.getProfilePicture(path: "images/\(user.userId)", completion: { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let url):
                user.setProfilePicUrl(url: url)
                strongSelf.configureImage(user)
            case .failure(_):
                strongSelf.pictureView.image = UIImage(named: "defaultProfilePic")
            }

            
        })
    }
    
    
    
    
    
}
