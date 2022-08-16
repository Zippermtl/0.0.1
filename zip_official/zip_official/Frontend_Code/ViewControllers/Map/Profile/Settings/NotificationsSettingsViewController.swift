//
//  NotificationsSettingsViewController.swift
//  zip_official
//
//  Created by Yianni Zavaliagkos on 8/10/22.
//

import UIKit

protocol NotificationSectionHeaderDelegate: AnyObject {
    func openSection(section: Int)
}

class NotificationsSettingsViewController: UITableViewController, NotificationSectionHeaderDelegate {
    fileprivate struct SectionData {
        var open: Bool
        var notifType: NotificationType
    }
    
    fileprivate var sections: [SectionData] = [
        SectionData(open: false, notifType: .general), //empty case
        SectionData(open: false, notifType: .general),
        SectionData(open: false, notifType: .zipNotification),
        SectionData(open: false, notifType: .EventNotification),
        SectionData(open: false, notifType: .messageNotification)
    ]
    
    var notifPrefs : NotificationPreference = [:]
    var inAppNotifs = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notifications"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(sectionHeader.self, forHeaderFooterViewReuseIdentifier: sectionHeader.identifier)
        tableView.backgroundColor = .zipGray
        tableView.tableHeaderView = nil
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        inAppNotifs = AppDelegate.userDefaults.value(forKey: "inAppNotifs") as? Bool ?? true
        let encodedPrefs = AppDelegate.userDefaults.value(forKey: "encodedNotificationSettings") as? Int ?? 0
        notifPrefs = DecodePreferences(encodedPrefs)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.userDefaults.set(EncodePreferences(notifPrefs),forKey: "encodedNotificationSettings")
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? .leastNormalMagnitude : 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return sections[section].open ? sections[section].notifType.subtypes.count : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 1))
        view.backgroundColor = .zipSeparator
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let sectionData = sections[section]
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: sectionHeader.identifier) as! sectionHeader
        sectionHeader.delegate = self
        sectionHeader.section = section
        sectionHeader.configure(sectionData: sectionData, sectionIdx: section)
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        var labelText = section.notifType.subtypes[indexPath.row].description
        var switchValue = notifPrefs[section.notifType.subtypes[indexPath.row]]!
        
        if indexPath.section == 0 {
            labelText = "In-App Notifications"
            switchValue = inAppNotifs
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.backgroundColor = .zipGray
        var content = cell.defaultContentConfiguration()
        content.textProperties.color = .white
        content.textProperties.font = .zipTextFill
        
        content.text = labelText
        cell.contentConfiguration = content
        let switchView = UISwitch(frame: .zero)
        switchView.onTintColor = .zipLightGray
        switchView.tintColor = .zipLightGray
        switchView.thumbTintColor = .zipBlue
        switchView.setOn(switchValue, animated: true)
        switchView.tag = indexPath.row + 1000*indexPath.section
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        cell.selectionStyle = .none
        return cell
    }
    
    @objc fileprivate func switchChanged(_ sender : UISwitch!){
        let row = sender.tag % 1000
        let section = sender.tag / 1000
        notifPrefs[sections[section].notifType.subtypes[row]] = sender.isOn
        
        if section == 0 {
            AppDelegate.userDefaults.set(sender.isOn, forKey: "inAppNotifs")
            if sender.isOn {
                for section in sections.indices {
                    if section == 0 { continue }
                    let sectionHeader = tableView.headerView(forSection: section) as! sectionHeader
                    let button = sectionHeader.button
                    button.enable()
                }
            } else { // don't allow notificationsso close
                for section in sections.indices {
                    if section == 0 { continue }
                    let sectionHeader = tableView.headerView(forSection: section) as! sectionHeader
                    let button = sectionHeader.button
                    button.close()
                    forceCloseSection(section: section)
                    button.disable()
                }
            }
           
        }
    }
    
    private func forceCloseSection(section: Int) {
        if sections[section].open {
            openSection(section: section)
        }
    }
    
    internal func openSection(section: Int) {
        if section == 0 { return }
        var indexPaths = [IndexPath]()
        for row in sections[section].notifType.subtypes.indices {
            let indexPathToDelete = IndexPath(row: row, section: section)
            indexPaths.append(indexPathToDelete)
        }
        
        let isOpen = sections[section].open
        sections[section].open = !isOpen
        
        if isOpen {
            tableView.deleteRows(at: indexPaths, with: .automatic)
        } else {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    fileprivate class sectionHeader: UITableViewHeaderFooterView {
        static let identifier = "sectionHeader"
        lazy var button: sectionButton = {
            return sectionButton()
        }()
        weak var delegate: NotificationSectionHeaderDelegate?
        var section: Int?
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.topAnchor.constraint(equalTo: topAnchor).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            button.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            button.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            
            let separator = UIView()
            addSubview(separator)
            separator.backgroundColor = .zipSeparator
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            separator.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            separator.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        public func configure(sectionData: SectionData, sectionIdx: Int){
            button.configure(sectionData: sectionData)
            button.backgroundColor = .zipGray
            button.tag = sectionIdx
            button.setTitle(sectionData.notifType.description, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.zipLightGray, for: .disabled)
            button.titleLabel?.font = .zipTextFill
            button.addTarget(self, action: #selector(openSection(button:)), for: .touchUpInside)
            button.contentHorizontalAlignment = .left
            button.contentVerticalAlignment = .center
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
        }
        
        
        
        @objc private func openSection(button: sectionButton) {
            button.switchIndiciator()
            delegate?.openSection(section: button.tag)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    fileprivate class sectionButton: UIButton {
        var sectionData: SectionData
        var imgView: UIImageView
       
        init() {
            sectionData = SectionData(open: false, notifType: .general)
            let img = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            self.imgView = UIImageView(image: img)
            super.init(frame: .zero)
            
            addSubview(imgView)
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            imgView.rightAnchor.constraint(equalTo: rightAnchor,constant: -10).isActive = true
        }
        
        init(sectionData: SectionData, frame: CGRect = .zero) {
            self.sectionData = sectionData
            let img = UIImage(systemName: sectionData.open ? "chevron.up" : "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            self.imgView = UIImageView(image: img)
            super.init(frame: frame)
            
            addSubview(imgView)
            imgView.translatesAutoresizingMaskIntoConstraints = false
            imgView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            imgView.rightAnchor.constraint(equalTo: rightAnchor,constant: -10).isActive = true
        }
        
        public func configure(sectionData: SectionData){
            self.sectionData = sectionData
            let img = UIImage(systemName: sectionData.open ? "chevron.up" : "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            self.imgView.image = img
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func switchIndiciator(){
            print("1",sectionData.open)
            sectionData.open = !sectionData.open
            print("2",sectionData.open)
            let img = UIImage(systemName: sectionData.open ? "chevron.up" : "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            imgView.image = img
        }
        
        public func close() {
            sectionData.open = false
            let img = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            imgView.image = img
        }
        
        public func open() {
            sectionData.open = true
            let img = UIImage(systemName: "chevron.up")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            imgView.image = img
        }
        
        public func disable() {
            isEnabled = false
            let img = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.zipLightGray)
            imgView.image = img
        }
        
        public func enable() {
            isEnabled = true
            let img = UIImage(systemName: "chevron.down")?.withRenderingMode(.alwaysOriginal).withTintColor(.white)
            imgView.image = img
        }
    }
}
