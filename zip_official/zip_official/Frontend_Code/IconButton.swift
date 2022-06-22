//
//  IconButton.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit

class IconButton: UIButton {

    var iconButton: UIButton
    
    
    
    
    init(text: String, icon: UIImage?, config: UIImage.Configuration) {
        iconButton = UIButton()

        super.init(frame: .zero)
        
        
        
        iconButton.setImage(icon!.withConfiguration(config)
                                 .withRenderingMode(.alwaysOriginal)
                                 .withTintColor(.white),
                            for: .normal)

        
        
        
        iconButton.contentMode = .scaleAspectFit
        
        addSubview(iconButton)
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        iconButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        iconButton.layer.masksToBounds = true
        
        iconButton.backgroundColor = .zipLightGray
        
        let label = UILabel.zipTextIcon()
        label.text = text
        
        label.textAlignment = .center
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        label.topAnchor.constraint(equalTo: iconButton.bottomAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    public func setIconDimension(width: CGFloat) {
        iconButton.translatesAutoresizingMaskIntoConstraints = false
        iconButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        iconButton.heightAnchor.constraint(equalTo: iconButton.widthAnchor).isActive = true
        
        iconButton.layer.cornerRadius = width/2
    }

    
    func iconAddTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        iconButton.addTarget(target, action: action, for: controlEvents)
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
