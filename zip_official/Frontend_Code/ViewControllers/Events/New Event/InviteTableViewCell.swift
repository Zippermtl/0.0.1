//
//  EventInviteTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/28/21.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    static let identifier = "eventInviteCell"
    
    var outlineView = UIView()
    var profilePicture = UIImageView()
    var checkMark: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "redX"), for: .normal)
        btn.setImage(UIImage(named: "accept"), for: .selected)
        return btn
    }()
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .zipBody
        label.textColor = .white
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    public func configure(with user: User){
        contentView.backgroundColor = .zipGray
        
        nameLabel.text = user.name
        if user.pictures.count != 0 {
            profilePicture.image = user.pictures[0]
        } else {
            print("THIS PERSON HAS NO PROFILE PICTURE")
        }
        
        configureOutlineView()
        addSubviews()
        
    }
    
    private func configureOutlineView(){
        outlineView.backgroundColor = .zipLightGray
        outlineView.frame = CGRect(x: 5, y: 5, width: contentView.frame.width-10, height: contentView.frame.height-10)
        outlineView.layer.cornerRadius = 15
    }
    
    private func addSubviews(){
        contentView.addSubview(outlineView)
        outlineView.addSubview(profilePicture)
        outlineView.addSubview(nameLabel)
        outlineView.addSubview(checkMark)
    }
    
    
    override func layoutSubviews(){
        super.layoutSubviews()
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        profilePicture.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profilePicture.rightAnchor, constant: 5).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: checkMark.leftAnchor).isActive = true
        
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        checkMark.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -5).isActive = true
        checkMark.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true

    }
    
}
