//
//  EventTypeSelectViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 6/23/22.
//

import UIKit

class EventTypeSelectViewController: UIViewController {
    private let tableView: UITableView
    private let tableData: [EventType:(String,String)]
    
    init() {
        self.tableView =  UITableView()
        self.tableData = [
            .Private : ("Invite your Zips",
                        "Only appears on the map for those invited"),
            
            .Friends : ("Automatically invites all your zips",
                            "Only appears on the map for those invited"),
            
            .Public: ("Invite your Zips",
                      "Only appears on the map for those invited"),
            
            .Promoter : ("Exclusive for promoter accounts (Coming soon)",
                         "Appears on the map for EVERYONE")

        ]
        
        
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .zipGray
        title = "Select an Event Type"
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: self, action: #selector(didTapDismiss))
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.white), for: .normal)
        dismissButton.frame = CGRect(x: 0, y: 0, width: 1, height: 34)
        dismissButton.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: dismissButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(EventTypeTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.bounces = false
        tableView.separatorColor = .zipGray
        
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapDismiss(){
        dismiss(animated: true, completion : nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}


extension EventTypeSelectViewController: UITableViewDelegate {
    
}

extension EventTypeSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? EventTypeTableViewCell else {
            return UITableViewCell()
        }
        
        
        switch indexPath.row {
        case 0:
            cell.configure(type: .Private,
                           bulletPoints: tableData[.Private]!,
                           color: .zipBlue,
                           icon: UIImage(systemName: "lock.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        case 1:
            cell.configure(type: .Public,
                           bulletPoints: tableData[.Public]!,
                           color: .zipGreen,
                           icon: UIImage(systemName: "lock.open.fill")!.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        case 2:
            cell.configure(type: .Promoter,
                           bulletPoints: tableData[.Promoter]!,
                           color: .zipYellow,
                           icon: UIImage(systemName: "globe")!.withRenderingMode(.alwaysOriginal).withTintColor(.white))
        default: return UITableViewCell()
        }
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = CreateEventViewController(event: PrivateEvent())
            navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = CreateEventViewController(event: PublicEvent())
            navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = CreateEventViewController(event: PromoterEvent())
            navigationController?.pushViewController(vc, animated: true)
        default: break
        }
    }
    
    
}
