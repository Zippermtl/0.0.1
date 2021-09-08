//
//  PrivacySettingsMethods.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

extension SettingsCategoryViewController {
    //MARK: - Config
    func privacyCellConfig(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTableViewCell.identifier, for: indexPath) as! SettingsCellTableViewCell
        guard let section = PrivacySettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .General:
            let general = PrivacyGeneralOptions(rawValue: indexPath.row)
            cell.sectionType = general
        }

        return cell
    }
    
    
    //MARK: - Rows in Section
    func privacyNumberOfRowsInSection(sectionIdx: Int) -> Int {
        guard let section = PrivacySettingsSection(rawValue: sectionIdx) else { return 0 }

        switch section {
        case .General: return PrivacyGeneralOptions.allCases.count
        }
    }
    
    //MARK: - Did Tap
    func didTapInPrivacy(_ indexPath: IndexPath) {
        //There are no tapable cells in privacy
    }

    //MARK: - Accessory Tapped
    func accessoryTappedInPrivacy(_ indexPath: IndexPath) {
        guard let switchControl = tableView.cellForRow(at: indexPath)?.accessoryView as? UISwitch else { return }
        let status = switchControl.isOn
        
        guard let section = PrivacySettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .General:
            let setting = PrivacyGeneralOptions(rawValue: indexPath.row)
            switch setting {
            case .incognito: AppDelegate.userDefaults.setValue(status, forKey: "PrivacySettingsIncognito")
            case .readReceipts: AppDelegate.userDefaults.setValue(status, forKey: "PrivacySettingsReadReceipts")
            case .sharePastEvents: AppDelegate.userDefaults.setValue(status, forKey: "PrivacySettingsSharePastEvents")
            case .none: break
            }
        }
    }
}
