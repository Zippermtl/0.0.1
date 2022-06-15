//
//  IconButton.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit

class IconButton: UIButton {

    var iconView: UIImageView?
    var iconBG: UIView
    
    init(text: String, icon: UIImage?, config: UIImage.Configuration) {
        iconBG = UIView()

        super.init(frame: .zero)
        
        
        iconView = UIImageView(image: icon!
                                .withConfiguration(config)
                                .withRenderingMode(.alwaysOriginal)
                                .withTintColor(.white))

        
        iconView?.isExclusiveTouch = false
        iconView?.isUserInteractionEnabled = false
        iconView?.contentMode = .scaleAspectFit
        
        
        iconBG.backgroundColor = .zipLightGray
        addSubview(iconBG)
        iconBG.translatesAutoresizingMaskIntoConstraints = false
        iconBG.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconBG.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconBG.layer.masksToBounds = true
        
        iconBG.addSubview(iconView!)
        iconView?.translatesAutoresizingMaskIntoConstraints = false
        iconView?.centerXAnchor.constraint(equalTo: iconBG.centerXAnchor).isActive = true
        iconView?.centerYAnchor.constraint(equalTo: iconBG.centerYAnchor).isActive = true
        iconView?.layer.masksToBounds = true
        
        let label = UILabel.zipTextIcon()
        label.text = text
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: iconBG.bottomAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public func setIconDimension(width: CGFloat) {
        iconBG.translatesAutoresizingMaskIntoConstraints = false
        iconBG.widthAnchor.constraint(equalToConstant: width).isActive = true
        iconBG.heightAnchor.constraint(equalTo: iconBG.widthAnchor).isActive = true
        
        iconBG.layer.cornerRadius = width/2

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    static func eventsIcon() -> IconButton {
        return IconButton(
            text: "Events",
            icon:  UIImage(systemName: "calendar")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
            config: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        )
    }
    
    static func zipsIcon() -> IconButton {
        return IconButton(
            text: "Zips",
            icon:  UIImage(systemName: "person.3.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
            config: UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        )
    }
    
    static func inviteIcon() -> IconButton {
        return IconButton(
            text: "Invite",
            icon:  UIImage(systemName: "paperplane")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
            config: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        )
    }
    
    static func messageIcon() -> IconButton {
        return IconButton(
            text: "Message",
            icon:  UIImage(systemName: "message")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
            config: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        )
    }
    
    static func myCardIcon() -> IconButton {
        return IconButton(
            text: "My Card",
            icon:  UIImage(systemName: "lanyardcard.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(.white),
            config: UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        )
    }
        
}
