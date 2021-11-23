//
//  SettingsCategoryViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 7/15/21.
//
import UIKit

protocol SectionType: CustomStringConvertible {
    var containsSwitch: Bool { get }
    var containsDisclosureIndiciated: Bool { get }
}

enum SettingsCategory: Int, CaseIterable, CustomStringConvertible {
    case Account
    case Notifications
    case Privacy
    case Help
    
    var description: String {
        switch self {
        case .Account: return "Account"
        case .Notifications: return "Notifications"
        case .Privacy: return "Privacy"
        case .Help: return "Help"
        }
    }
}

class SettingsCategoryViewController: UIViewController {
    var category: SettingsCategory = SettingsCategory(rawValue: 0)!
    // MARK: - SubViews
    var tableView = UITableView()
    

    
    
    //MARK: - Buttons
    let backButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "backarrow"), for: .normal)
        btn.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        return btn
    }()
    
    
    //MARK: - Button Actions
    @objc private func didTapBackButton(){
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromLeft
        view.window!.layer.add(transition, forKey: nil)
        dismiss(animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .zipGray
    }
    
    public func configure(_ categoryIdx: Int){
        category = SettingsCategory(rawValue: categoryIdx)!
        
        

        configureNavBar()
        configureTable()
        addSubviews()
        configureSubviewLayout()
    }
    
    private func configureNavBar(){
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont.zipTitle.withSize(20),
             NSAttributedString.Key.foregroundColor: UIColor.white]
        
        navigationItem.title = category.description.uppercased()
        navigationItem.backBarButtonItem = BackBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    //MARK: - Table Config
    private func configureTable(){
        
        tableView.register(SettingsCellTableViewCell.self, forCellReuseIdentifier: SettingsCellTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .zipGray
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.bounces = false
        tableView.sectionIndexBackgroundColor = .zipLightGray
    }
    

    //MARK: AddSubviews
    private func addSubviews(){
        view.addSubview(tableView)
    }
    
    //MARK: Layout Subviews
    private func configureSubviewLayout() {
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

}

//MARK: - Delegate
extension SettingsCategoryViewController :  UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .zipSeparator
        
        let sectionLabel = UILabel()
        switch category {
        case .Account: sectionLabel.text = AccountSettingsSection(rawValue: section)?.description
        case .Notifications: sectionLabel.text = NotificationsSettingsSection(rawValue: section)?.description
        case .Privacy: sectionLabel.text = PrivacySettingsSection(rawValue: section)?.description
        case .Help: sectionLabel.text = HelpSettingsSection(rawValue: section)?.description
        }
        
        view.addSubview(sectionLabel)
        sectionLabel.textColor = .white
        sectionLabel.font = .zipBodyBold
        
        sectionLabel.translatesAutoresizingMaskIntoConstraints = false
        sectionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        sectionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        
        return view
    }
}

//MARK: - Data Source
extension SettingsCategoryViewController :  UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch category{
        case .Account: return accountNumberOfRowsInSection(sectionIdx: section)
        case .Notifications: return notificationsNumberOfRowsInSection(sectionIdx: section)
        case .Privacy: return privacyNumberOfRowsInSection(sectionIdx: section)
        case .Help: return helpNumberOfRowsInSection(sectionIdx: section)
        }

    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        switch category{
        case .Account: accessoryTappedInAccount(indexPath)
        case .Notifications: accessoryTappedInNotifications(indexPath)
        case .Privacy: accessoryTappedInPrivacy(indexPath)
        case .Help: accessoryTappedInHelp(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch category{
        case .Account: didTapInAccount(indexPath)
        case .Notifications: didTapInNotifications(indexPath)
        case .Privacy: didTapInPrivacy(indexPath)
        case .Help: didTapInHelp(indexPath)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch category{
        case .Account: return AccountSettingsSection.allCases.count
        case .Notifications: return NotificationsSettingsSection.allCases.count
        case .Privacy: return PrivacySettingsSection.allCases.count
        case .Help: return HelpSettingsSection.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch category{
        case .Account: cell = accountCellConfig(indexPath)
        case .Notifications: cell = notificationsCellConfig(indexPath)
        case .Privacy: cell = privacyCellConfig(indexPath)
        case .Help: cell = helpCellConfig(indexPath)
        }
        cell.textLabel?.font = .zipBody
        cell.textLabel?.textColor = .white
        return cell
    }
    
}
