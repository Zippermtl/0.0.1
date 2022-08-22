//
//  EventNotificationTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/15/22.
//

import UIKit

class EventNotificationTableViewCell: UITableViewCell {
    static let identifier = "eventNotificationCell"
    
    //MARK: - User Data
    private var pictureView: UIImageView
    private var outlineView: UIView
    private var titleLabel: UILabel
    private var timeLabel: UILabel
    private var eventBorder: UIView
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.pictureView = UIImageView()
        self.titleLabel = UILabel.zipTextNotiBold()
        self.timeLabel = UILabel.zipTextDetail()
        self.outlineView = UIView()
        self.eventBorder = UIView()
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        pictureView.backgroundColor = .zipLightGray
        pictureView.contentMode = .scaleAspectFit
        pictureView.layer.masksToBounds = true
        
        eventBorder.layer.borderWidth = 6
        eventBorder.backgroundColor = .clear
        eventBorder.layer.masksToBounds = true
        
        addSubviews()
        configureSubviewLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapOpen(){
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        pictureView.layer.cornerRadius = pictureView.frame.width/2
        eventBorder.layer.cornerRadius = eventBorder.frame.width/2
    }
    
    //MARK: - Configure
    public func configure(event: Event){
        
        eventBorder.layer.borderColor = event.getType().color.cgColor
        guard let url = event.imageUrl else {
            let imageName = event.getType() == .Promoter ? "defaultPromoterEventProfilePic" : "defaultEventProfilePic"
            pictureView.image = UIImage(named: imageName)
            return
        }
        pictureView.sd_setImage(with: url)
    }
    
    //MARK: -Add Subviews
    private func addSubviews(){
        contentView.addSubview(outlineView)
        outlineView.addSubview(eventBorder)
        outlineView.addSubview(pictureView)
        outlineView.addSubview(titleLabel)
        outlineView.addSubview(timeLabel)
    }

    //MARK: - Layout Subviews
    private func configureSubviewLayout(){
//        outlineView.frame = CGRect(x: 10, y: 10, width: contentView.frame.width-20, height: contentView.frame.height-20)
        outlineView.layer.cornerRadius = 15
        outlineView.backgroundColor = .zipLightGray
        
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        outlineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        outlineView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10).isActive = true

        eventBorder.translatesAutoresizingMaskIntoConstraints = false
        eventBorder.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 10).isActive = true
        eventBorder.topAnchor.constraint(equalTo: outlineView.topAnchor, constant: 5).isActive = true
        eventBorder.bottomAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: -5).isActive = true
        eventBorder.widthAnchor.constraint(equalTo: pictureView.heightAnchor).isActive = true
        
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        pictureView.centerYAnchor.constraint(equalTo: eventBorder.centerYAnchor).isActive = true
        pictureView.centerXAnchor.constraint(equalTo: eventBorder.centerXAnchor).isActive = true
        pictureView.widthAnchor.constraint(equalTo: eventBorder.widthAnchor, constant: -10).isActive = true
        pictureView.heightAnchor.constraint(equalTo: pictureView.widthAnchor).isActive = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leftAnchor.constraint(equalTo: eventBorder.rightAnchor, constant: 10).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        

    }
    
    


}
