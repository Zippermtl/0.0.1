//
//  NotificationsSettingsMethod.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

extension SettingsCategoryViewController {
    //MARK: - Config
    func notificationsCellConfig(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTableViewCell.identifier, for: indexPath) as! SettingsCellTableViewCell
        guard let section = NotificationsSettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .General:
            let general = NotificationsGeneralOptions(rawValue: indexPath.row)
            cell.sectionType = general
        case .Zips:
            let zips = NotificationsZipOptions(rawValue: indexPath.row)
            cell.sectionType = zips
        case .Messages:
            let messages = NotificationsMessagesOptions(rawValue: indexPath.row)
            cell.sectionType = messages
        case .Events:
            let messages = NotificationsEventOptions(rawValue: indexPath.row)
            cell.sectionType = messages
        }
        
        return cell
    }
    

    //MARK: - Rows in Section
        func notificationsNumberOfRowsInSection(sectionIdx: Int) -> Int {
        guard let section = NotificationsSettingsSection(rawValue: sectionIdx) else { return 0 }

        switch section {
        case .General: return NotificationsGeneralOptions.allCases.count
        case .Zips: return NotificationsZipOptions.allCases.count
        case .Messages: return NotificationsMessagesOptions.allCases.count
        case .Events: return NotificationsEventOptions.allCases.count
        }
    }
    

    //MARK: - Did Tap
    func didTapInNotifications(_ indexPath: IndexPath) {
        // None of the notifications tabbs have tap buttons
    }
    
    //MARK: - Accessory Tapped
    func accessoryTappedInNotifications(_ indexPath: IndexPath) {
        guard let switchControl = tableView.cellForRow(at: indexPath)?.accessoryView as? UISwitch else { return }
        let status = switchControl.isOn
        
        guard let section = NotificationsSettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .General:
            let setting = NotificationsGeneralOptions(rawValue: indexPath.row)
            switch setting {
            case .pauseAll: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsPauseAll")
            case .zipUpdate: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsZipUpdate")
            case .none: break
            }

        case .Messages:
            let setting = NotificationsMessagesOptions(rawValue: indexPath.row)
            switch setting {
            case .messages: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsMessages")
            case .messageRequests: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsMessageRequests")
            case .none: break
            }
        case .Zips:
            let setting = NotificationsZipOptions(rawValue: indexPath.row)
            switch setting {
            case .zipRequests: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsZipRequests")
            case .acceptedRequests: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsAcceptedRequests")
            case .none: break
            }

        case .Events:
            let setting = NotificationsEventOptions(rawValue: indexPath.row)
            switch setting {
            case .eventInvites: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsEventInvites")
            case .publicEvents: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsPublicEvents")
            case .dayReminders: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsDayReminders")
            case .infoChange: AppDelegate.userDefaults.setValue(status, forKey: "NotificationSettingsInfoChange")
            case .none: break
            }
        }
    }
}


/*
 
 
 func notificationsCellConfig(_ indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTableViewCell.identifier, for: indexPath) as! SettingsCellTableViewCell
     guard let section = NotificationsSettingsSection(rawValue: indexPath.section),
           let encoded = AppDelegate.userDefaults.value(forKey: "encodedNotificationSettings") as? Int else {
         return UITableViewCell()
         
     }
     
     
     let decoded = DecodePreferences(encoded)
     
     switch section {
     case .General:
         let general = NotificationsGeneralOptions(rawValue: indexPath.row)
         cell.sectionType = general
         switch general {
         case .pauseAll:
             
 
         case .zipUpdate:
             <#code#>
         }
         
     case .Zips:
         let zips = NotificationsZipOptions(rawValue: indexPath.row)
         cell.sectionType = zips
         
         switch zips {
         case .zipRequests:
             <#code#>
         case .acceptedRequests:
             <#code#>
         }
     case .Messages:
         let messages = NotificationsMessagesOptions(rawValue: indexPath.row)
         cell.sectionType = messages
         
         switch messages {
         case .messages:
             <#code#>
         case .messageRequests:
             <#code#>
         }
     case .Events:
         let events = NotificationsEventOptions(rawValue: indexPath.row)
         cell.sectionType = events
         
         switch events {
         case .eventInvites:
             <#code#>
         case .publicEvents:
             <#code#>
         case .dayReminders:
             <#code#>
         case .infoChange:
             <#code#>
         }
     }
     
     return cell
 }
 */
