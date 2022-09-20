//
//  AccountSettingsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/10/22.
//

import UIKit

class AccountSettingsViewController: UITableViewController {

    
    let tableData = ["Gender", "Blocked Users"]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Account"
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tableView.backgroundColor = .zipGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = genderVC()
            navigationController?.pushViewController(vc, animated: true)
        default:
            let blockedUser = AppDelegate.userDefaults.value(forKey: "blockedUsers") as? [String] ?? []
            let users = blockedUser.map({ User(userId: $0 )})
            let vc = MasterTableViewController(cellData: users, cellType: CellType(userType: .unblock))
            vc.title = "Blocked Users"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = .zipGray
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .white
        content.textProperties.font = .zipTextFill
        content.text = tableData[indexPath.row]
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private class genderVC : GenderSelectViewController {
        init(){
            super.init(user: User())
            
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            guard let gender = AppDelegate.userDefaults.value(forKey: "gender") as? String else {
                return
            }
            let idx: Int
            switch gender {
            case "M": idx = 0
            case "W": idx = 1
            case "O": idx = 2
            default: idx = 3
            }
            
            let cell = tableView.cellForRow(at: IndexPath(row: idx, section: 0)) as! GenderCell
            cell.selectionButton.isSelected = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didTapDoneButton() {
            AppDelegate.userDefaults.set(gender, forKey: "gender")
            DatabaseManager.shared.updateGender(gender: gender, completion: { [weak self] error in
                guard error == nil else {
                    return
                }
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }

}
