//
//  DevStackViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 9/27/22.
//

import UIKit
import JGProgressHUD

class DevStackViewController: UITableViewController {
    let spinner = JGProgressHUD(style: .light)
    let tableData = ["Promoter Applications", "Ambassador Applications"]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem =  BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        title = "Developer Stack"
        tableView.backgroundColor = .zipGray
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            spinner.show(in: view)
            DatabaseManager.shared.getPromoterRequests(completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let users):
                    let vc = PromoterAppsViewController(users: users)
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true)
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                case .failure(let error):
                    print("Error getting promoter requests")
                    let alert = UIAlertController(title: "Error", message: "Either bad connection or no requests", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true)
                        strongSelf.present(alert,animated: true)
                    }
                }
                
            })
        case 1:
            spinner.show(in: view)
            DatabaseManager.shared.getAmbassadorRequests(completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let users):
                    let vc = AmbassadorAppsViewController(users: users)
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true)
                        strongSelf.navigationController?.pushViewController(vc, animated: true)
                    }
                case .failure(let error):
                    print("Error getting promoter requests")
                    let alert = UIAlertController(title: "Error", message: "Either bad connection or no requests", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
                    DispatchQueue.main.async {
                        strongSelf.spinner.dismiss(animated: true)
                        strongSelf.present(alert,animated: true)
                    }
                }
                
            })
        default: break
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

    private class PromoterAppsViewController: MasterTableViewController {
        init(users: [User]) {
            super.init(cellData: users, cellType: CellType(userType: .abstract))
            let rejectConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Reject", { item in
                guard let user = item as? User else { return }
                DatabaseManager.shared.rejectPromoterApplication(user: user, completion: { error in

                    
                })
            }, nil, .systemRed)
            
            let acceptConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Accept", { item in
                guard let user = item as? User else { return }
                DatabaseManager.shared.acceptPromoterApplication(user: user, completion: { error in
                    
                })
            }, nil, .systemGreen)
            
            let devConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Make Dev", { item in
                guard let user = item as? User else { return }
                DatabaseManager.shared.makeDeveloper(userId: user.userId, completion: { error in
                    
                })
            }, nil, .systemBlue)
            
            trailingCellSwipeConfiguration = [rejectConfig]
            leadingCellSwipeConfiguration = [devConfig,acceptConfig]
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Promoter Applications"
        }
    }
    
    private class AmbassadorAppsViewController: MasterTableViewController {
        init(users: [User]) {
            super.init(cellData: users, cellType: CellType(userType: .abstract))
            let rejectConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Reject", { item in
                guard let user = item as? User else { return }
                
            }, nil, .systemRed)
            
            let acceptConfig : MasterTableSwipeConfiguration = (UIContextualAction.Style.destructive, "Accept", { item in
                guard let user = item as? User else { return }
                DatabaseManager.shared.acceptAmbassador(user: user, completion: { error in
                    
                })
            }, nil, .systemGreen)
            
            
            trailingCellSwipeConfiguration = [rejectConfig]
            leadingCellSwipeConfiguration = [acceptConfig]
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Ambassador Applications"
        }
    }
}
