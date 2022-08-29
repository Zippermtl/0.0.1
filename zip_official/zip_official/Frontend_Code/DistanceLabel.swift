//
//  DistanceLabel.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/14/22.
//

import UIKit
import CoreLocation

class DistanceLabel: IconLabel {
    var min: Double = 1.0 { didSet {
        update(distance: distance)
    }}
    
    var max: Double = 500.0 { didSet {
        update(distance: distance)
    }}
    
    var distance: Double = 0.0
    
    init(){
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        let pin = UIImage(named: "zip.mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white).withConfiguration(pinConfig)
        super.init(iconImage: pin)
    }
    
    init(labelFont: UIFont, color: UIColor, config: UIImage.Configuration){
        let pin = UIImage(named: "zip.mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
        super.init(iconImage: pin?.withConfiguration(config), labelFont: labelFont, color: color)
        textColor = color
    }
    
    init(distance: Double, labelFont: UIFont = .zipTextFillBold, color: UIColor = .zipBlue) {
        let pinConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .regular, scale: .large)
        let pin = UIImage(named: "zip.mappin")?.withRenderingMode(.alwaysOriginal).withTintColor(.white).withConfiguration(pinConfig)
        super.init(iconImage: pin, labelFont: labelFont, color: color)
        textColor = color
        update(distance: distance)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func update(distance d: Double){
        var distanceText = ""
        var unit = "km"
        distance = Double(round(10*(d)/1000))/10

        if NSLocale.current.regionCode == "US" {
            distance = round(10*distance/1.6)/10
            unit = "miles"
            
            if distance == 1 {
                unit = "mile"
            }
        }
            
        if distance < min {
            distanceText = "<\(Int(min)) \(unit)"
        } else if distance > max{
            distanceText = ">\(Int(max)) \(unit)"
        } else {
            if distance > 10 {
                distanceText = String(Int(distance)) + " \(unit)"
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
