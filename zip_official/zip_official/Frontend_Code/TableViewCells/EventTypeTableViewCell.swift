//
//  EventTypeCollectionViewCell.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/23/22.
//

import UIKit

class EventTypeTableViewCell: UITableViewCell {
    let typeLabel: UILabel
    let bulletPointsLabel: UILabel
    let bgView: UIView
    let iconView: UIImageView
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.typeLabel = UILabel.zipTitle()
        self.bulletPointsLabel = UILabel.zipSubtitle()
        self.bgView = UIView()
        self.iconView = UIImageView()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .zipGray
        
        contentView.addSubview(bgView)
        bgView.addSubview(typeLabel)
        bgView.addSubview(bulletPointsLabel)
        bgView.addSubview(iconView)
        
        bgView.translatesAutoresizingMaskIntoConstraints = false
        bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true

        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        typeLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 10).isActive = true
        typeLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true

        bulletPointsLabel.translatesAutoresizingMaskIntoConstraints = false
        bulletPointsLabel.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10).isActive = true
        bulletPointsLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10).isActive = true
        bulletPointsLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true

        bulletPointsLabel.numberOfLines = 0
        bulletPointsLabel.lineBreakMode = .byWordWrapping
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: typeLabel.topAnchor).isActive = true
        iconView.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10).isActive = true
        
        bgView.layer.masksToBounds = true
        bgView.layer.cornerRadius = 10

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func configure(type: EventType, bulletPoints: (String,String), color: UIColor, icon: UIImage) {
        typeLabel.text = type.description
        bulletPointsLabel.text = "\(bulletPoints.0)\n\n\(bulletPoints.1)"
        
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [color.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: 500, height:  170)
        
        iconView.image = icon.withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .bold, scale: .large))
        bgView.layer.insertSublayer(gradient, at: 0)
        
    }
    
    
    
    
    
    
    
}
