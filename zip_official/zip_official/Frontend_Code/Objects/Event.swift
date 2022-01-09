//
//  Event.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/9/21.
//

import Foundation
import UIKit
import CoreLocation

//for future, enumerate event type


struct Event {
    var eventId: String = ""
    var title: String = ""
    var coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var hosts: [User] = []
    var description: String = ""
    var address: String = ""
    var locationName: String = ""
    var maxGuests: Int = 0
    var usersGoing: [User] = []
    var usersInterested: [User] = []
    var usersInvite: [User] = []
    var type: String = "promoter"
    var isPublic: Bool = false
    var startTime: Date = Date()
    var endTime: Date = Date()
    var duration: TimeInterval = TimeInterval(1)
    var image: UIImage? = UIImage(named: "launchevent")
    
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: startTime)
    }
    
    var createEventId: String {
        guard let userId = AppDelegate.userDefaults.value(forKey: "userId") as? String else {
            return ""
        }
        let dateString = ChatViewController.dateFormatter.string(from: Date())
        return "\(userId)_\(title.replacingOccurrences(of: " ", with: "-"))_\(dateString)"
    }
}
