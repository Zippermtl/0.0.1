//
//  HelpSettingsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/10/22.
//

import UIKit
import FirebaseAuth

class HelpSettingsViewController: UITableViewController {

    let tableData = ["Privacy Policy", "Terms and Conditions", "Contact/Support", "Delete Account"]
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help"
        tableView.backgroundColor = .zipGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let url = URL(string: "https://theofficialzipper.com/privacy-policy/")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        case 1:
            let url = URL(string: "https://theofficialzipper.com/terms-of-service/")!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        case 2:
            let email = "contact.zipmtl@gmail.com"
            if let url = URL(string: "mailto:\(email)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        default:
            let alert = UIAlertController(title: "Delete Account?", message: "are you sure you want to delete your account?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Delete Account", style: .default, handler: { _ in
                DatabaseManager.shared.deleteUser(userId: AppDelegate.userDefaults.value(forKey: "userId") as! String, completion: { [weak self] _ in
                    guard let strongSelf = self else {
                        return
                    }
                    
                    do {
                        try FirebaseAuth.Auth.auth().signOut()
                        let domain = Bundle.main.bundleIdentifier!
                        AppDelegate.userDefaults.removePersistentDomain(forName: domain)
                        AppDelegate.userDefaults.synchronize()
                        
                        let vc = OpeningLoginViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .fullScreen
                        strongSelf.present(nav, animated: true, completion: nil)
                    }
                    catch {
                        print("Failed to Logout User")
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true)
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
        cell.selectionStyle = .none
        return cell
        
    }


}
