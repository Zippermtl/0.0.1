//
//  User_Data.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//

import Foundation
import MapKit

struct User {
    var userID: Int = 0
    var email: String = ""
    var username: String = ""
    var name: String = ""
    var zipped: Bool = false
    var distance: Double = 0
    var birthday: Date = Date()
    var age: Int = 18
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var pictures: [UIImage] = []
    var bio: String = ""
    var school: String?
    var interests: [String] = []
    var previousEvents: [Event] = []
    var goingEvents: [Event] = []
    var interestedEvents: [Event] = []
}
