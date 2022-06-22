//
//  EventInviteTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/28/21.
//

import UIKit

protocol InviteTableViewCellDelegate: AnyObject {
    func inviteUser(user: User)
    func uninviteUser(user: User)
}

class InviteTableViewCell: UITableViewCell {
    static let identifier = "eventInviteCell"
    var user = User()

    var outlineView = UIView()
    var pictureView = UIImageView()
    
    weak var delegate: InviteTableViewCellDelegate?
    
    public var addButton: UIButton = {
        let btn = UIButton()
//        btn.backgroundColor = .white
        let plus = UIImage(systemName: "plus.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipVeryLightGray)
        let check = UIImage(systemName: "checkmark.circle.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
        btn.setImage(plus, for: .normal)
        btn.setImage(check, for: .selected)
        btn.contentVerticalAlignment = .fill
        btn.contentHorizontalAlignment = .fill
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(18)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .left
        label.sizeToFit()
        label.text = "A"
        return label
    }()
    
    
    @objc private func didTapAdd(_ sender: UIButton){
        if sender.isSelected {
            sender.isSelected = false
            delegate?.uninviteUser(user: user)
        } else {
            sender.isSelected = true
            user.isInivted = true
            delegate?.inviteUser(user: user)

        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    public func configure(_ user: User){
        contentView.backgroundColor = .zipGray
        self.user = user

        
        configureOutlineView()
        configureLabels()
        addSubviews()
        configureSubviewLayout()
        
    }
    
    private func configureLabels(){
        nameLabel.text = user.fullName
        
        if user.pictures.count != 0 {
            pictureView.image = user.pictures[0]
        } else {
            print("THIS PERSON HAS NO PROFILE PICTURE")
        }
        
        addButton.addTarget(self, action: #selector(didTapAdd(_:)), for: .touchUpInside)        
    }
    
    private func configureOutlineView(){
        contentView.addSubview(outlineView)
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        outlineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        outlineView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true

        
//        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 10
        outlineView.layer.masksToBounds = true
        outlineView.backgroundColor = .zipLightGray
        
        
    }
    
    private func addSubviews(){
        outlineView.addSubview(pictureView)
        outlineView.addSubview(nameLabel)
        outlineView.addSubview(addButton)
    }
    
    private func configureSubviewLayout(){
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        pictureView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -5).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true
        
        pictureView.layer.cornerRadius = 30 //(80 - 10 - 10) / 2
        pictureView.layer.masksToBounds = true

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: 15).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        addButton.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        addButton.widthAnchor.constraint(equalTo: addButton.heightAnchor).isActive = true        
    }

}
