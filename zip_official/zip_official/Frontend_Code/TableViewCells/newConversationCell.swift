//
//  ConversationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/6/21.
//

import UIKit
import SDWebImage

class NewConversationTableViewCell: UITableViewCell {
    static let identifier = "NewConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody.withSize(21)
        label.textColor = .white
        return label
    }()

    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier reuseIdentifer: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifer)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        
        backgroundColor = .zipGray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        userImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        userImageView.widthAnchor.constraint(equalTo: userImageView.heightAnchor).isActive = true
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.centerYAnchor.constraint(equalTo: userImageView.centerYAnchor).isActive = true
        userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10).isActive = true

        
    }
    
    
    public func configure(with model: SearchResult){
        userNameLabel.text = model.name

        let path = "images/\(model.id)/profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image URL: \(error)")
            }
            
            
        })
    }
    
    
    
    
    
}
