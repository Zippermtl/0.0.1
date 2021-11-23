//
//  ConversationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/6/21.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identifier = "conversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(21)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .zipSubscript.withSize(19)
        label.textColor = .zipLightGray
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseIdentifer: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifer)
        contentView.backgroundColor = .zipGray
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor).isActive = true
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.bottomAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive = true

        userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        userMessageLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 5).isActive = true
        userMessageLabel.leftAnchor.constraint(equalTo: userNameLabel.leftAnchor).isActive = true

    }
    
    
    public func configure(with model: Conversation){
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name

        let path = "images/\(model.otherUserId)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                print("URL = \(url)")
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image URL: \(error)")
            }
            
            
        })
    }
    
    
    
    
    
}
