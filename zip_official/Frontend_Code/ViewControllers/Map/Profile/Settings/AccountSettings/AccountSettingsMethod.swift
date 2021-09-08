//
//  AccountSettingsMethod.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//

import UIKit

extension SettingsCategoryViewController {
    //MARK: - Config
    func accountCellConfig(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCellTableViewCell.identifier, for: indexPath) as! SettingsCellTableViewCell
        
        guard let section = AccountSettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .General:
            let general = AccountGeneralOptions(rawValue: indexPath.row)
            cell.sectionType = general
        }
        
        return cell
    }


    //MARK: - Rows in Section
    func accountNumberOfRowsInSection(sectionIdx: Int) -> Int {
        guard let section = AccountSettingsSection(rawValue: sectionIdx) else { return 0 }

        switch section {
        case .General: return AccountGeneralOptions.allCases.count
        }
    }

    //MARK: - Did Tap
    func didTapInAccount(_ indexPath: IndexPath) {
        guard let section = AccountSettingsSection(rawValue: indexPath.section) else { return }
        switch section {
        case .General:
            let setting = AccountGeneralOptions(rawValue: indexPath.row)
            switch setting {
            case .username: didTapChangeUsername()
            case .email: break
            case .changePassword: didTapChangePassword()
//            case .Appearance: break
            case .none: break
            }
            
        }
    }
    
    //MARK: - Cell Taps
    private func didTapChangeUsername(){
        let changeUsernameView = ChangeUsernameViewController()
        changeUsernameView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        
        self.view.window!.layer.add(transition, forKey: nil)
        present(changeUsernameView, animated: false, completion: nil)
    }
    
    private func didTapChangePassword(){
        let changePasswordView = ChangePasswordViewController()
        changePasswordView.modalPresentationStyle = .overCurrentContext
        
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        
        self.view.window!.layer.add(transition, forKey: nil)
        present(changePasswordView, animated: false, completion: nil)
    }
    
    //MARK: - Accessory Tapped
    func accessoryTappedInAccount(_ indexPath: IndexPath) {
        
    }
}
