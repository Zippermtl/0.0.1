//
//  DistanceLabel.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit

class IconLabel: UILabel {
    
    private let icon: NSTextAttachment
    private var labelFont: UIFont
    private var color: UIColor
    
    init(iconImage: UIImage?){
        self.labelFont = .zipBody
        self.color = .zipBlue
        icon = NSTextAttachment()
        icon.image = iconImage?.withRenderingMode(.alwaysOriginal).withTintColor(self.color)
        
        super.init(frame: .zero)
    }
    
    init(iconImage: UIImage?, labelFont: UIFont, color: UIColor) {
        self.labelFont = labelFont
        self.color = color
        icon = NSTextAttachment()

        icon.image = iconImage?.withRenderingMode(.alwaysOriginal).withTintColor(color)

        
        super.init(frame: .zero)
        textColor = color
        update(string: "")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func update(string s: String){
        let attachmentString = NSAttributedString(attachment: icon)
        let completeString = NSMutableAttributedString(string: "")
        completeString.append(attachmentString)
        completeString.append(NSAttributedString(string: s, attributes: [NSAttributedString.Key.font: self.labelFont,
                                                                         NSAttributedString.Key.foregroundColor: self.color]))
        attributedText = completeString
    }
}
