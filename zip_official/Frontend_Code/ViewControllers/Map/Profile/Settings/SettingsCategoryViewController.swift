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
    var headerView = UIView()
    var tableView = UITableView()
    
    //MARK: - Labels
    private var pageTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(26)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "SETTINGS"
        return label
    }()
    
    private var pageSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .zipTitle.withSize(20)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        label.sizeToFit()
        label.text = "______ SETTINGS"
        return label
    }()
    
    
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
        self.view.window!.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func configure(_ categoryIdx: Int){
        self.category = SettingsCategory(rawValue: categoryIdx)!
        
        
        pageSubtitleLabel.text = category.description.uppercased() + " SETTINGS"
        configureHeader()
        configureTable()
        addSubviews()
        configureSubviewLayout()
    }
    
    //MARK: - Header Config
    private func configureHeader(){
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/6)
        headerView.backgroundColor = .zipGray
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
        // Header
        view.addSubview(headerView)
        headerView.addSubview(pageTitleLabel)
        headerView.addSubview(backButton)
        headerView.addSubview(pageSubtitleLabel)
        
        // Table Views
        view.addSubview(tableView)
        
    }
    
    //MARK: Layout Subviews
    private func configureSubviewLayout() {
        // Table View
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true

        // Page Title
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageTitleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor).isActive = true
        pageTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        pageSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        pageSubtitleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        pageSubtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.heightAnchor.constraint(equalToConstant: pageTitleLabel.intrinsicContentSize.height*1.5).isActive = true
        backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 20).isActive = true
        backButton.centerYAnchor.constraint(equalTo: pageTitleLabel.centerYAnchor).isActive = true
        
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
        switch category{
        case .Account: return accountCellConfig(indexPath)
        case .Notifications: return notificationsCellConfig(indexPath)
        case .Privacy: return privacyCellConfig(indexPath)
        case .Help: return helpCellConfig(indexPath)
        }
    }
    
}
