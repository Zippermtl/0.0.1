//
//  Users.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/3/21.
//

import Foundation
import MapKit

public class User {
    var userId: String = ""
    var email: String = ""
    var username: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var zipped: Bool = false
    var distance: Double = 0
    var birthday: Date = Date()
    var age: Int = 18
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var picNum: Int = 0
    var pictures: [UIImage] = []
    var pictureURLs: [URL] = []
    var bio: String = ""
    var school: String?
    var interests: [Interests] = []
    var previousEvents: [Event] = []
    var goingEvents: [Event] = []
    var interestedEvents: [Event] = []
    var notificationPreferences: [String: Bool] = [:] // Notification Preferences
    var friendships: [Friendship] = [] // Friendship Preferences
    
    init() {}
    
    init(userId id: String, username us: String, firstName fn: String, lastName ln: String, birthday bd: Date, picNum pn: Int, bio b: String, school sc: String?, interests inters: [Interests], notificationPreferences np: Int?, friendships fs: String?) {
        userId = id
        username = us
        firstName = fn
        lastName = ln
        birthday = bd
        picNum = pn
        bio = b
        school = sc
        interests = inters
        notificationPreferences = DecodePreferences(np)
        friendships = DecodeFriendships(of: self, given: fs)
    }
    
    func getFriendsList() -> [User] {
        var friends: [User] = []
        for friendship in friendships {
            switch friendship.status {
                case.ACCEPTED: friends.append(friendship.to)
                default: break
            }
        }
        
        return friends
    }
    
    var safeId: String {
        var safeID = userId.replacingOccurrences(of: ".", with: "-")
        safeID = safeID.replacingOccurrences(of: "@", with: "-")
        return safeID
    }
    
    var picturesPath: String {
        return "images/\(safeId)/"
    }
    
    var profilePictureFileName: String {
        return "\(safeId)/profile_picture.png"
    }
    
    var fullName: String {
        return firstName + " " + lastName
    }
    
    var birthdayString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: birthday)
    }
    
    var interestsString: String {
        return "Interests: " + interests.map{$0.description}.joined(separator: ", ")
    }
}
