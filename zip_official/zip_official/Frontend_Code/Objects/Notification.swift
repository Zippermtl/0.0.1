//
//  Notification.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/8/21.
//

import Foundation
import UIKit

enum NotificationType: Int, CaseIterable {
    case news
    case eventPublic
    case eventInvite
    case eventTimeChange
    case eventAddressChange
    case eventLimitedSpots
    case zipRequest
    case zipAccepted
}


/// All notification keys
public let ALL_NOTIF_KEYS = [
    "pause_all", "news_update",
    "zip_requests", "accepted_zip_requests",
    "messages", "message_requests",
    "event_invites", "public_events",
    "one_day_reminders", "changes_to_event_info"
]


/// For you Yianni, to make your life simpler I grouped notification keys below by category

/// Notification keys under the "General" section
public let GENERAL_NOTIF_KEYS = [ALL_NOTIF_KEYS[0], ALL_NOTIF_KEYS[1]]

/// Notification keys under the "Zips" section
public let ZIPS_NOTIF_KEYS = [ALL_NOTIF_KEYS[2], ALL_NOTIF_KEYS[3]]

/// Notification keys under the "Messages" section
public let MESSAGES_NOTIF_KEYS = [ALL_NOTIF_KEYS[4], ALL_NOTIF_KEYS[5]]

/// Notification kets under the "Events" section
public let EVENTS_NOTIF_KEYS = [ALL_NOTIF_KEYS[6], ALL_NOTIF_KEYS[7], ALL_NOTIF_KEYS[8], ALL_NOTIF_KEYS[9]]


let DEFAULT_NOTIF_VALUE = 0 // Disable notifications by default


// Decode integer into a dictionary
public func DecodePreferences(_ N: Int?) -> [String: Bool] {
    var values: [String: Bool] = [:]
    var counter = 0 // Start index
    var current = N ?? DEFAULT_NOTIF_VALUE
    let NB_PREFS = ALL_NOTIF_KEYS.count
    
    // While we have not yet created an array of NUMBER_OF_PREFERENCES elements
    while (counter < NB_PREFS) {
        values[ALL_NOTIF_KEYS[NB_PREFS-1-counter]] = current%2 > 0
        current /= 2 // Get rid of LSB
        counter += 1 // Increase counter
    }
    
    // Return dictionary
    return values
}


// Encode preferences into a integer
public func EncodePreferences(_ preferences: [String: Bool]) -> Int {
    var total = 0 // Total value
    var powerOfTwo = 1 // Start with 2^0
    
    // Loop through each value starting from end
    for i in (0..<ALL_NOTIF_KEYS.count).reversed() {
        let pref = preferences[ALL_NOTIF_KEYS[i]]
        if let preference = pref {
            if preference {total += powerOfTwo} // If bit is on, add power of 2
        }
        powerOfTwo *= 2 // Multiply by 2 to get next power of 2
    }
    
    // Return total
    return total
}


struct ZipNotification {
    var fromId: String = " " //figure this shit out later
    var fromName: String = "default Notif Name"
    let type: NotificationType
    let image: UIImage
    let time: TimeInterval
    var hasRead: Bool = false
}
