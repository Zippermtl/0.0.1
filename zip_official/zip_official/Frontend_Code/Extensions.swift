//
//  Extensions.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 10/7/21.
//

import Foundation
import UIKit
import DropDown
import RSKImageCropper
import CoreLocation
import FirebaseFirestore
import FirebaseFirestoreSwift
import CodableFirebase

extension UIScrollView {
    func updateContentView(_ buffer: CGFloat = 0) {
        contentSize.height = (subviews.sorted(by: { $0.frame.maxY < $1.frame.maxY }).last?.frame.maxY ?? contentSize.height) + buffer
    }
}

extension RSKImageCropViewController {
    public func setBackgroundColor(_ color : UIColor){
        view.backgroundColor = color
    }
}


extension Notification.Name {
    /// Notification when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}


class ResizeSlider: UISlider {
  @IBInspectable var trackHeight: CGFloat = 2

  override func trackRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(origin: CGPoint(x: 0, y: bounds.midY), size: CGSize(width: bounds.width, height: trackHeight))
  }
}


extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}


//creates frame with wrapped text to see what the height will be
extension String {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipTextFill
        tempLabel.text = self
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
    
    var imgNumber: String {
        if self.contains("profile_picture") { return "!profile_picture" }
        
        if let range = self.range(of: "img")?.upperBound {
            return String(self[range...])
        }
        
        return ""
    }
}


extension UILabel {
    func heightForWrap(width: CGFloat) -> CGFloat{
        let tempLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.lineBreakMode = .byWordWrapping
        tempLabel.font = .zipBody
        tempLabel.text = text
        tempLabel.sizeToFit()
        return tempLabel.frame.height
    }
}


public func getDistanceLabel(user: User) -> String {
    guard let coordinates = UserDefaults.standard.object(forKey: "userLoc") as? [Double] else {
        return ""
    }
    
    let userLoc = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
    var distance = Double(round(10*(userLoc.distance(from: user.location))/1000))/10

    var unit = "km"
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
            return "<1 \(unit)"
        } else if distance >= 500 {
            return ">500 \(unit)"
        } else {
            return String(intDistance) + " \(unit)"
        }
    } else {
        if distance <= 1 {
            if unit == "miles" {
                unit = "mile"
            }
            return "<1 \(unit)"
        } else if distance >= 500 {
            return ">500 \(unit)"
        } else {
            return String(distance) + " \(unit)"
        }
    }
}

extension Date {
    
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
            calendar.isDate(self, equalTo: date, toGranularity: component)
    }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }
    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameDay(as date: Date) -> Bool { isEqual(to: date, toGranularity: .day) }

    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
         let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
         return addingTimeInterval(delta)
    }
    
    public func round(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .toNearestOrAwayFromZero)
    }
    
    public func ceil(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .up)
    }
    
    public func floor(precision: TimeInterval) -> Date {
        return round(precision: precision, rule: .down)
    }
    
    private func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
        let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision;
        return Date(timeIntervalSinceReferenceDate: seconds)
    }
    
}


extension JSONDecoder {
    func decode<T>(_ type: T.Type, fromJSONObject object: Any) throws -> T where T: Decodable {
        return try decode(T.self, from: try JSONSerialization.data(withJSONObject: object, options: []))
    }
}
//
//extension QueryDocumentSnapshot {
//
//    func prepareForDecoding() -> [String: Any] {
//        var data = self.data()
//        data["documentId"] = self.documentID
//
//        return data
//    }
//
//}


extension DocumentReference {
    func updateData<T: Encodable>(for object: T, completion: @escaping (Error?) -> Void) {
        do {
            try self.setData(from: object, merge: true) { err in
                completion(err)
            }
        } catch {
            completion(error)
        }
    }
}
