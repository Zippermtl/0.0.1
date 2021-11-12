//
//  ZipRequestTableViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/18/21.
//

import UIKit

class ZipRequestTableViewCell: UITableViewCell {
    static let identifier = "ZipRequest"

    let cellImage = UIImageView()
    
    let textView = UIView()
    
    let cellText: UILabel = {
        let label = UILabel()
        label.font = .zipBodyBold.withSize(16)
        label.textColor = .white
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = .zipSubscript.withSize(14)
        label.textColor = .zipVeryLightGray
    
        return label
    }()
    
    let acceptButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named:"accept"), for: .normal)
        return btn
    }()
    
    let rejectButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named:"redX"), for: .normal)
        return btn
    }()
    
    let outlineView = UIView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        selectionStyle = .none
        // Configure the view for the selected state
    }
    
    public func configure(with notification: ZipNotification){
        contentView.backgroundColor = .zipGray
        contentView.addSubview(outlineView)
        outlineView.translatesAutoresizingMaskIntoConstraints = false
        outlineView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        outlineView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        outlineView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        outlineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

        outlineView.backgroundColor = .zipLightGray

        outlineView.layer.cornerRadius = 15
    
        cellImage.image = notification.image
        cellText.text = "Yianni Zavaliagkos Zipped you!"
        
        if notification.time < 60 {
            timeLabel.text = Int(notification.time).description + "s ago"
        } else if notification.time < 3600 {
            timeLabel.text = Int(notification.time/60).description + "m ago"
        } else if notification.time < 3600 {
            timeLabel.text = Int(notification.time/3600).description + "h ago"
        } else {
            timeLabel.text = Int(notification.time/86400).description + "d ago"
        }
        
        configureLayout()
        
    }
    
    private func configureLayout(){
        
        outlineView.addSubview(cellImage)
        
        outlineView.addSubview(textView)
        textView.addSubview(cellText)
        textView.addSubview(timeLabel)
        
        outlineView.addSubview(acceptButton)
        outlineView.addSubview(rejectButton)

        
        cellImage.translatesAutoresizingMaskIntoConstraints = false
        cellImage.leftAnchor.constraint(equalTo: outlineView.leftAnchor, constant: 5).isActive = true
        cellImage.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        cellImage.heightAnchor.constraint(equalTo: outlineView.heightAnchor, multiplier: 0.8).isActive = true
        cellImage.widthAnchor.constraint(equalTo: cellImage.heightAnchor).isActive = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leftAnchor.constraint(equalTo: cellImage.rightAnchor, constant: 5).isActive = true
        textView.rightAnchor.constraint(equalTo: rejectButton.leftAnchor, constant: -5).isActive = true
        textView.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: cellText.topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor).isActive = true
                
        cellText.translatesAutoresizingMaskIntoConstraints = false
        cellText.leftAnchor.constraint(equalTo: textView.leftAnchor).isActive = true
        cellText.rightAnchor.constraint(equalTo: textView.rightAnchor).isActive = true
        cellText.topAnchor.constraint(equalTo: textView.topAnchor).isActive = true
        

        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.leftAnchor.constraint(equalTo: textView.leftAnchor).isActive = true
        timeLabel.rightAnchor.constraint(equalTo: textView.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: cellText.bottomAnchor).isActive = true

        acceptButton.translatesAutoresizingMaskIntoConstraints = false
        acceptButton.rightAnchor.constraint(equalTo: outlineView.rightAnchor, constant: -10).isActive = true
        acceptButton.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        acceptButton.heightAnchor.constraint(equalTo: outlineView.heightAnchor, multiplier: 0.7).isActive = true
        acceptButton.widthAnchor.constraint(equalTo: acceptButton.heightAnchor).isActive = true

        rejectButton.translatesAutoresizingMaskIntoConstraints = false
        rejectButton.rightAnchor.constraint(equalTo: acceptButton.leftAnchor).isActive = true
        rejectButton.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor).isActive = true
        rejectButton.heightAnchor.constraint(equalTo: acceptButton.heightAnchor).isActive = true
        rejectButton.widthAnchor.constraint(equalTo: acceptButton.widthAnchor).isActive = true

        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}


