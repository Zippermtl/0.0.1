//
//  DistanceLabel.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit

class DistanceLabel: UILabel {
    
    private let distanceImage: NSTextAttachment
   
    init(){
        distanceImage = NSTextAttachment()
//        distanceImage.image = UIImage(named: "distanceToWhite")?.withTintColor(.zipBlue)
        distanceImage.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)
        super.init(frame: .zero)
    }
    
    init(distance: Double) {
        distanceImage = NSTextAttachment()
//        distanceImage.image = UIImage(named: "distanceToWhite")?.withTintColor(.zipBlue)
        distanceImage.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)

        super.init(frame: .zero)
        textColor = .zipBlue
        update(distance: distance)
    }
    
    required init?(coder: NSCoder) {
        distanceImage = NSTextAttachment()
//        distanceImage.image = UIImage(named: "distanceToWhite")?.withTintColor(.zipBlue)
        distanceImage.image = UIImage(systemName: "mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipBlue)

        super.init(coder: coder)
        textColor = .zipBlue
    }
    
    
    public func update(distance d: Double){
        var distanceText = ""
        var unit = "km"
        var distance = Double(round(10*(d)/1000))/10

        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
        }
        
        if distance > 10 {
            let intDistance = Int(distance)
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
            } else {
                distanceText = String(intDistance) + " \(unit)"
            }
        } else {
            if distance <= 1 {
                if unit == "miles" {
                    unit = "mile"
                }
                distanceText = "<1 \(unit)"
            } else if distance >= 500 {
                distanceText = ">500 \(unit)"
            } else {
                distanceText = String(distance) + " \(unit)"
            }
        }
        
        let attachmentString = NSAttributedString(attachment: distanceImage)
        let completeString = NSMutableAttributedString(string: "")
        completeString.append(attachmentString)
        completeString.append(NSAttributedString(string: distanceText, attributes: [NSAttributedString.Key.font: UIFont.zipBody,
                                                                                    NSAttributedString.Key.foregroundColor: UIColor.zipBlue]))
        attributedText = completeString
    }
}
