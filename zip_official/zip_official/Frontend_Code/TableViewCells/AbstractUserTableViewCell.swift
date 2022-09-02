//
//  AbstractUserTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/1/22.
//

import UIKit

class AbstractUserTableViewCell: UITableViewCell {

    static let identifier = "myZipUser"
    
    var cellHeight = 90
    //MARK: - User Data
    var user: User
    
    var pictureView: UIImageView
    var outlineView: UIView
    var nameLabel: UILabel
    var extraInfoLabel: UILabel
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.user = User()
        self.pictureView = UIImageView()
        self.nameLabel = UILabel.zipSubtitle()
        self.extraInfoLabel = UILabel.zipTextNotiBold()
        self.outlineView = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        pictureView.backgroundColor = .zipLightGray
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    //MARK: - Configure
    public func configure(_ user: User){
        print(user.pictures)
        
        self.user = user
        nameLabel.text = user.fullName
        
        guard let pfp = user.profilePicUrl else {
            return
        }
        pictureView.sd_setImage(with: pfp)
    }
    
    public func configureImage(_ user: User) {
        pictureView.sd_setImage(with: user.profilePicUrl)
    }
    
    //MARK: -Add Subviews
    private func addSubviews(){
        contentView.addSubview(outlineView)
        outlineView.addSubview(pictureView)
        outlineView.addSubview(nameLabel)
        outlineView.addSubview(extraInfoLabel)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
//        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 15
        outlineView.backgroundColor = .zipLightGray
        pictureView.layer.masksToBounds = true
        
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        outlineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        outlineView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true

        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        pictureView.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5).isActive = true
        pictureView.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -5).isActive = true
        pictureView.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true
        pictureView.layer.cornerRadius = CGFloat((cellHeight - 10 - 20)/2) // - 10 for top bottom of profile, -20 for t/b of outline

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: pictureView.rightAnchor, constant: 10).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        extraInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        extraInfoLabel.leftAnchor.constraint(equalTo: nameLabel.leftAnchor).isActive = true
        extraInfoLabel.topAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        

    }
    
    

}
