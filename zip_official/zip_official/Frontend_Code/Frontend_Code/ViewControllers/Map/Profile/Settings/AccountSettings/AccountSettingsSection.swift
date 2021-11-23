//
//  PrivacySettingsSection.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//



enum AccountSettingsSection: Int, CaseIterable, CustomStringConvertible {
    case General
    
    var description: String {
        switch self {
        case .General: return "General".uppercased()
        }
    }
}

//MARK: - General Section
enum AccountGeneralOptions: Int, CaseIterable, SectionType {
    case username
    case email
    case changePassword
//    case Appearance
    
    var containsSwitch: Bool {
        return false
    }
    
    var containsDisclosureIndiciated: Bool {
        return true
    }
    
    var description: String {
        switch self {
        case .username: return "Change Username"
        case .email: return "Change Email"
        case .changePassword: return "Change Password"
//        case .Appearance: return "Appearance"
        }
    }
}
