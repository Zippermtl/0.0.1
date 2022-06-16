//
//  AppConstants.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import Foundation
import UIKit
import DropDown
import RSKImageCropper

extension UIColor {
    
    static var zipBlue: UIColor{
//        return UIColor(red: 7/255, green: 185/255, blue: 224/255, alpha: 1)
        
        
//        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
        return UIColor(red: 99/255, green: 189/255, blue: 218/255, alpha: 1)

    }
    
    static let zipLogoBlue = UIColor(red: 99/255, green: 189/255, blue: 218/255, alpha: 1)
    
    
    static var zipGreen: UIColor{
//        return UIColor(red: 154/255, green: 219/255, blue: 131/255, alpha: 1)
        return UIColor(red: 142/255, green: 221/255, blue: 114/255, alpha: 1)
    }
    static var zipPink: UIColor{
//        return UIColor(red: 233/255, green: 163/255, blue: 226/255, alpha: 1)
        return UIColor(red: 229/255, green: 142/255, blue: 221/255, alpha: 1)
    }
    static var zipYellow: UIColor{
//        return UIColor(red: 7/255, green: 185/255, blue: 224/255, alpha: 1)
//        return UIColor(red: 223/255, green: 225/255, blue: 125/255, alpha: 1)
        return UIColor(red: 237/255, green: 232/255, blue: 119/255, alpha: 1)

    }
    static var zipRed: UIColor{
//        return UIColor(red: 240/255, green: 114/255, blue: 114/255, alpha: 1)
        return UIColor(red: 225/255, green: 84/255, blue: 84/255, alpha: 1)
    }
    
    static var zipGray: UIColor{
//        let value = CGFloat(50)
//        let value = CGFloat(43)
        let value = CGFloat(36)

        return UIColor(red: value/255, green: value/255, blue: value/255, alpha: 1)

    }
    
    static var zipDarkGray: UIColor{
        return UIColor(red: 30/255, green: 30/255, blue: 30/255, alpha: 1)
    }
    
    static var zipLightGray: UIColor{
    //        let value = CGFloat(85)
        let value = CGFloat(50)

        return UIColor(red: value/255, green: value/255, blue: value/255, alpha: 1)
    }
    
    static var zipMidGray: UIColor{
//        let value = CGFloat(65)
        let value = CGFloat(53)

        return UIColor(red: value/255, green: value/255, blue: value/255, alpha: 1)    }
    
    static var zipVeryLightGray: UIColor{
        return UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
    }
    
    static var zipInnerCircleBlue: UIColor{
        return UIColor(red: 35/255, green: 207/255, blue: 244/255, alpha: 1)
    }
    
    static var zipButtonBlue: UIColor{
        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
    }
    
    static var zipSeparator: UIColor {
        return UIColor(red: 70/255, green: 70/255, blue: 70/255, alpha: 1)
    }
    
    static var zipEventYellow: UIColor {
        return UIColor(red: 223/255, green: 225/255, blue: 125/255, alpha: 1)
    }
    
    static var zipEventBlue: UIColor {
        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
    }
    
    static var zipMyZipsBlue: UIColor {
        return UIColor(red: 106/255, green: 205/255, blue: 237/255, alpha: 1)
    }
    
    static var zipMyEventsYellow: UIColor {
        return UIColor(red: 210/255, green: 207/255, blue: 133/255, alpha: 1)
    }
    
}

extension UIFont {
    static var zipTitle: UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 30)!
    }
    static var zipBody: UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: 18)!
    }
    static var zipBodyBold: UIFont {
        return UIFont(name: "HelveticaNeue-Bold", size: 18)!
    }
    static var zipSubscript: UIFont {
        return UIFont(name: "HelveticaNeue-Medium", size: 15)!
    }
    static var zipTextDetail: UIFont {
        return .zipBody.withSize(12)
    }
}

extension DropDown {
    func setEdgeInsets(){
        let fontAttribute = [NSAttributedString.Key.font: textFont]
        var greatest: CGFloat = 0
        var xOffset: CGFloat = 0
        for title in dataSource {
            xOffset = (title as NSString).size(withAttributes: fontAttribute).width
            if xOffset > greatest {
                greatest = xOffset
            }
        }
        bottomOffset = CGPoint(x: -xOffset, y: 40)
    }
}



extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
}

extension UILabel {
    
    static func zipSubtitle() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold.withSize(18)
//        label.numberOfLines = 1
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.5
        label.sizeToFit()
        label.text = "A"

        return label
    }
    
    static func zipHeader() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(24)
        label.sizeToFit()
        label.text = "@"
        return label
    }
    
    static func zipTitle() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(28)
        label.sizeToFit()
        label.text = "@"
        return label
    }


    static func zipSubtitle2() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold.withSize(16)
        label.text = "A"
        return label
    }
    
    static func zipTextNotiBold() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBodyBold.withSize(14)
        label.text = "A"
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }
    
    static func zipTextFill() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipBody.withSize(16)
        label.sizeToFit()
        label.text = "@"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }
    
    static func zipTextDetail() -> UILabel {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.font = .zipTextDetail
        label.sizeToFit()
        label.text = "Joined Zipper on January 1st, 2022"
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        return label
    }
    
    static func zipTextPrompt() -> UILabel {
        let label = UILabel()
        label.textColor = .zipVeryLightGray
        label.numberOfLines = 0
        label.font = .zipBody.withSize(14)
        label.text = "tap to flip"
        return label
    }
    
    static func zipTextIcon() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .zipBody.withSize(12)
        return label
    }
    
}






//https://github.com/lionhylra/iOS-UIFont-Names
//static let titleFont = UIFont(name: "HelveticaNeue-Bold", size: 30)

//    static let titleFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 30)
//        static let titleFont = UIFont(name: "MuktaMahee-Bold", size: 30)
//        static let titleFont = UIFont(name: "Arial Rounded MT Bold", size: 30)
//        static let titleFont = UIFont(name: "avenir-heavy", size: 30)
//        static let titleFont = UIFont(name: "Arial-BoldMT", size: 30)


//    static let subtitleFont = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 18)
//        static let subtitleFont = UIFont(name: "MuktaMahee-Regular", size: 20)
//        static let subtitleFont = UIFont(name: "Arial Rounded MT Bold", size: 20)
//        static let subtitleFont =  UIFont(name: "avenir-medium", size: 20)
//        static let subtitleFont = UIFont(name: "ArialMT", size: 20)
