//
//  NotificationsSettingSection.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//



//MARK: - Section Names
enum NotificationsSettingsSection: Int, CaseIterable, CustomStringConvertible {
    case General
    case Zips
    case Messages
    case Events
    
    var description: String {
        switch self {
        case .General: return "General".uppercased()
        case .Zips: return "Zips".uppercased()
        case .Messages: return "Messages".uppercased()
        case .Events: return "Events".uppercased()
        }
    }
}

//MARK: - General Section
enum NotificationsGeneralOptions: Int, CaseIterable, SectionType {
    case pauseAll
    case zipUpdate
    
    var containsSwitch: Bool {
        return true
    }
    
    var containsDisclosureIndiciated: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .pauseAll: return "Pause All Notifications"
        case .zipUpdate: return "News Updates"
        }
    }
}

//MARK: - Zip Section
enum NotificationsZipOptions: Int, CaseIterable, SectionType {
    case zipRequests
    case acceptedRequests
    
    var containsSwitch: Bool {
        return true
    }
    
    var containsDisclosureIndiciated: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .zipRequests: return "Zip Requests"
        case .acceptedRequests: return "Accepted Zip Requests"
        }
    }
}

//MARK: - Messages Section
enum NotificationsMessagesOptions: Int, CaseIterable, SectionType {
    case messages
    case messageRequests
    
    var containsSwitch: Bool {
        return true
    }
    
    var containsDisclosureIndiciated: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .messages: return "Messages"
        case .messageRequests: return "Message Requests"
        }
    }
}

//MARK: - Event Section
enum NotificationsEventOptions: Int, CaseIterable, SectionType {
    case eventInvites
    case publicEvents
    case dayReminders
    case infoChange
    
    var containsSwitch: Bool {
        return true
    }
    
    var containsDisclosureIndiciated: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .eventInvites: return "Event Invites"
        case .publicEvents: return "Public Events"
        case .dayReminders: return "1 Day Reminders"
        case .infoChange: return "Changes to Event Info"
        }
    }
}
