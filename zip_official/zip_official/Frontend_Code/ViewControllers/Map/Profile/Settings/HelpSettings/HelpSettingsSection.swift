//
//  HelpSettingsSection.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

enum HelpSettingsSection: Int, CaseIterable, CustomStringConvertible {
    case General
    
    var description: String {
        switch self {
        case .General: return "General"
        }
    }
}

//MARK: - General Section
enum HelpGeneralOptions: Int, CaseIterable, SectionType {
    case privacyPolicy
    case termsAndConditions
    case contactSupport
    case feedback
    case deleteAccount
    
    var containsSwitch: Bool {
        return false
    }
    
    var containsDisclosureIndiciated: Bool {
        switch self {
        case .privacyPolicy, .termsAndConditions: return true
        default: return false
        }
    }
    
    var description: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .termsAndConditions: return "Terms and Conditions"
        case .contactSupport: return "Contact Support"
        case .feedback: return "Feedback"
        case .deleteAccount: return "Delete Account"
        }
    }
}
