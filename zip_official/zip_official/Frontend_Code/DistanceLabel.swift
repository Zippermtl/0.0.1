//
//  DistanceLabel.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit
import CoreLocation

class DistanceLabel: IconLabel {
    init(){
        super.init(iconImage: UIImage(systemName: "mappin"))
    }
    
    init(labelFont: UIFont, color: UIColor, config: UIImage.Configuration){
        super.init(iconImage: UIImage(systemName: "mappin")?.withConfiguration(config), labelFont: labelFont, color: color)
        textColor = color
    }
    
    init(distance: Double, labelFont: UIFont = .zipBody, color: UIColor = .zipBlue) {
  
        super.init(iconImage: UIImage(systemName: "mappin"), labelFont: labelFont, color: color)
        textColor = color
        update(distance: distance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        update(string: distanceText)
    }
    
    public func update(location: CLLocation) {
        guard let coordinates = UserDefaults.standard.object(forKey: "userLoc") as? [Double] else {
            return
        }
        let userLoc = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        
        update(distance: userLoc.distance(from: location))
    }
}
