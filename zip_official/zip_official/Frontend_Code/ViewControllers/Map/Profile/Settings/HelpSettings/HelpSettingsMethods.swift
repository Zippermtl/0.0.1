//
//  HelpSettingsMethods.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

extension SettingsCategoryViewController {
    //MARK: - Config
    func helpCellConfig(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTableViewCell.identifier, for: indexPath) as! SettingsCellTableViewCell
        guard let section = HelpSettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .General:
            let general = HelpGeneralOptions(rawValue: indexPath.row)
            cell.sectionType = general
        }
        
        return cell
    }
    
    //MARK: - Rows in Section
    func helpNumberOfRowsInSection(sectionIdx: Int) -> Int {
        guard let section = HelpSettingsSection(rawValue: sectionIdx) else { return 0 }

        switch section {
        case .General: return HelpGeneralOptions.allCases.count
        }
    }
    
    //MARK: - Did Tap
    func didTapInHelp(_ indexPath: IndexPath) {
        guard let section = AccountSettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .General:
            let setting = HelpGeneralOptions(rawValue: indexPath.row)
            switch setting {
            case .privacyPolicy: break
            case .termsAndConditions: break
            case .feedback: break
            case .contactSupport: break
            case .deleteAccount: break
            case .none: break
            }
        }
    }
    
    
    //MARK: - Did Tap Accessory
    func accessoryTappedInHelp(_ indexPath: IndexPath) {
        
    }

}





