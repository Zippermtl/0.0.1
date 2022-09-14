//
//  DistanceLabel.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit

class IconLabel: UILabel {
    open override var text: String? {
        didSet {
            labelText = self.text ?? ""
            update(string: labelText)
        }
    }
    
    var spacing: Int = 0 {
        didSet {
            update(string: labelText)
            var spaces = ""
            for _ in 0..<spacing {
                spaces += " "
            }
            labelText = spaces + labelText
        }
    }

    let icon: NSTextAttachment
    private var labelFont: UIFont
    private var color: UIColor
    private var labelText: String
    
    
    enum IconPlacement {
        case left
        case right
    }
    
    var iconPlaceMent: IconPlacement? {
        didSet {
            update(string: labelText)
        }
    }
    
    init(iconImage: UIImage?){
        self.labelFont = .zipSubtitle2
        self.color = .zipBlue
        self.labelText = ""
        
        icon = NSTextAttachment()
        
        super.init(frame: .zero)
        guard let iconImage = iconImage else {
            return
        }

        icon.image = iconImage.withRenderingMode(.alwaysOriginal).withTintColor(self.color)
    }
    
    init(iconImage: UIImage?, labelFont: UIFont, color: UIColor) {
        self.labelFont = labelFont
        self.color = color
        self.labelText = ""
        icon = NSTextAttachment()
        
        super.init(frame: .zero)
        guard let iconImage = iconImage else {
            return
        }

        
        icon.image = iconImage.withRenderingMode(.alwaysOriginal).withTintColor(self.color)
        
        textColor = color
        update(string: labelText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func update(string s: String){
        labelText = ""
        for _ in 0..<spacing {
            labelText += " "
        }
        labelText += s
        let attachmentString = NSAttributedString(attachment: icon)
        let completeString = NSMutableAttributedString(string: "")
        
        if let iconPlaceMent = iconPlaceMent {
            switch iconPlaceMent {
            case .left:
                completeString.append(attachmentString)
                completeString.append(NSAttributedString(string: s, attributes: [NSAttributedString.Key.font: self.labelFont,
                                                                                 NSAttributedString.Key.foregroundColor: self.color]))
            case .right:
                completeString.append(NSAttributedString(string: s, attributes: [NSAttributedString.Key.font: self.labelFont,
                                                                                 NSAttributedString.Key.foregroundColor: self.color]))
                completeString.append(attachmentString)

            }
        } else {
            completeString.append(attachmentString)
            completeString.append(NSAttributedString(string: s, attributes: [NSAttributedString.Key.font: self.labelFont,
                                                                             NSAttributedString.Key.foregroundColor: self.color]))
        }
        
        attributedText = completeString
    }
    
    public func setIcon(newIcon: UIImage?) {
        icon.image = newIcon
    }
    
}
