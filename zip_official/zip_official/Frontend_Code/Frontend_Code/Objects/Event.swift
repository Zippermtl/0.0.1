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
    var eventId: Int = 0
    var title: String = ""
    var location: CLLocation = CLLocation()
    var hosts: [User] = []
    var description: String = ""
    var address: String = ""
    var maxGuests: Int = 0
    var usersGoing: [User] = []
    var usersInterested: [User] = []
    var usersInvite: [User] = []
    var type: String = "promoter"
    var isPublic: Bool = false
    var startTime: Date = Date()
    var duration: TimeInterval = TimeInterval(1)
    var image: UIImage? = UIImage(named: "launchevent")
}
