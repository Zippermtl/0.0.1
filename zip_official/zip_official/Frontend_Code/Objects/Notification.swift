//
//  Notification.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/8/21.
//

import Foundation
import UIKit

//enum NotificationType: Int, CaseIterable {
//    case news
//    case eventPublic
//    case eventInvite
//    case eventTimeChange
//    case eventAddressChange
//    case eventLimitedSpots
//    case zipRequest
//    case zipAccepted
//}

public enum NotificationType: CaseIterable {
    case general
    case zipNotification
    case messageNotification
    case EventNotification
    
    var subtypes: [NotificationSubtype] {
        switch self {
        case .general: return [.pause_all, .news_update]
        case .zipNotification: return [.zip_request, .accepted_zip_request]
        case .messageNotification: return [.message, .message_request]
        case .EventNotification: return [.event_invite, .public_event, .one_day_reminder, .change_to_event_info]
        }
    }
}

public enum NotificationSubtype: Int, Codable, CaseIterable{
    case pause_all = 0
    case news_update = 1
    case zip_request = 2
    case accepted_zip_request = 3
    case message = 4
    case message_request = 5
    case event_invite = 6
    case public_event = 7
    case one_day_reminder = 8
    case change_to_event_info = 9
}






let DEFAULT_NOTIF_VALUE = 0 // Disable notifications by default


// Decode integer into a dictionary
public func DecodePreferences(_ N: Int?) -> NotificationPreference {
    var values: NotificationPreference = [:]
    var counter = 0 // Start index
    var current = N ?? DEFAULT_NOTIF_VALUE
    let NB_PREFS = NotificationSubtype.allCases.count
    
    // While we have not yet created an array of NUMBER_OF_PREFERENCES elements
    while (counter < NB_PREFS) {
        values[NotificationSubtype.allCases[NB_PREFS-1-counter]] = current%2 > 0
        current /= 2 // Get rid of LSB
        counter += 1 // Increase counter
    }
    
    // Return dictionary
    return values
}


// Encode preferences into a integer
public func EncodePreferences(_ preferences: NotificationPreference) -> Int {
    var total = 0 // Total value
    var powerOfTwo = 1 // Start with 2^0
    
    for i in (0..<NotificationSubtype.allCases.count).reversed() {
        let pref = preferences[NotificationSubtype.allCases[i]]
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

struct ZipRequest {
    var fromUser: User
    let time: TimeInterval
}
