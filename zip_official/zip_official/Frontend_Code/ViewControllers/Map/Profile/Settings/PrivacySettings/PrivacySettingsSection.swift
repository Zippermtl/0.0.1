//
//  PrivacySettingsSection.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

enum PrivacySettingsSection: Int, CaseIterable, CustomStringConvertible {
    case General
    
    var description: String {
        switch self {
        case .General: return "General"
        }
    }
}

//MARK: - General Section
enum PrivacyGeneralOptions: Int, CaseIterable, SectionType {
    case incognito
    case readReceipts
    case sharePastEvents
    
    var containsSwitch: Bool {
        switch self {
        case .incognito: return true
        case .readReceipts: return true
        case .sharePastEvents: return true
        }
    }
    
    var containsDisclosureIndiciated: Bool {
        return false
    }
    
    var description: String {
        switch self {
        case .incognito: return "Incognito"
        case .readReceipts: return "Read Receipts"
        case .sharePastEvents: return "Share Past Events"
        }
    }
}
